{
  config,
  lib,
  pkgs,
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
  pkgs2511 =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-25.11.tar.gz";
        sha256 = "0ln4yw7z3g9lb0x081hc0pd2j1wsx2qqf6bgmwwvdbkcl4bcy1dp";
      })
      {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
  # Neovim stable from nixpkgs 25.11, including its compatible tree-sitter dependency set.
  neovimStable = pkgs2511.neovim-unwrapped;
  # vscode-langservers-extracted pinned to the last commit before nixpkgs rewrote it to
  # "extract directly from vscodium" (5611e17, 2026-06-23). That rewrite ships 1.106.27818,
  # whose json/css server entrypoints require missing webpack chunks (962/920) → jsonls/cssls
  # crash on startup. This parent commit provides the working 4.10.0 build.
  langserversFixed =
    (import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/ff77533172372be5d4b8566100c73e96d9c57a50.tar.gz";
        sha256 = "1h6mapfkwndizayx9a36vymkaddarksrwfhjxk5rvhp7lxw9jk4a";
      })
      {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      }
    ).vscode-langservers-extracted;
  # Bun only for x86_64-linux
  # https://github.com/oven-sh/bun/releases
  bunLatest = pkgs.bun.overrideAttrs (old: rec {
    pname = "bun";
    version = "1.3.14";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "13w4gvgwrjq9bi3ddp53hgm3z399d8i2aqpcmsaqbw2mx2pf47lm";
    };
  });
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
    version = "576.0.0";
    src = pkgs.fetchurl {
      url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${version}-linux-x86_64.tar.gz";
      sha256 = "1gjf2yg1h1z0rwnl87lv6lgav5k3v9fxk6hlzd5yjg8agrl5qr2c";
    };
    installCheckPhase = ''
      echo "Skip installCheckPhase"
    '';
  });
  # Go only for Linux x86_64
  # https://go.dev/dl
  goLatest = pkgs.go.overrideAttrs (old: rec {
    pname = "go";
    version = "1.26.5";
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      sha256 = "0hnwn9v6kk2cfqgd8jbv7p9nd16rmcb42nrf75kwashphyyf8ns9";
    };
  });
  # Nodejs only for x86_64-linux
  # https://nodejs.org/en/download/prebuilt-binaries
  nodejsLatestLts = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "24.18.0";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "0hk7lw7lak3yh41ig21nibww1da5d6pdbnpwcpbji3yqz59p3ajm";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xJf $src --strip-components=1 -C $out
      mv $out/LICENSE $out/share/doc/LICENSE_nodejs
    '';
  };
  prettierWithAstro = pkgs.writeShellScriptBin "prettier-with-astro" ''
    shopt -s nullglob
    plugins=(${pkgs.astro-language-server}/lib/node_modules/astro-language-server/node_modules/.pnpm/prettier-plugin-astro@*/node_modules/prettier-plugin-astro/dist/index.js)
    if [ ''${#plugins[@]} -eq 0 ]; then
      echo "prettier-plugin-astro not found in astro-language-server package" >&2
      exit 1
    fi
    exec ${pkgs.prettier}/bin/prettier --plugin "''${plugins[0]}" "$@"
  '';
  # Rofi Arc-Dark theme
  rofiTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi/refs/heads/next/themes/Arc-Dark.rasi";
    sha256 = "1kqv5hbdq9w8sf0fx96knfhmzb8avh6yzp28jaizh77hpsmgdx9s";
  };
  # RTK (Rust Token Killer) only for x86_64-linux
  # https://github.com/rtk-ai/rtk/releases
  rtkLatest = pkgs.stdenv.mkDerivation rec {
    pname = "rtk";
    version = "0.43.0";
    src = pkgs.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "02d6lbz7ig0z7n4yal9yydnzzjcpvjhyqnm8j591fvj9crvix2pz";
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
    version = "3.7b";
    src = pkgs.fetchurl {
      url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
      sha256 = "15nv6bavcw2nl7jsm780yx25f6p5sxpgsbq0rbr76nb87fgfkwl7";
    };
    patches = [ ];
  });
  pathHome = builtins.getEnv "HOME";
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
      # # D
      duf
      # # E
      exiftool
      # # F
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
      minify
      mysql84
      # # N
      nix-prefetch-git
      nodejsLatestLts
      # # O
      onefetch
      # # P
      packer
      php
      pnpm
      podman-compose
      postgresql
      prettier
      pyright
      python313Packages.huggingface-hub
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
        offset = 0x0
        separator_height = 0
        frame_width = 0
        sort = update
        [urgency_low]
        background = "#ffffff"
        foreground = "#000000"
        [urgency_normal]
        background = "#526596"
        [urgency_critical]
        background = "#ff4d4f"
        [ignore]
        appname=spotify
        skip_display = true
        [skip-display]
        appname=spotify
        skip_display = yes
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
        }
        ${builtins.readFile rofiTheme}
        window {
          width: 40%;
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
            swaymsg exit
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
  targets.genericLinux.nixGL.packages = import <nixgl> { inherit pkgs; };
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
        # Check if the current directory is a git repository
        set -l arrow ">>"
        set -l git_rev
        set -l git_branch
        if test -d .git
          set git_rev (set_color cyan)(git rev-parse --short HEAD 2>/dev/null)
          set git_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)(set_color normal)
        end
        if test -n "$git_branch" && test -n "$git_rev"
          set -l git_status (git status --porcelain 2>/dev/null)
          if test -n "$git_status"
            set -l indicator (set_color yellow)"!"(set_color normal)
            string join "" -- (set_color normal) "" (prompt_pwd) $stat " $git_rev:$git_branch " "$indicator $arrow "
          else
            string join "" -- (set_color normal) "" (prompt_pwd) $stat " $git_rev:$git_branch" " $arrow "
          end
        else
          if test -d .git
            string join "" -- (set_color normal) "" (prompt_pwd) $stat (set_color cyan)" git?"(set_color normal) " $arrow "
          else
            string join "" -- (set_color normal) "" (prompt_pwd) $stat " $arrow "
          end
        end
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
    alacritty = {
      enable = true;
      settings = {
        env = {
          TERM = "alacritty";
        };
        terminal.shell = {
          program = "${config.home.profileDirectory}/bin/fish";
        };
        general.live_config_reload = false;
        font = {
          normal = {
            family = "FiraCode Nerd Font";
            style = "Regular";
          };
          size = 16;
        };
        colors = {
          primary.foreground = "#ffffff";
          primary.background = "#0c0c0c";
          selection = {
            text = "#ffffff";
            background = "#264f78";
          };
          normal.red = "#ff4d4f";
          normal.blue = "#096dd9";
          normal.green = "#52c41a";
          normal.yellow = "#faad14";
          normal.black = "#0c0c0c";
          normal.white = "#ffffff";
          normal.cyan = "#08979c";
          normal.magenta = "#c41d7f";
        };
        cursor = {
          style = {
            shape = "Beam";
            blinking = "Always";
          };
          vi_mode_style = {
            shape = "Beam";
            blinking = "Always";
          };
          blink_interval = 200;
          blink_timeout = 0;
        };
        keyboard.bindings = [
          {
            key = "Return";
            mods = "Shift";
            chars = "\n";
          }
        ];
        window = {
          decorations = "None";
          decorations_theme_variant = "Dark";
          dynamic_padding = true;
          opacity = 0.95;
          startup_mode = "Maximized";
        };
        selection.save_to_clipboard = true;
      };
      package = config.lib.nixGL.wrap pkgs.alacritty;
    };
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
        color_theme = "adwaita-dark";
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
          source = "${pathHome}/.personal.txt";
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
            text = "echo \"$(alacritty -V) + $(tmux -V)\"";
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
    go = {
      enable = true;
      package = goLatest;
      telemetry.mode = "off";
      env.GOPATH = "${pathHome}/.go";
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
        beautysh
        black
        prettierWithAstro
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
        stylua
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
