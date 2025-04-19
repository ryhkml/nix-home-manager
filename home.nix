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
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = "HEAD";
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        rev = rev;
      };
    };
  # Angular CLI
  # https://www.npmjs.com/package/@angular/cli
  angularCli = pkgs.stdenv.mkDerivation rec {
    pname = "static-angular-cli";
    version = "19.2.5";
    src = builtins.fetchGit {
      url = "https://github.com/ryhkml/static-angular-cli.git";
      rev = "4ba7ff1afc1f5a307ec1e521da421bc3c1b738fb";
    };
    buildPhase = ''
      mkdir -p $out/bin
      ln -s ${src}/node_modules/@angular/cli/bin/ng.js $out/bin/ng
      chmod +x $out/bin/ng
    '';
    installPhase = ''
      mkdir -p $out/lib/node_modules
      cp -r ${src}/node_modules $out/lib/
    '';
  };
  # https://www.npmjs.com/package/@angular/language-server
  angularLanguageServer = builtins.fetchGit {
    url = "https://github.com/ryhkml/static-angular-language-server.git";
    rev = "0feeda4b6b6a1bde118d8b4be0f08c48097aa73e";
  };
  # Bun only for x86_64-linux
  # https://github.com/oven-sh/bun/releases
  bunBin = pkgs.stdenv.mkDerivation rec {
    pname = "bun";
    version = "1.2.10";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "0vn36ifaw3qmhx2kvylsnw5ghzh2gwcwaz58s6s52s793gzm98b8";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    phases = [
      "unpackPhase"
      "installPhase"
    ];
    unpackPhase = ''
      mkdir $out
      unzip $src -d $out
    '';
    installPhase = ''
      mkdir -p $out/bin
      mv $out/bun-linux-x64/bun $out/bin/bun
      chmod +x $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
    '';
  };
  # Firebase CLI only for linux
  # https://github.com/firebase/firebase-tools/releases
  firebaseToolsCli = pkgs.stdenv.mkDerivation rec {
    pname = "firebase-tools";
    version = "14.1.0";
    src = pkgs.fetchurl {
      url = "https://github.com/firebase/firebase-tools/releases/download/v${version}/firebase-tools-linux";
      sha256 = "0809xw6582nzfs9d5vy4pix0hdxrl1zm4l838m4qwsf5127s0nfp";
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
  gcloudCli = pkgs.stdenv.mkDerivation rec {
    pname = "google-cloud-sdk";
    version = "517.0.0";
    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-${version}-linux-x86_64.tar.gz";
      sha256 = "0i3ky92ciy37xxiz9k7n7wfhi66wa380ykk0kpya9ww427wlfh95";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xzf $src --strip-components=1 -C $out
      # Prevent collision between 2 LICENSE
      mv $out/LICENSE $out/share/doc/LICENSE-google-cloud-sdk
    '';
  };
  # LM Studio AI for Linux
  # https://lmstudio.ai
  lmStudio = pkgs.stdenv.mkDerivation rec {
    pname = "lmstudio";
    version = "0.3.14";
    src = pkgs.fetchurl {
      url = "https://installers.lmstudio.ai/linux/x64/${version}-5/LM-Studio-${version}-5-x64.AppImage";
      sha256 = "1f31adym8m255crh76gcggm2j99znvld9valacsg1mzwxkjvvcss";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/LM-Studio.AppImage
      chmod +x $out/bin/LM-Studio.AppImage
    '';
  };
  # Nodejs only for x86_64-linux
  # https://nodejs.org/en/download/prebuilt-binaries
  nodejsBin = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "22.14.0";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "1v1p0kl4kcn55gdfy9rrzvman18hvd046fi7wk20bjwdbjx9vc39";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xJf $src --strip-components=1 -C $out
      # Prevent collision between 2 LICENSE
      mv $out/LICENSE $out/share/doc/LICENSE-nodejs
    '';
  };
  # Rofi
  rofiTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi/refs/heads/next/themes/Arc-Dark.rasi";
    sha256 = "1kqv5hbdq9w8sf0fx96knfhmzb8avh6yzp28jaizh77hpsmgdx9s";
  };
  # R
  rWrapper = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      ggplot2
      languageserver
      readr
      styler
    ];
  };
  pathHome = builtins.getEnv "HOME";
