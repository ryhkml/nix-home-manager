{
  config,
  lib,
  pkgs,
  # Extra nixpkgs instances and nixGL, supplied by flake.nix via extraSpecialArgs.
  pkgs2511,
  pkgsLangservers,
  pkgsGhostty,
  nixgl,
  ...
}:

let
  # Vim plugins
  # Some Vim plugins is not available in nixpkgs
  myVimPlugin =
    repo: rev:
    pkgs2511.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = "HEAD";
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        rev = rev;
      };
    };
  # Neovim stable from nixpkgs 25.11, including its compatible tree-sitter dependency set.
  neovimStable = pkgs2511.neovim-unwrapped;
  # vscode-langservers-extracted pinned to the last commit before nixpkgs rewrote it to
  # "extract directly from vscodium" (5611e17, 2026-06-23). That rewrite ships 1.106.27818,
  # whose json/css server entrypoints require missing webpack chunks (962/920) → jsonls/cssls
  # crash on startup. This parent commit provides the working 4.10.0 build.
  langserversFixed = pkgsLangservers.vscode-langservers-extracted;
  # Bun only for x86_64-linux
  # https://github.com/oven-sh/bun/releases
  bunLatest = pkgs.bun.overrideAttrs (old: rec {
    pname = "bun";
    version = "1.4.2";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "04x94ba6hh6nin521diym3r425q2936m6bm5zzapay2jyyp8ydin";
    };
  });
  # CodeGraph only for x86_64-linux
  # https://github.com/colbymchenry/codegraph/releases
  codegraphLatest = pkgs.stdenv.mkDerivation rec {
    pname = "codegraph";
    version = "1.6.1";
    src = pkgs.fetchurl {
      url = "https://github.com/colbymchenry/codegraph/releases/download/v${version}/codegraph-linux-x64.tar.gz";
      sha256 = "09jxiwmlfsp108nbbi19vrcz9zh3h9lc3vwdfvfs6xc1mwpi2z3n";
    };
    sourceRoot = "codegraph-linux-x64";
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.autoPatchelfHook
    ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/codegraph
      cp -r lib $out/lib/codegraph/lib
      cp node $out/lib/codegraph/node
      install -Dm 755 bin/codegraph $out/lib/codegraph/bin/codegraph
      mkdir -p $out/bin
      makeWrapper $out/lib/codegraph/bin/codegraph $out/bin/codegraph
      runHook postInstall
    '';
  };
  # fff MCP server only for x86_64-linux.
  # Upstream ships a static-pie musl binary, so this tracks the latest release without compiling the Rust workspace.
  # https://github.com/dmtrKovalenko/fff/releases
  fffMcpLatest = pkgs.stdenv.mkDerivation rec {
    pname = "fff-mcp";
    version = "0.10.6";
    src = pkgs.fetchurl {
      url = "https://github.com/dmtrKovalenko/fff/releases/download/v${version}/fff-mcp-x86_64-unknown-linux-musl";
      sha256 = "03zvip4w8m4mn2khsd85iwlidva8lzcj83397fk4lxgi2m0gckm4";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      install -Dm 755 $src $out/bin/fff-mcp
    '';
  };
  # Firebase CLI only for linux
  # https://github.com/firebase/firebase-tools/releases
  firebaseToolsLatest = pkgs.stdenv.mkDerivation rec {
    pname = "firebase-tools";
    version = "14.27.0";
    src = pkgs.fetchurl {
      url = "https://github.com/firebase/firebase-tools/releases/download/v${version}/firebase-tools-linux";
      sha256 = "1j1gqsxcwxnkszhbh85bn2jss030sj4lj0lvrp7pss5r3096vz4s";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/firebase
      chmod +x $out/bin/firebase
    '';
  };
  # Google Cloud CLI only for x86_64-linux
  # https://console.cloud.google.com/storage/browser/cloud-sdk-release
  gcloudLatest = pkgs.google-cloud-sdk.overrideAttrs (old: rec {
    pname = "google-cloud-sdk";
    version = "581.0.0";
    src = pkgs.fetchurl {
      url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${version}-linux-x86_64.tar.gz";
      sha256 = "14gvc7c0cha7v7jv4bkisc0m3q018kr989agi7hma4xgqmdwzrij";
    };
    installCheckPhase = ''
      echo "Skip installCheckPhase"
    '';
  });
  # Ghostty comes from its own pinned input. overrideAttrs does not work here:
  # Ghostty builds with Zig against a version-specific vendored cache, which
  # nixpkgs generates as 36 hashes in by-name/gh/ghostty/deps.nix.
  #
  # Update: nix flake update nixpkgs-ghostty
  # https://github.com/ghostty-org/ghostty/releases
  ghosttyLatest = pkgsGhostty.ghostty;
  # Go only for Linux x86_64
  # https://go.dev/dl
  goLatest = pkgs.go.overrideAttrs (old: rec {
    pname = "go";
    version = "1.27.1";
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      sha256 = "1c9qn8m8cpxldnw97mhj2g5f7w2l5hzij9s62sv1dn96w6x8lh2f";
    };
    # nixpkgs still ships the 1.26 copy of go_no_vendor_checks and its hunk no
    # longer applies to the 1.27 tree, which fails the whole build.
    # The patch only relaxes vendor consistency checks for nixpkgs' own
    # buildGoModule; this toolchain is used interactively, so stock upstream
    # behaviour is what we want. Every other patch is kept -- go_ldso and tzdata
    # are what make Go work against store paths.
    patches = builtins.filter (
      p: !lib.hasSuffix "go_no_vendor_checks-1.26.patch" (toString p)
    ) old.patches;
  });
  # Nodejs only for x86_64-linux
  # https://nodejs.org/en/download/prebuilt-binaries
  nodejsLatestLts = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "24.20.0";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "1wnblxq6q5v1pi5xw19iixnd7lrfiiy0qhb5fvj0v3ricahhsb1g";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xJf $src --strip-components=1 -C $out
      mv $out/LICENSE $out/share/doc/LICENSE_nodejs
    '';
  };
  # Obscura only for x86_64-linux
  # nixpkgs lags upstream, so the release tarball is used instead. The stealth
  # variant bundles both build features nixpkgs leaves off: render (screenshots,
  # screencasts, PDF) and stealth (BoringSSL TLS impersonation, tracker blocking).
  # https://github.com/h4ckf0r0day/obscura/releases
  obscuraLatest = pkgs.stdenv.mkDerivation rec {
    pname = "obscura";
    version = "0.2.2";
    src = pkgs.fetchurl {
      url = "https://github.com/h4ckf0r0day/obscura/releases/download/v${version}/obscura-x86_64-linux-stealth.tar.gz";
      sha256 = "18axvlmy59cjvcybh6dvccys9nvsaynzlikg9pacc44cjhl6rx7s";
    };
    # Two loose binaries, no wrapping directory.
    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      # obscura launches obscura-worker by bare name, so both must share a bin.
      install -Dm 755 obscura obscura-worker -t $out/bin
      runHook postInstall
    '';
  };
  # nixpkgs ships neither prettier-plugin-astro nor prettier-plugin-svelte on its
  # own; both are bundled inside their language server behind a pnpm-hashed
  # directory name, hence the glob.
  prettierWithPlugins = pkgs.writeShellScriptBin "prettier-with-plugins" ''
    shopt -s nullglob
    astro=(${pkgs.astro-language-server}/lib/node_modules/astro-language-server/node_modules/.pnpm/prettier-plugin-astro@*/node_modules/prettier-plugin-astro/dist/index.js)
    svelte=(${pkgs.svelte-language-server}/lib/node_modules/svelte-language-server/node_modules/.pnpm/prettier-plugin-svelte@*/node_modules/prettier-plugin-svelte/plugin.js)
    args=()
    for plugin in "''${astro[0]}" "''${svelte[0]}"; do
      if [ -n "$plugin" ]; then
        args+=(--plugin "$plugin")
      fi
    done
    if [ ''${#args[@]} -eq 0 ]; then
      echo "no prettier plugin found in the astro or svelte language server" >&2
      exit 1
    fi
    exec ${pkgs.prettier}/bin/prettier "''${args[@]}" "$@"
  '';
  # RTK (Rust Token Killer) only for x86_64-linux
  # https://github.com/rtk-ai/rtk/releases
  rtkLatest = pkgs.stdenv.mkDerivation rec {
    pname = "rtk";
    version = "0.50.0";
    src = pkgs.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "12azv9xxr8rmc8ayx9gcmxbpgq874fp1cpzl5v49diyrn018jaxw";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin rtk
      chmod +x $out/bin/rtk
    '';
  };
  # Tmux from source
  # https://github.com/tmux/tmux/releases
  tmuxLatest = pkgs.tmux.overrideAttrs (old: rec {
    pname = "tmux";
    version = "3.7c";
    src = pkgs.fetchurl {
      url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
      sha256 = "1gxkrw0l5vi93dz48pjmsizzq048kvyall27wbi8hlp2l3lwlq3w";
    };
    patches = [ ];
  });
in
{
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "ryhkml";
    homeDirectory = "/home/ryhkml";
    stateVersion = "25.05";
    packages = with pkgs; [
      # # A
      act
      air
      asciiquarium-transparent
      # # B
      bash-language-server
      binsider
      # # C
      cmus
      codegraphLatest
      # # D
      duf
      # # E
      exiftool
      # # F
      fffMcpLatest
      file
      firebaseToolsLatest
      # # G
      gcloudLatest
      gopls
      govulncheck
      (go-migrate.overrideAttrs (old: {
        tags = [
          "mysql"
          "postgres"
        ];
      }))
      gping
      # # H
      hey
      hyperfine
      # # I
      id3v2
      # # J
      jq
      # # K
      k6
      # # L
      lazydocker
      lazysql
      lua
      lua-language-server
      # # M
      markitdown
      minify
      mysql84
      # # N
      nix-prefetch-git
      nodejsLatestLts
      # # O
      obscuraLatest
      onefetch
      # # P
      php
      pnpm
      podman-compose
      postgresql
      prettier
      pyright
      python313Packages.huggingface-hub
      # # Q
      qpdf
      # # R
      rlwrap
      rtkLatest
      rustup
      # # S
      shellcheck
      # # T
      tesseract
      tmuxLatest
      tree-sitter
      tokei
      typescript
      typescript-language-server
      # # U
      ueberzugpp
      unar
      uv
      # # V
      langserversFixed
      # # W
      weathr
      # # Y
      yt-dlp
    ];
    file = {
      ".bunfig.toml".text = ''
        smol = true
        telemetry = false

        [install]
        exact = true
      '';
      ".clang-format".text = ''
        ---
        BasedOnStyle: Google
        IndentWidth: 4
        ColumnLimit: 120
        AlignArrayOfStructures: Left
        AlignAfterOpenBracket: Align
        BracedInitializerIndentWidth: 4
        ---
        Language: Proto
        ColumnLimit: 100
        ---
        Language: CSharp
        DisableFormat: true
        ---
        Language: JavaScript
        DisableFormat: true
      '';
      ".curlrc".text = ''
        -s
        -L
        -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"
        -H "Cache-Control: no-cache, no-store, must-revalidate"
        --retry 5
        --retry-delay 5
        --connect-timeout 30
      '';
      ".config/dunst/dunstrc".text = ''
        [global]
        font = FiraCode Nerd Font 13
        width = (300, 600)
        origin = bottom-center
        # Nothing occupies the bottom edge, so this is a plain margin.
        # The horizontal value is ignored by a centered origin.
        offset = (0, 24)
        # A gap makes dunst frame and round each notification separately instead of shaping the whole stack.
        # It also makes separator_height irrelevant, so that setting is gone.
        gap_size = 8
        # No corner radius anywhere: waybar sets border-radius 0 and niri draws square windows, so a rounded notification would be the only curve on screen.
        # The frame is 2px to match the width of the niri focus ring.
        frame_width = 2
        padding = 14
        horizontal_padding = 14
        text_icon_padding = 12
        icon_position = left
        max_icon_size = 48
        enable_recursive_icon_lookup = true
        # bin/volume and bin/brightness already send int:value, so this bar is in use.
        progress_bar_height = 8
        progress_bar_frame_width = 0
        sort = update
        # The transparency option is X11 only.
        # On Wayland the alpha has to ride on the color itself, hence the trailing b3 (70% opaque).
        # Measured against a bright video frame: 80% hid the blur entirely, 60% picked up too much of the background colour at bottom-center.
        [urgency_low]
        background = "#1c1f26b3"
        # #c4cbd4 held only 3.73:1 against the card over a white page, and the old #3a4152 frame just 1.77:1 against the card itself.
        foreground = "#dadee4"
        frame_color = "#59637d"
        highlight = "#526596"
        [urgency_normal]
        background = "#1c1f26b3"
        foreground = "#e6e6e6"
        frame_color = "#526596"
        highlight = "#526596"
        [urgency_critical]
        background = "#1c1f26b3"
        foreground = "#ffffff"
        frame_color = "#ff4d4f"
        highlight = "#ff4d4f"
        [ignore]
        appname=spotify
        skip_display = true
        [skip-display]
        appname=spotify
        skip_display = yes
        # No filter, so this matches every notification.
        # The script itself skips volume, brightness and Spotify, because a later rule can only add scripts, never remove one.
        [sound]
        script = ${config.home.homeDirectory}/.config/niri/bin/notify-sound
      '';
      ".config/foot/foot.ini".text = ''
        font=FiraCode Nerd Font:size=16
        letter-spacing=0.5
        term=xterm-256color
        pad=6x6 center
        initial-window-mode=maximized
        [cursor]
        style=beam
        blink=yes
        [colors]
        background=000000
        foreground=ffffff
        [mouse]
        hide-when-typing=yes
      '';
      ".config/lazydocker/config.yml".text = ''
        gui:
          border: "single"
          language: "en"
        logs:
          timestamps: true
          since: ""
      '';
      ".config/rofi/config.rasi".text = ''
        configuration {
          modes: "drun";
          combi-modes: [drun];
          font: "FiraCode Nerd Font 14";
          drun-display-format: "{name}";
        }

        /* Same palette as dunst and the niri focus ring, and square everywhere for the same reason waybar sets border-radius 0. */
        * {
          surface:    #1c1f26b3;
          on-surface: #e6e6e6;
          muted:      #dadee4;   /* 4.52:1 worst case; #c4cbd4 gave 3.73:1 */
          accent:     #526596;
          urgent:     #ff4d4f;

          background-color: transparent;
          text-color:       @on-surface;
        }

        window {
          width:            40%;
          background-color: @surface;
          border:           2px;
          border-color:     @accent;
          padding:          0;
        }

        mainbox {
          padding:  0;
          spacing:  0;
          children: [ inputbar, listview ];
        }

        inputbar {
          padding:      14px 16px;
          spacing:      10px;
          children:     [ prompt, entry ];
          border:       0 0 2px 0;
          border-color: @accent;
        }

        /* Both need an explicit text-color for the same reason the element states do: rofi's own rules outrank the * selector. */
        prompt {
          text-color:     @muted;
          vertical-align: 0.5;
        }

        entry {
          text-color:        @on-surface;
          cursor-color:      @on-surface;
          vertical-align:    0.5;
          placeholder:       "";
          placeholder-color: @muted;
        }

        listview {
          lines:     10;
          columns:   1;
          scrollbar: false;
          padding:   8px 0;
          spacing:   0;
          /* rofi's own listview carries a dashed top border; the inputbar below already draws the separator. */
          border:    0;
          /* Without this the power menu reserves all 10 rows for its 4 entries. */
          fixed-height: false;
        }

        element {
          padding: 10px 16px;
          spacing: 12px;
        }

        /* Every state needs naming: rofi ships its own element rules, and a bare * selector loses to them. */
        element normal.normal,
        element alternate.normal {
          background-color: transparent;
          text-color:       @on-surface;
        }

        element normal.urgent,
        element alternate.urgent {
          background-color: transparent;
          text-color:       @urgent;
        }

        element normal.active,
        element alternate.active {
          background-color: transparent;
          text-color:       @accent;
        }

        element selected.normal,
        element selected.active {
          background-color: @accent;
          text-color:       #ffffff;
        }

        element selected.urgent {
          background-color: @urgent;
          text-color:       #ffffff;
        }

        element-icon {
          size:           28px;
          vertical-align: 0.5;
        }

        element-text {
          vertical-align: 0.5;
          text-color:     inherit;
        }

        message {
          padding:      10px 16px;
          border:       2px 0 0 0;
          border-color: @accent;
        }

        textbox {
          text-color: @muted;
        }
      '';
      ".npmrc".text = ''
        ignore-scripts=true
        save-exact=true
      '';
      ".scripts/waybar/custom-wifi.sh".text = ''
        #!/usr/bin/env bash
        set -e
        if ! systemctl is-active --quiet NetworkManager; then
          notify-send -t 3000 -u critical "NetworkManager" "NetworkManager is not running"
          exit 13
        fi
        if nmcli radio wifi | grep -q "disabled"; then
          notify-send -t 3000 -u critical "WiFi" "WiFi is disabled"
          exit 13
        fi
        nmcli device wifi rescan
        networks=()
        while IFS= read -r line; do
          networks+=("$line")
        done < <(nmcli -t -f SSID,SIGNAL device wifi list | awk -F: '$1 != "" && !seen[$1]++ { printf "[%s%%] %s\n", $2, $1 }')
        chosen=$(printf '%s\n' "''${networks[@]}" | rofi -dmenu -no-custom -i -p "Select a WiFi network")
        [ -z "$chosen" ] && exit
        ssid="''${chosen#*] }"
        nmcli device wifi connect "$ssid" && notify-send -t 3000 "WiFi" "Connected to $ssid"
      '';
      ".scripts/waybar/custom-clock.sh".text = ''
        #!/usr/bin/env bash
        set -e
        current_date=$(date +'%A - %B %-d, %Y')
        current_time=$(date +'%-l:%M:%S')
        echo -n "{\"text\": \"$current_time\", \"tooltip\": \"$current_date\"}"
      '';
      ".scripts/rofi/power.sh".text = ''
        #!/usr/bin/env bash
        set -e
        options="Logout\nSuspend\nReboot\nPower Off"
        menu=$(echo -e "$options" | rofi -dmenu -no-custom -i -p "Select Action")
        case "$menu" in
          "Logout")
            # One script serves both sessions: niri exports NIRI_SOCKET, sway does not.
            # No braces on the variable: Nix would read ''${...} as interpolation.
            if [ -n "$NIRI_SOCKET" ]; then
              niri msg action quit -s
            else
              swaymsg exit
            fi
            ;;
          "Suspend")
            systemctl suspend
            ;;
          "Reboot")
            systemctl reboot
            ;;
          "Power Off")
            systemctl poweroff
            ;;
          "*")
            echo -n
            ;;
        esac
      '';
      ".personal.txt".text = ''
            .--.
           |o_o |
           |:_/ |
          //   \ \
         (|     | )
        /'\_   _/`\
        \___)=(___/
      '';
    };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_style = "tab";
        indent_size = 4;
        trim_trailing_whitespace = true;
        insert_final_newline = true;
      };
      "*.nix" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.toml" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.yaml" = {
        indent_style = "space";
        indent_size = 2;
      };
      "*.yml" = {
        indent_style = "space";
        indent_size = 2;
      };
      "flake.lock" = {
        indent_style = "space";
        indent_size = 2;
      };
    };
  };

  # GPU on non-NixOS systems
  # https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
  # https://github.com/nix-community/nixGL
  targets.genericLinux.nixGL.packages = import nixgl { inherit pkgs; };
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  targets.genericLinux.nixGL.installScripts = [ "mesa" ];

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    plugins = with pkgs; [
      {
        name = "autopair";
        src = fishPlugins.autopair.src;
      }
    ];
    shellAbbrs = {
      "/" = "cd /";
      ".." = "cd ..";
      c = "clear";
      C = "clear";
      q = "exit";
      Q = "exit";
      # Act
      acts = "act --no-cache-server --rm";
      # Claude Code
      cr = "claude -r";
      cdr = "claude doctor";
      cup = "claude update";
      # Update library
      cmusup = "cmus-remote -C clear; cmus-remote -C \"add ~/Music\"; cmus-remote -C \"update-cache -f\"";
      # Greatest abbreviations downloader ever
      dlmp3 = "yt-dlp --embed-thumbnail -o \"%(channel)s - %(title)s.%(ext)s\" -f bestaudio -x --audio-format mp3 --audio-quality 320 ?";
      dlmp4 = "yt-dlp --embed-thumbnail -S res,ext:mp4:m4a --recode mp4 ?";
      # Git
      gitpt = "set -l TAG_NAME (jq .version package.json -r); set -l TIMESTAMP (date +'%Y/%m/%d'); git tag -s $TAG_NAME -m \"$TIMESTAMP\"; git push origin $TAG_NAME";
      # Lazy
      lzd = "lazydocker";
      lzg = "lazygit";
      # Wifi
      setnm = "set NETWORK_NAME (nmcli -t -f NAME connection show --active | head -n 1)";
      nmwon = "nmcli radio wifi on";
      nmwoff = "nmcli radio wifi off";
      nmwconn = "nmcli device wifi connect ?";
      nmreconn = "nmcli connection down $NETWORK_NAME; and nmcli connection up $NETWORK_NAME";
      nmwscan = "nmcli device wifi rescan";
      nmwls = "nmcli device wifi list";
      nmactive = "nmcli connection show --active";
      nmup = "nmcli connection up $NETWORK_NAME";
      nmdown = "nmcli connection down $NETWORK_NAME";
      nmdnsv4-google = "nmcli connection modify $NETWORK_NAME ipv4.dns \"8.8.8.8,8.8.4.4\"; nmcli connection modify $NETWORK_NAME ipv4.ignore-auto-dns yes";
      nmdnsv6-google = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2001:4860:4860::8888,2001:4860:4860::8844\"; nmcli connection modify $NETWORK_NAME ipv6.ignore-auto-dns yes";
      nmdnsv4-cloudflare = "nmcli connection modify $NETWORK_NAME ipv4.dns \"1.1.1.1,1.0.0.1\"; nmcli connection modify $NETWORK_NAME ipv4.ignore-auto-dns yes";
      nmdnsv6-cloudflare = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2606:4700:4700::1111,2606:4700:4700::1001\"; nmcli connection modify $NETWORK_NAME ipv6.ignore-auto-dns yes";
      nmdnsv4-quad9 = "nmcli connection modify $NETWORK_NAME ipv4.dns \"9.9.9.9,149.112.112.112\"; nmcli connection modify $NETWORK_NAME ipv4.ignore-auto-dns yes";
      nmdnsv6-quad9 = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2620:fe::fe,2620:fe::9\"; nmcli connection modify $NETWORK_NAME ipv6.ignore-auto-dns yes";
      v = "nvim";
      # Greatest abbreviations ever
      fv = "fd -H -I -E .angular -E .git -E dist -E node_modules -E target | fzf --reverse | xargs -r nvim";
      # Open
      xof = "xdg-open $(pwd)/?";
    };
    shellAliases = {
      docker = "podman";
    };
    shellInit = ''
      # Source: jorgebucaran, https://github.com/jorgebucaran/humantime.fish
      function humantime -a ms
        set -q ms[1] || return
        set -l secs (math --scale=1 $ms/1000 % 60)
        set -l mins (math --scale=0 $ms/60000 % 60)
        set -l hours (math --scale=0 $ms/3600000)
        test $hours -gt 0 && set -l -a out $hours"h"
        test $mins -gt 0 && set -l -a out $mins"m"
        test $secs -gt 0 && set -l -a out $secs"s"
        set -q out && echo $out || echo $ms"ms"
      end
      # Left side prompt
      function fish_prompt
        set -l last_status $status
        set -l stat
        if test $last_status -ne 0
          set stat (set_color red)" [$last_status]"(set_color normal)
        end
        # One call reports oid, head and dirtiness, and unlike `test -d .git` it
        # still works from a subdirectory.
        set -l git_out (git status --porcelain=v2 --branch 2>/dev/null)
        set -l git_info
        if test -n "$git_out"
          set -l oid (string replace -f "# branch.oid " "" -- $git_out)
          set -l head (string replace -f "# branch.head " "" -- $git_out)
          set -l dirty (string match -v -- "#*" $git_out)
          if test "$oid" = "(initial)"
            set git_info (set_color cyan)" git?"(set_color normal)
          else
            # Must be "" and not an empty list: concatenating an empty list
            # collapses the whole expression to nothing.
            set -l mark ""
            if test -n "$dirty"
              set mark " "(set_color yellow)"!"(set_color normal)
            end
            set git_info " "(set_color cyan)(string sub -l 7 -- $oid)":$head"(set_color normal)$mark
          end
        end
        string join "" -- (set_color normal) (prompt_pwd) $stat $git_info " -> "
      end
      # Right side prompt
      function fish_right_prompt
        set -l time_d (humantime $CMD_DURATION)
        echo -n " $time_d"
      end
      #
      set -U fish_greeting
      set -gx CGO_ENABLED 1
      set -gx GOTELEMETRY off
      set -gx CLOUDSDK_PYTHON_SITEPACKAGES 1
      set -gx DOCKER_BUILDKIT 1
      set -gx DOCKER_HOST unix:///run/user/1000/podman/podman.sock
      set -gx GPG_TTY (tty)
      set -gx NODE_OPTIONS --max-old-space-size=8192
      set -gx XCURSOR_THEME Bibata-Original-Ice
      # Opencode
      set -gx OPENCODE_DISABLE_CLAUDE_CODE 1
      set -gx OPENCODE_DISABLE_CLAUDE_CODE_PROMPT 1
      set -gx OPENCODE_DISABLE_CLAUDE_CODE_SKILLS 1
    '';
    functions = {
      "screenshot_entire_screen -S" = ''
        set -l output_dir ~/Pictures/screenshot/entire-screen
        set -l timestamp (date +'%F-%T')
        set -l output_file $output_dir/ss-$timestamp.png
        grim $output_file
        notify-send "Screenshot" "Entire screen saved" -t 2000
      '';
      "screenshot_on_window_focus -S" = ''
        set -l output_dir ~/Pictures/screenshot/window-focus
        set -l timestamp (date +'%F-%T')
        set -l output_file $output_dir/ss-$timestamp.png
        grim -g (swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp) $output_file
        notify-send "Screenshot" "Focus window screen saved" -t 2000
      '';
      "screenshot_selected_area -S" = ''
        set -l output_dir ~/Pictures/screenshot/selected-area
        set -l timestamp (date +'%F-%T')
        set -l output_file $output_dir/ss-$timestamp.png
        grim -g (slurp) $output_file
        notify-send "Screenshot" "Selected area saved" -t 2000
      '';
    };
  };

  programs = {
    bat = {
      enable = true;
      config = {
        italic-text = "never";
        pager = "less -FR";
        theme = "base16";
        wrap = "never";
      };
    };
    btop = {
      enable = true;
      settings = {
        color_theme = "kanagawa-dragon";
        show_battery = false;
        base_10_sizes = true;
        temp_scale = "celsius";
        update_ms = 1000;
        clock_format = "";
        rounded_corners = false;
        log_level = "WARNING";
      };
    };
    bun = {
      enable = true;
      package = bunLatest;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "${config.home.homeDirectory}/.personal.txt";
          color = {
            "1" = "white";
          };
        };
        display = {
          color = "white";
          separator = "";
          size.binaryPrefix = "jedec";
        };
        modules = [
          "title"
          "separator"
          {
            type = "os";
            key = "OS: ";
          }
          {
            type = "host";
            key = "Host: ";
            format = "{?2}{2}{?}{?5} ({5}){?}";
          }
          {
            type = "kernel";
            key = "Kernel: ";
          }
          {
            type = "command";
            key = "SELinux: ";
            text = "echo \"$(sestatus | head -n 1 | cut -d ':' -f2 | xargs | sed 's/^./\\u&/') - $(getenforce)\"";
            format = "{result}";
          }
          {
            type = "wm";
            key = "Window Manager: ";
          }
          {
            type = "de";
            key = "Desktop Environment: ";
          }
          "break"
          {
            type = "cpu";
            key = "CPU: ";
          }
          {
            type = "gpu";
            key = "GPU: ";
          }
          {
            type = "memory";
            key = "Memory: ";
          }
          {
            type = "swap";
            key = "Swap: ";
          }
          {
            type = "disk";
            key = "Disk: ";
          }
          {
            type = "display";
            key = "Resolution: ";
          }
          {
            type = "locale";
            key = "Locale: ";
          }
          "break"
          {
            type = "command";
            key = "Terminal Workspace: ";
            text = "echo \"$(ghostty --version | head -1) + $(tmux -V)\"";
            format = "{result}";
          }
          {
            type = "shell";
            key = "Shell: ";
          }
          "break"
          {
            type = "custom";
            format = "{#1}Development:";
          }
          {
            type = "command";
            key = "- ";
            text = "bun -v";
            format = "bun (Bun) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "claude --version | awk '{print $1}'";
            format = "claude (Claude Code) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "(git --version | cut -d ' ' -f3) 2>/dev/null || echo -n 'ERROR'";
            format = "git (Git) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "go version | cut -d ' ' -f3- | cut -c3-";
            format = "go (Go) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "nix --version 2>/dev/null";
            format = "{result}";
          }
          {
            type = "command";
            key = "- ";
            text = "nvim --version | head -n1 | cut -d ' ' -f2 | cut -c2-";
            format = "nvim (Neovim) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "(podman --version | cut -d ' ' -f3) 2>/dev/null || echo -n 'ERROR'";
            format = "podman (Podman) {result}";
          }
          {
            type = "command";
            key = "- ";
            text = "(wg --version | awk '{print substr($2, 2)}') 2>/dev/null || echo -n 'ERROR'";
            format = "wg (WireGuard) {result}";
          }
          "break"
        ];
      };
    };
    fd = {
      enable = true;
      hidden = true;
      ignores = [
        ".git/"
        ".angular/"
        ".database/"
        ".db/"
        ".firebase/"
        "node_modules/"
        "target/"
        "*.min.css"
        "*.min.js"
      ];
      extraOptions = [
        "-tf"
        "--no-require-git"
      ];
    };
    fzf.enable = true;
    ghostty = {
      enable = true;
      package = config.lib.nixGL.wrap ghosttyLatest;
      settings = {
        command = "${config.home.profileDirectory}/bin/fish";
        shell-integration-features = "sudo,ssh-env";
        font-family = "FiraCode Nerd Font";
        font-style = "Regular";
        font-size = 16;
        foreground = "#ffffff";
        background = "#0c0c0c";
        selection-foreground = "#ffffff";
        selection-background = "#264f78";
        # All six hues stay: TUIs treat ANSI colors as semantics (red = error),
        # so graying them out would break git, fzf and btop. Aligned instead:
        # slot 4 is the Neovim/Sway blue, 8 and 12 match Comment and escape, and
        # every entry clears 4.5:1 on #0c0c0c -- old 4 and 5 did not.
        palette = [
          "0=#0c0c0c"
          "1=#ff4d4f"
          "2=#52c41a"
          "3=#faad14"
          "4=#667db7"
          "5=#f759ab"
          "6=#08979c"
          "7=#cccccc"
          "8=#7a7a7a"
          "9=#ff7875"
          "10=#73d13d"
          "11=#ffc53d"
          "12=#9fb0d8"
          "13=#ff85c0"
          "14=#36cfc9"
          "15=#ffffff"
        ];
        cursor-style = "bar";
        cursor-style-blink = true;
        window-decoration = "none";
        window-theme = "dark";
        window-padding-balance = true;
        background-opacity = 0.95;
        maximize = true;
        copy-on-select = "clipboard";
        keybind = [ "shift+enter=text:\\n" ];
      };
    };
    go = {
      enable = true;
      package = goLatest;
      telemetry.mode = "off";
      env.GOPATH = "${config.home.homeDirectory}/.go";
    };
    lazygit = {
      enable = true;
      settings = {
        gui = {
          border = "single";
        };
        git = {
          merging = {
            args = "-S";
          };
          mainBranches = [
            "master"
            "main"
            "dev"
            "next"
          ];
        };
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      package = neovimStable;
      withRuby = true;
      withPython3 = true;
      plugins = with pkgs2511.vimPlugins; [
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/gitsigns.lua;
        }
        {
          plugin = hlchunk-nvim.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace lua/hlchunk/utils/chunkHelper.lua \
                --replace-fail \
                  'local cur_row_val = vim.api.nvim_buf_get_lines(pos.bufnr, pos.row, pos.row + 1, false)[1]' \
                  'local cur_row_val = vim.api.nvim_buf_get_lines(pos.bufnr, pos.row, pos.row + 1, false)[1]
              if cur_row_val == nil then
                  return chunkHelper.CHUNK_RANGE_RET.NO_CHUNK, Scope(pos.bufnr, -1, -1)
              end'
            '';
          });
          type = "lua";
          config = builtins.readFile ./nvim/plugins/hlchunk.lua;
        }
        # https://github.com/neovim/nvim-lspconfig
        nvim-lspconfig
        {
          plugin = luasnip;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/luasnip.lua;
        }
        # https://github.com/b0o/SchemaStore.nvim
        SchemaStore-nvim
        {
          plugin = nvim-cmp;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/cmp.lua;
        }
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/lsp.lua;
        }
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        {
          plugin = telescope-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/telescope.lua;
        }
        {
          plugin = nvim-treesitter;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/treesitter.lua;
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/autopairs.lua;
        }
        vim-visual-multi
        {
          plugin = myVimPlugin "slugbyte/lackluster.nvim" "b247a6f51cb43e49f3f753f4a59553b698bf5438";
          type = "lua";
          config = builtins.readFile ./nvim/plugins/lackluster.lua;
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/lualine.lua;
        }
        {
          plugin = nvim-colorizer-lua;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/colorizer.lua;
        }
        {
          plugin = comment-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/comment.lua;
        }
        {
          plugin = treesj;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/treesj.lua;
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/surround.lua;
        }
        {
          plugin = lsp_lines-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/lsp_lines.lua;
        }
        {
          plugin = conform-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/conform.lua;
        }
        {
          plugin = markdown-preview-nvim;
          type = "viml";
          config = ''
            let g:mkdp_port = "10013"
            let g:mkdp_theme = "dark"
          '';
        }
        lazygit-nvim
        {
          plugin = nui-nvim;
          optional = true;
        }
        {
          plugin = myVimPlugin "VonHeikemen/fine-cmdline.nvim" "6e646f4da6afe856e36f3d952489b723d1475638";
          type = "lua";
          config = builtins.readFile ./nvim/plugins/fine-cmdline.lua;
        }
        {
          plugin = searchbox-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/searchbox.lua;
        }
        # Explorer
        {
          plugin = nvim-web-devicons;
          optional = true;
        }
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/nvim-tree.lua;
        }
        # Tab
        {
          plugin = tabby-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/tabby.lua;
        }
        vim-wakatime
        {
          plugin = myVimPlugin "nvzone/showkeys" "cb0a50296f11f1e585acffba8c253b9e8afc1f84";
          type = "lua";
          config = builtins.readFile ./nvim/plugins/showkeys.lua;
        }
      ];
      extraPackages = with pkgs; [
        # LSP and Fmt
        asm-lsp
        asmfmt
        astro-language-server
        astyle
        black
        prettierWithPlugins
        docker-language-server
        dockerfile-language-server
        hclfmt
        htmx-lsp
        isort
        nginx-config-formatter
        nil
        nixfmt
        rust-analyzer
        rustfmt
        shfmt
        stylua
        svelte-language-server
        tailwindcss-language-server
        taplo
        yamlfmt
        yaml-language-server
      ];
      initLua = builtins.readFile ./nvim/init.lua;
      viAlias = true;
      vimAlias = true;
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--glob=!.angular/*"
        "--glob=!.database/*"
        "--glob=!.db/*"
        "--glob=!.firebase/*"
        "--glob=!.git/*"
        "--glob=!dist/*"
        "--glob=!node_modules/*"
        "--glob=!target/*"
        "--glob=!*.min.css"
        "--glob=!*.min.js"
      ];
    };
    zoxide.enable = true;
  };
}