in
{
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "ryhkml";
    homeDirectory = "/home/ryhkml";
    stateVersion = "24.05";
    packages = with pkgs; [
      # # A
      act
      angularCli
      asciiquarium-transparent
      # # C
      cmus
      (curl.override {
        c-aresSupport = true;
        gsaslSupport = true;
      })
      # # D
      duf
      # # E
      exiftool
      # # F
      file
      firebaseToolsCli
      # # G
      gnuplot
      gcloudCli
      # # H
      hey
      hyperfine
      # # I
      id3v2
      # # L
      lazydocker
      lua
      # # M
      minify
      # # N
      nix-prefetch-git
      nodejsBin
      noisetorch # This package is mind blowing!
      # # P
      pnpm
      podman-compose
      # # R
      rlwrap
      rustup
      rWrapper
      # # S
      sqlite
      # # T
      tokei
      trash-cli
      typescript
      # # Y
      yt-dlp
      # # Z
      zig
    ];
    file = {
      ".angular-config.json".text = builtins.toJSON {
        "$schema" = "${angularCli}/lib/node_modules/@angular/cli/lib/config/schema.json";
        version = 1;
        cli = {
          completion.prompted = true;
          analytics = false;
        };
        projects = { };
      };
      ".bunfig.toml".text = ''
        mosl = true
        telemetry = false
        [install.cache]
        disable = true
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
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
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
        font=FiraCode Nerd Font:size=15
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
      '';
      ".config/zellij/config.kdl".text = ''
        ui {
          pane_frames {
            rounded_corners false
          }
        }
        keybinds {
          unbind "Ctrl b" "Ctrl o" "Ctrl q"
          normal {
            bind "Ctrl a" { SwitchToMode "Tmux"; }
          }
        }
        themes {
          default {
            fg "#ffffff"
            bg "#000000"
            black "#000000"
            red "#ff4d4f"
            green "#526596"
            blue "#096dd9"
            yellow "#faad14"
            magenta "#965252"
            cyan "#08979c"
            white "#ffffff"
            orange "#965287"
          }
        }
        default_shell "${config.home.profileDirectory}/bin/fish"
        layout_dir "${pathHome}/.config/zellij/layouts"
      '';
      ".config/zellij/layouts/default.kdl".text = ''
        layout {
          cwd "${pathHome}"
          tab name="Sysinfo" hide_floating_panes=true {
            pane command="btop" name="Monitor resource" {}
            pane size=1 borderless=true {
              plugin location="zellij:tab-bar"
            }
          }
          tab name="Editor" hide_floating_panes=true {
            pane name="Compose" {}
            pane size=1 borderless=true {
              plugin location="zellij:tab-bar"
            }
          }
          tab name="Debug" hide_floating_panes=true {
            pane name="Test" {}
            pane size=1 borderless=true {
              plugin location="zellij:tab-bar"
            }
          }
          new_tab_template {
            pane
            pane size=1 borderless=true {
              plugin location="zellij:tab-bar"
            }
          }
        }
      '';
      ".scripts/waybar/custom-clock.sh".text = ''
        set -e
        current_date=$(date +'%A - %B %-d, %Y')
        current_time=$(date +'%-l:%M:%S')
        echo -n "{\"text\": \"$current_time\", \"tooltip\": \"$current_date\"}"
      '';
      ".scripts/rofi/power.sh".text = ''
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
    };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  xdg.desktopEntries.lmstudio = {
    name = "LM Studio";
    comment = "Discover, download, and run local LLMs";
    exec = "${lmStudio}/bin/LM-Studio.AppImage";
    type = "Application";
    categories = [
      "Utility"
      "Development"
    ];
    terminal = false;
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
  nixGL.packages = import <nixgl> { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

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
      # Update library
      cmusup = "cmus-remote -C clear; cmus-remote -C \"add ~/Music\"; cmus-remote -C \"update-cache -f\"";
      # Greatest abbreviations downloader ever
      dlmp3 = "yt-dlp --embed-thumbnail -o \"%(channel)s - %(title)s.%(ext)s\" -f bestaudio -x --audio-format mp3 --audio-quality 320 ?";
      dlmp4 = "yt-dlp --embed-thumbnail -S res,ext:mp4:m4a --recode mp4 ?";
      # Git
      gitpt = "set -l TAG_NAME (jq .version package.json -r); set -l TIMESTAMP (date +'%Y/%m/%d'); git tag -s $TAG_NAME -m \"$TIMESTAMP\"; git push origin --tag";
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
      nmdnsv4-cloudflare = "nmcli connection modify $NETWORK_NAME ipv4.dns \"1.1.1.1,1.0.0.1\"; nmcli connection modify $NETWORK_NAME ipv4.ignore-auto-dns yes";
      nmdnsv6-cloudflare = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2606:4700:4700::1111,2606:4700:4700::1001\"; nmcli connection modify $NETWORK_NAME ipv6.ignore-auto-dns yes";
      v = "nvim";
      # Greatest abbreviations ever
      fv = "fd -H -I -E .angular -E .git -E dist -E node_modules -E target | fzf --reverse | xargs -r nvim";
      # Zellij
      zla = "zellij a ?";
      zld = "zellij d ?";
      zls = "zellij ls";
      zlda = "zellij da -y";
      zl = "zellij -s Main";
    };
    shellAliases = {
      docker = "podman";
      la = "eza -ahlT --color never -L 1 --time-style relative";
      lg = "eza -hlT --git --color never -L 1 --time-style relative";
      ll = "eza -hlT --color never -L 1 --time-style relative";
      ls = "eza -hT --color never -L 1";
      # Safety rm
      rm = "trash-put";
      tree = "eza -T --color never";
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
            string join "" -- (set_color normal) "\$ " (prompt_pwd) $stat " $git_rev:$git_branch " "$indicator> "
          else
            string join "" -- (set_color normal) "\$ " (prompt_pwd) $stat " $git_rev:$git_branch" " > "
          end
        else
          if test -d .git
            string join "" -- (set_color normal) "\$ " (prompt_pwd) $stat (set_color cyan)" git?"(set_color normal) " > "
          else
            string join "" -- (set_color normal) "\$ " (prompt_pwd) $stat " > "
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
        terminal.shell = {
          program = "${config.home.profileDirectory}/bin/fish";
        };
        general.live_config_reload = false;
        font = {
          normal = {
            family = "FiraCode Nerd Font";
            style = "Regular";
          };
          size = 15;
        };
        colors = {
          primary.foreground = "#ffffff";
          primary.background = "#000000";
          normal.red = "#ff4d4f";
          normal.blue = "#096dd9";
          normal.green = "#52c41a";
          normal.yellow = "#faad14";
          normal.black = "#000000";
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
          blink_interval = 400;
          blink_timeout = 0;
        };
        mouse.hide_when_typing = true;
        window = {
          decorations = "None";
          decorations_theme_variant = "Dark";
          padding = {
            x = 12;
            y = 6;
          };
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
        show_battery = false;
        temp_scale = "celsius";
        update_ms = 1000;
        clock_format = "";
        rounded_corners = false;
        log_level = "WARNING";
      };
    };
    bun = {
      enable = true;
      package = bunBin;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "small";
          color = {
            "1" = "white";
          };
        };
        display = {
          color = "white";
        };
        modules = [
          "title"
          "separator"
          "os"
          {
            type = "host";
            format = "{?2}{2}{?}{?5} ({5}){?}";
          }
          "kernel"
          {
            type = "wm";
            key = "Window Manager";
          }
          {
            type = "de";
            key = "Desktop Environment";
          }
          "break"
          "chassis"
          "cpu"
          "gpu"
          "memory"
          "swap"
          "disk"
          "break"
          "shell"
          "packages"
          "terminal"
          "break"
          "uptime"
          {
            type = "display";
            key = "Resolution";
          }
          "locale"
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
      ];
      extraOptions = [
        "-tf"
        "--no-require-git"
      ];
    };
    fzf.enable = true;
    go = {
      enable = true;
      goPath = ".go";
    };
    java.enable = true;
    jq.enable = true;
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
      plugins = with pkgs.vimPlugins; [
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            -- https://github.com/lewis6991/gitsigns.nvim
            require("gitsigns").setup({
              signs = {
                add          = { text = "A" },
                change       = { text = "C" },
                delete       = { text = "D" },
                topdelete    = { text = "TD" },
                changedelete = { text = "CD" },
                untracked    = { text = "U" },
              },
              signs_staged = {
                add          = { text = "SA" },
                change       = { text = "SC" },
                delete       = { text = "SD" },
                topdelete    = { text = "S-" },
                changedelete = { text = "S~" },
                untracked    = { text = "SU" },
              },
            })
          '';
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            -- https://github.com/lukas-reineke/indent-blankline.nvim
            require("ibl").setup{
              debounce = 100,
              indent = {
                char = { "" },
              },
              scope = {
                enabled = false,
              },
            }
            local iblhooks = require "ibl.hooks"
            iblhooks.register(
              iblhooks.type.WHITESPACE,
              iblhooks.builtin.hide_first_space_indent_level
            )
            iblhooks.register(
              iblhooks.type.WHITESPACE,
              iblhooks.builtin.hide_first_tab_indent_level
            )
          '';
        }
        lsp-zero-nvim
        nvim-lspconfig
        nvim-cmp
        # https://github.com/b0o/SchemaStore.nvim
        SchemaStore-nvim
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            -- https://github.com/VonHeikemen/lsp-zero.nvim
            local lspconfig_defaults = require("lspconfig").util.default_config
            lspconfig_defaults.capabilities = vim.tbl_deep_extend(
              "force",
              lspconfig_defaults.capabilities,
              require("cmp_nvim_lsp").default_capabilities()
            )
            vim.api.nvim_create_autocmd("LspAttach", {
              desc = "LSP actions",
              callback = function(event)
                local opts = { buffer = event.buf, silent = true }
                vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                vim.keymap.set({"n", "x"}, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
                vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
              end,
            })
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
            -- Angular
            local ngcmd = {
              "${angularLanguageServer}/node_modules/.bin/ngserver",
              "--stdio",
              "--tsProbeLocations",
              "${angularLanguageServer}/node_modules",
              "--ngProbeLocations",
              "${angularLanguageServer}/node_modules",
            }
            local lspconfig = require("lspconfig")
            lspconfig.angularls.setup{
              cmd = ngcmd,
              on_new_config = function(new_config, new_root_dir)
                new_config.cmd = ngcmd
              end,
            }
            -- Bash
            lspconfig.bashls.setup{}
            -- C
            lspconfig.clangd.setup{}
            -- cmake
            lspconfig.cmake.setup{}
            -- CSS
            lspconfig.cssls.setup{}
            -- Dockerfile
            lspconfig.dockerls.setup{}
            -- HTML
            lspconfig.html.setup{}
            -- Go
            lspconfig.gopls.setup{}
            -- Java
            lspconfig.jdtls.setup{}
            -- JSON
            lspconfig.jsonls.setup{
              settings = {
                json = {
                  schemas = require("schemastore").json.schemas {
                    select = {
                      "cloudbuild.json",
                      "Firebase",
                      "Google Cloud Workflows",
                      "openapi.json",
                      "package.json",
                      "tsconfig.json"
                    }
                  },
                  validate = {
                    enable = true
                  }
                }
              }
            }
            -- Nginx
            lspconfig.nginx_language_server.setup{}
            -- Nix
            lspconfig.nil_ls.setup{}
            -- R
            lspconfig.r_language_server.setup{}
            -- Rust
            lspconfig.rust_analyzer.setup{}
            -- Typescript
            lspconfig.ts_ls.setup{}
            -- YAML
            lspconfig.yamlls.setup{
              settings = {
                yaml = {
                  validate = true,
                  schemas = {
                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose.{yaml,yml}",
                  },
                },
              }
            }
            -- Zig
            lspconfig.zls.setup{}
          '';
        }
        vim-vsnip
        cmp-vsnip
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            -- https://github.com/hrsh7th/nvim-cmp
            local cmp = require("cmp")
            cmp.setup({
              snippet = {
                expand = function(args)
                  vim.snippet.expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "vsnip" },
              }, {
                { name = "buffer" },
              })
            })
          '';
        }
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-live-grep-args-nvim
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            -- https://github.com/nvim-telescope/telescope.nvim
            require("telescope").setup{
              defaults = {
                file_ignore_patterns = {
                  "^.angular/",
                  "^.database/",
                  "^.db/",
                  "^.firebase/",
                  "^.git/",
                  "^dist/",
                  "^node_modules/",
                  "^target/"
                },
                vimgrep_arguments = {
                  "rg",
                  "--color=never",
                  "--no-heading",
                  "--line-number",
                  "--column",
                  "--smart-case",
                  "--hidden",
                  "--no-ignore-files",
                  "--no-require-git"
                }
              },
              pickers = {
                find_files = {
                  hidden = true,
                  no_ignore = true,
                  disable_devicons = true,
                  file_ignore_patterns = {
                    "^.angular/",
                    "^.database/",
                    "^.db/",
                    "^.firebase/",
                    "^.git/",
                    "^dist/",
                    "^node_modules/",
                    "^target/"
                  },
                  find_command = {
                    "fd",
                    ".",
                    "-tf",
                    "--hidden",
                    "--strip-cwd-prefix",
                    "--no-require-git"
                  }
                },
              },
              extensions = {
                fzf = {
                  fuzzy = true,
                  case_mode = "smart_case",
                  override_file_sorter = true,
                  override_generic_sorter = true,
                },
                live_grep_args = {
                  auto_quoting = true,
                }
              }
            }
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files)
            vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
            vim.keymap.set("n", "<leader>fb", builtin.buffers)
            vim.keymap.set("n", "<leader>fh", builtin.help_tags)
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("live_grep_args")
          '';
        }
        {
          plugin = harpoon2;
          type = "lua";
          config = ''
            -- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
            local harpoon = require("harpoon")
            harpoon:setup({
              settings = {
                save_on_toggle = false,
                sync_on_ui_close = true,
              }
            })
            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<A-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
            vim.keymap.set("n", "<A-1>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<A-2>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<A-3>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<A-4>", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<A-5>", function() harpoon:list():select(5) end)
            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
          '';
        }
        {
          plugin = nvim-treesitter;
          type = "lua";
          config = ''
            -- https://github.com/nvim-treesitter/nvim-treesitter
            local dir_parser = os.getenv("HOME") .. "/.vim/parsers"
            vim.opt.runtimepath:append(dir_parser)
            require("nvim-treesitter.configs").setup{
              ensure_installed = {
                "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "comment",
                "angular", "bash", "c", "cmake", "make", "css", "dockerfile", "hcl", "html", "http", "java", "javascript",
                "kdl", "nginx", "nix", "scss", "sql", "sway", "pem", "r", "rust", "toml", "typescript", "yaml", "xml", "zig", "ziggy",
                "diff", "gitattributes", "gitcommit", "gitignore", "git_config"
              },
              sync_install = false,
              auto_install = true,
              parser_install_dir = dir_parser,
              highlight = {
                enable = true,
                disable = function(lang, buf)
                  if lang == "html" or lang == "css" or lang == "js" then
                    local max_size = 256 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_size then
                      return true
                    end
                  end
                  return false
                end,
                additional_vim_regex_highlighting = false,
              },
              indent = {
                enable = true
              }
            }
          '';
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = ''
            -- https://github.com/windwp/nvim-autopairs
            require("nvim-autopairs").setup()
          '';
        }
        vim-visual-multi
        {
          plugin = myVimPlugin "slugbyte/lackluster.nvim" "6d206a3af7dd2e8389eecebab858e7d97813fc0c";
          type = "lua";
          config = ''
            -- https://github.com/slugbyte/lackluster.nvim
            local lackluster = require("lackluster")
            lackluster.setup({
              tweak_color = {
                lack = "default",
                luster = "default",
                orange = "#d46b08",
                yellow = "#d4b106",
                green = "#389e0d",
                blue = "#096dd9",
                red = "#cf1322",
              },
              tweak_background = {
                normal = "#000000",
                popup = "#000000",
                menu = "#000000",
                telescope = "#000000",
              }
            })
            vim.cmd.colorscheme("lackluster-hack")
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            local function SearchResultCount()
              if vim.v.hlsearch == 0 then
                return ""
              end
              local last = vim.fn.getreg("/")
              if not last or last == "" then
                return ""
              end
              local searchcount = vim.fn.searchcount { maxcount = 9000 }
              return "" .. searchcount.current .. "/" .. searchcount.total .. ""
            end
            require("lualine").setup({
              options = {
                icons_enabled = false,
                theme = "lackluster",
                globalstatus = true,
                component_separators = "",
                section_separators = "",
              },
              sections = {
                lualine_x = {
                  SearchResultCount,
                  "encoding",
                  "filetype"
                },
              },
            })
          '';
        }
        {
          plugin = nvim-colorizer-lua;
          type = "lua";
          config = ''
            -- https://github.com/nvchad/nvim-colorizer.lua
            require("colorizer").setup {
              filetypes = {
                "*",
                html = {
                  mode = "foreground",
                },
              },
              user_default_options = {
                RGB = true,
                RRGGBB = true,
                names = false,
                RRGGBBAA = true,
                AARRGGBB = true,
                rgb_fn = false,
                hsl_fn = false,
                css = false,
                css_fn = false,
                mode = "background",
                tailwind = false,
                sass = { enable = false, parsers = { "css" }, },
                virtualtext = "^",
                always_update = false
              },
              buftypes = {},
            }
          '';
        }
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
            -- https://github.com/numToStr/Comment.nvim
            require("Comment").setup()
          '';
        }
        {
          plugin = treesj;
          type = "lua";
          config = ''
            -- https://github.com/Wansmer/treesj
            require("treesj").setup({})
          '';
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = ''
            -- https://github.com/kylechui/nvim-surround
            require("nvim-surround").setup({
              surrounds = {
                ["("] = false,
                ["["] = false,
                ["{"] = false,
              },
              aliases = {
                ["("] = ")",
                ["["] = "]",
                ["{"] = "}",
              }
            })
          '';
        }
        {
          plugin = lsp_lines-nvim;
          type = "lua";
          config = ''
            -- https://github.com/maan2003/lsp_lines.nvim
            vim.diagnostic.config({
              virtual_text = false,
            })
            require("lsp_lines").setup()
          '';
        }
        {
          plugin = conform-nvim;
          type = "lua";
          config = ''
            -- https://github.com/stevearc/conform.nvim
            require("conform").setup({
              formatters_by_ft = {
                c = { "clang-format" },
                css = { "prettier" },
                fish = { "fish_indent" },
                html = { "prettier" },
                go = { "gofmt" },
                java = { "astyle" },
                javascript = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                less = { "prettier" },
                lua = { "stylua" },
                markdown = { "prettier" },
                nix = { "nixfmt" },
                r = { "styler" },
                rust = { "rustfmt" },
                scss = { "prettier" },
                sh = { "beautysh" },
                typescript = { "prettier" },
                yaml = { "yamlfmt" },
                -- I don't know why this works
                zig = { "zig fmt" },
                ["_"] = { "trim_whitespace" },
              },
              default_format_opts = {
                lsp_format = "fallback",
              },
              format_on_save = {
                lsp_format = "fallback",
                timeout_ms = 1000,
              },
              log_level = vim.log.levels.ERROR,
              notify_on_error = true,
              notify_no_formatters = true,
            })
            require("conform").formatters.astyle = {
              prepend_args = { "--style=java", "-t4", "--add-braces" },
            }
            require("conform").formatters.beautysh = {
              prepend_args = { "--indent-size", "4", "--tab" },
            }
            require("conform").formatters.nixfmt = {
              prepend_args = { "--width=128" },
            }
            require("conform").formatters.prettier = {
              prepend_args = function(self, ctx)
                if ctx.filename:match("%.md$") then
                  return { "--print-width", "128", "--tab-width", "4", "--trailing-comma", "none" }
                else
                  return { "--print-width", "128", "--use-tabs", "--tab-width", "4", "--trailing-comma", "none" }
                end
              end,
            }
            require("conform").formatters.injected = {
              options = {
                -- The default edition of Rust to use when no Cargo.toml file is found
                default_edition = "2021",
                -- Prettier
                ft_parsers = {
                  markdown = "markdown",
                  ["markdown.mdx"] = "mdx",
                },
              }
            }
          '';
        }
        {
          plugin = markdown-preview-nvim;
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
          plugin = myVimPlugin "VonHeikemen/fine-cmdline.nvim" "aec9efebf6f4606a5204d49ffa3ce2eeb7e08a3e";
          type = "lua";
          config = ''
            -- https://github.com/VonHeikemen/fine-cmdline.nvim
            require("fine-cmdline").setup({
              popup = {
                position = "50%",
                size = {
                  width = "25%",
                },
                border = {
                  style = "single",
                  text = {
                    top = " Cmd ",
                    top_align = "center",
                  },
                  padding = "0",
                },
                win_options = {
                  winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
              },
            })
          '';
        }
        {
          plugin = searchbox-nvim;
          type = "lua";
          config = ''
            require("searchbox").setup({
              popup = {
                position = "50%",
                size = "25%",
                border = {
                  style = "single",
                  text = {
                    top = " Search ",
                    top_align = "center",
                  },
                  padding = "0",
                },
                win_options = {
                  winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
              },
            })
          '';
        }
        # Explorer
        {
          plugin = nvim-web-devicons;
          optional = true;
        }
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = ''
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            require("nvim-tree").setup({
              sync_root_with_cwd = true,
              view = {
                signcolumn = "no",
                width = 30,
              },
              renderer = {
                group_empty = true,
                indent_markers = {
                  enable = true,
                },
                icons = {
                  web_devicons = {
                    file = {
                      enable = false,
                      color = false
                    },
                  },
                  git_placement = "after",
                  symlink_arrow = " -> ",
                  show = {
                    file = false,
                  },
                  glyphs = {
                    git = {
                      unstaged = "US",
                      staged = "S",
                      unmerged = "UM",
                      renamed = "R",
                      untracked = "UT",
                      deleted = "D",
                      ignored = "i",
                    }
                  }
                },
                symlink_destination = false,
              },
              filters = {
                custom = { ".angular", ".git" },
                exclude = { ".github", ".gitignore", ".gitattributes" }
              },
              filesystem_watchers = {
                enable = true,
                debounce_delay = 100,
                ignore_dirs = {
                  "/.angular",
                  "/.ccls-cache",
                  "/build",
                  "/dist",
                  "/node_modules",
                  "/target",
                },
              },
              update_focused_file = {
                enable = true,
              },
              git = {
                enable = false,
              }
            })
          '';
        }
        # Tab
        {
          plugin = tabby-nvim;
          type = "lua";
          config = ''
            local theme = {
              fill = "TabLineFill",
              head = "TabLine",
              current_tab = { fg = "#ffffff", bg = "#526596" },
              tab = "TabLine",
              win = "TabLine",
              tail = "TabLine",
            }
            local function PlainTabName(name)
              return name:gsub("%[%d+%+%]", "")
            end
            require("tabby").setup({
              line = function(line)
                return {
                  {
                    { " N ", hl = theme.head },
                    line.sep("", theme.head, theme.fill),
                  },
                  line.tabs().foreach(function(tab)
                    local hl = tab.is_current() and theme.current_tab or theme.tab
                    return {
                      line.sep("", hl, theme.fill),
                      PlainTabName(tab.name()),
                      line.sep("", hl, theme.fill),
                      hl = hl,
                      margin = " ",
                    }
                  end),
                  line.spacer(),
                  {
                    line.sep("", theme.tail, theme.fill),
                    { " OK ", hl = theme.tail },
                  },
                  hl = theme.fill,
                }
              end,
              option = {
                nerdfont = true,
                lualine_theme = "lackluster"
              }
            })
          '';
        }
        vim-wakatime
      ];
      extraPackages = with pkgs; [
        # LSP and Fmt
        astyle
        bash-language-server
        beautysh
        dockerfile-language-server-nodejs
        jdt-language-server
        gopls
        nginx-language-server
        nil
        nixfmt-rfc-style
        nodePackages.prettier
        rust-analyzer
        rustfmt
        shellcheck
        stylua
        typescript-language-server
        vscode-langservers-extracted
        yamlfmt
        yaml-language-server
        zls
      ];
      extraLuaConfig = ''
        vim.scriptencoding = "utf-8"
        vim.opt.encoding = "utf-8"
        vim.opt.fileencoding = "utf-8"
        vim.opt.clipboard = "unnamedplus"
        vim.opt.wildignore:append({
          "*/node_modules/*",
          "*/target/*",
          "*/dist/*",
          "*/.angular/*",
          "*/.git/*",
        })
        -- Filetype
        local function set_filetype_c()
          vim.bo.filetype = "c"
        end
        local function set_filetype_conf()
          vim.bo.filetype = "conf"
        end
        local function set_filetype_dotenv()
          vim.bo.filetype = "dotenv"
        end
        vim.api.nvim_create_augroup("FiletypeConfig", { clear = true })
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = { "*.h" },
          callback = set_filetype_c,
          group = "FiletypeConfig",
        })
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = { "*/config", "*/conf" },
          callback = set_filetype_conf,
          group = "FiletypeConfig",
        })
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = { "*/.env*" },
          callback = set_filetype_dotenv,
          group = "FiletypeConfig",
        })
        -- Number
        vim.opt.nu = true
        vim.opt.cursorline = true
        vim.opt.relativenumber = true
        -- Tab indent
        vim.opt.tabstop = 4
        vim.opt.softtabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true
        --
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "yaml", "nix" },
          callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.shiftwidth = 2
          end,
        })
        vim.api.nvim_create_autocmd("BufReadPost", {
          pattern = "flake.lock",
          callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.shiftwidth = 2
          end,
        })
        vim.opt.smartindent = true
        vim.opt.showmode = false
        vim.opt.wrap = false
        vim.opt.backup = false
        vim.opt.swapfile = false
        vim.opt.hlsearch = true
        vim.opt.incsearch = true
        vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
        vim.opt.undofile = true
        vim.opt.signcolumn = "yes"
        vim.opt.updatetime = 250
        vim.opt.cmdheight = 0
        vim.opt.showcmd = false
        --
        local options = { noremap = true, silent = true }
        vim.g.mapleader = " "
        -- Noop
        vim.keymap.set("n", "q", "<Nop>", options)
        vim.keymap.set("v", "q", "<Nop>", options)
        vim.keymap.set("n", "Q", "<Nop>", options)
        -- Hlsearch
        vim.keymap.set("n", "<leader>n", ":noh<CR>", options)
        vim.keymap.set({ "n", "v" }, "<leader>h", "^", options)
        vim.keymap.set({ "n", "v" }, "<leader>l", "$", options)
        -- Explorer
        vim.keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>", options)
        vim.keymap.set("n", "<leader>ef", ":NvimTreeFocus<CR>", options)
        vim.keymap.set("n", "<leader>ec", ":NvimTreeCollapse<CR>", options)
        vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", options)
        -- Yank/Paste/Change/Delete
        vim.keymap.set("x", "<leader>p", [["_dP]])
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
        vim.keymap.set("n", "<leader>Y", [["+Y]])
        -- d
        vim.keymap.set("n", "d", '"_d', { noremap = true })
        vim.keymap.set("n", "dd", '"_dd', { noremap = true })
        vim.keymap.set("n", "D", '"_D', { noremap = true })
        vim.keymap.set("x", "d", '"_d', { noremap = true })
        vim.keymap.set("n", "da", '"_da', { noremap = true })
        vim.keymap.set("n", "di", '"_di', { noremap = true })
        vim.keymap.set("n", "dw", '"_dw', { noremap = true })
        vim.keymap.set("n", "D", '"_D', { noremap = true })
        -- c
        vim.keymap.set("n", "c", '"_c', { noremap = true })
        vim.keymap.set("n", "C", '"_C', { noremap = true })
        vim.keymap.set("x", "c", '"_c', { noremap = true })
        vim.keymap.set("n", "ca", '"_ca', { noremap = true })
        vim.keymap.set("n", "ci", '"_ci', { noremap = true })
        vim.keymap.set("n", "cw", '"_cw', { noremap = true })
        vim.keymap.set("n", "C", '"_C', { noremap = true })
        --
        vim.keymap.set("n", "d<Left>", '"_dh', options)
        vim.keymap.set("n", "d<Right>", '"_dl', options)
        vim.keymap.set("n", "d<Up>", '"_d<Up>', options)
        vim.keymap.set("n", "d<Down>", '"_d<Down>', options)
        -- Tab
        vim.opt.showtabline = 2
        vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>to", ":tabonly<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>tn", ":tabn<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>tp", ":tabp<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>1", "1gt", options)
        vim.keymap.set("n", "<leader>2", "2gt", options)
        vim.keymap.set("n", "<leader>3", "3gt", options)
        vim.keymap.set("n", "<leader>4", "4gt", options)
        vim.keymap.set("n", "<leader>5", "5gt", options)
        vim.keymap.set("n", "<leader>6", "6gt", options)
        vim.keymap.set("n", "<leader>7", "7gt", options)
        vim.keymap.set("n", "<leader>8", "8gt", options)
        vim.keymap.set("n", "<leader>9", "9gt", options)
        -- Definiton
        --Ctrl ] and Ctrl o
        -- Diagnostic
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
        -- CTRL
        vim.keymap.set("i", "<C-c>", "<Esc>")
        vim.keymap.set("n", "<C-z>", "u", options)
        vim.keymap.set({"i", "v"}, "<C-z>", "<Nop>")
        vim.keymap.set("n", "<C-y>", "<C-r>", options)
        vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", {silent = true})
        vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", {silent = true})
        vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", {silent = true})
        vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", {silent = true})
        -- Markdown preview
        function ToggleMarkdownPreview()
          local is_running = vim.g.markdown_preview_running or false
          if is_running then
            vim.cmd("MarkdownPreviewStop")
            vim.g.markdown_preview_running = false
          else
            vim.cmd("MarkdownPreview")
            vim.g.markdown_preview_running = true
          end
        end
        vim.keymap.set("n", "<leader>mp", ToggleMarkdownPreview, options)
        -- Undotree
        vim.keymap.set("n", "<leader><F1>", vim.cmd.UndotreeToggle)
        vim.api.nvim_create_autocmd("VimLeave", {
          pattern = "*",
          command = "set guicursor=a:ver25-Cursor/lCursor",
        })
        -- Wrap
        function WrapWord(symbol1, symbol2)
          local word = vim.fn.expand("<cword>")
          local cmd = string.format("normal ciw%s%s%s", symbol1, word, symbol2)
          vim.cmd(cmd)
        end
        vim.keymap.set("n", "<leader>()", ":lua WrapWord('(', ')')<CR>", options)
        vim.keymap.set("n", "<leader>[]", ":lua WrapWord('[', ']')<CR>", options)
        vim.keymap.set("n", "<leader>{}", ":lua WrapWord('{', '}')<CR>", options)
        vim.keymap.set("n", "<leader>'w", ":lua WrapWord(\"'\", \"'\")<CR>", options)
        vim.keymap.set("n", '<leader>"w', ":lua WrapWord('\"', '\"')<CR>", options)
        vim.keymap.set("n", "<leader><>", ":lua WrapWord('<', '>')<CR>", options)
        -- Telescope cmd
        vim.keymap.set("n", "<leader><leader>", ":Telescope cmdline<CR>", {noremap = true, desc = "Cmd"})
        -- Lazygit
        vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", options)
        -- Nui
        vim.keymap.set("n", ":", "<cmd>FineCmdline<CR>", {noremap = true})
        vim.keymap.set("n", "<leader>ss", ":SearchBoxIncSearch<CR>")
        vim.keymap.set("x", "<leader>ss", ":SearchBoxIncSearch visual_mode=true<CR>")
      '';
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
        "--glob=!node_modles/*"
        "--glob=!target/*"
      ];
    };
    zellij.enable = true;
    zoxide.enable = true;
  };
}
