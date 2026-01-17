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
  # Bun only for x86_64-linux
  # https://github.com/oven-sh/bun/releases
  bunLatest = pkgs.bun.overrideAttrs (old: rec {
    pname = "bun";
    version = "1.3.6";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "1vqidhf94196ynwc333y4v5vfx4fqkss88svhy86c3am6hhqvacv";
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
    version = "548.0.0";
    src = pkgs.fetchurl {
      url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${version}-linux-x86_64.tar.gz";
      sha256 = "15d0hnw8ihff75ppciilmhvjidsgma4pyr1hi3bd1bgyrqm86m8b";
    };
    installCheckPhase = ''
      echo "Skip installCheckPhase"
    '';
  });
  # Go only for Linux x86_64
  # https://go.dev/dl
  goLatest = pkgs.go.overrideAttrs (old: rec {
    pname = "go";
    version = "1.25.5";
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      sha256 = "0kwm3af45rg8a65pbhsr3yv08a4vjnwhcwakn2hjikggj45gv992";
    };
  });
  # LM Studio AI for Linux x64
  # https://lmstudio.ai
  lmStudio = pkgs.stdenv.mkDerivation rec {
    pname = "lmstudio";
    version = "0.3.30";
    src = pkgs.fetchurl {
      url = "https://installers.lmstudio.ai/linux/x64/${version}-1/LM-Studio-${version}-1-x64.AppImage";
      sha256 = "1qa4grcfd97v1h12jmm5m8f10b3zsmygw4nsffhm57ib2kmidlmm";
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
  nodejsLatestLts = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "24.13.0";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "0znnfby4b8aqm1da9bhmw4a25mjz146sp5rk78rp3fzl2ab5k677";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xJf $src --strip-components=1 -C $out
      mv $out/LICENSE $out/share/doc/LICENSE_nodejs
    '';
  };
  # R lang
  rWrapper = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      argparse
      cowplot
      DT
      dplyr
      dplyrAssist
      GGally
      ggplot2
      ggrepel
      gridExtra
      jsonlite
      languageserver
      lubridate
      magick
      readr
      readxl
      rmarkdown
      scales
      styler
      tidyr
      tidyverse
    ];
  };
  # Rofi Arc-Dark theme
  rofiTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/davatorium/rofi/refs/heads/next/themes/Arc-Dark.rasi";
    sha256 = "1kqv5hbdq9w8sf0fx96knfhmzb8avh6yzp28jaizh77hpsmgdx9s";
  };
  # Zellij statusbar plugin
  # https://github.com/dj95/zjstatus
  zjstatusPlugin = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    sha256 = "0lyxah0pzgw57wbrvfz2y0bjrna9bgmsw9z9f898dgqw1g92dr2d";
  };
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
      # # K
      k6
      # # L
      lazydocker
      lazysql
      lua
      # # M
      minify
      # # N
      nix-prefetch-git
      nodejsLatestLts
      # # O
      onefetch
      # # P
      packer
      pnpm
      podman-compose
      # # R
      rlwrap
      rustup
      rWrapper
      # # T
      terraform
      texliveFull
      tree-sitter
      tree-sitter-grammars.tree-sitter-latex
      tokei
      typescript
      # # U
      ueberzugpp
      unar
      # # Y
      yt-dlp
      # # Z
      zig
    ];
    file = {
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
            bg "#0c0c0c"
            black "#0c0c0c"
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
        simplified_ui true
        default_shell "${config.home.profileDirectory}/bin/fish"
        layout_dir "${pathHome}/.config/zellij/layouts"
      '';
      ".config/zellij/layouts/default.kdl".text = ''
        layout {
          cwd "${pathHome}"
          default_tab_template {
            children
            pane size=1 borderless=true {
              plugin location="file:${zjstatusPlugin}" {
                format_left "{tabs}"
                hide_frame_for_single_pane "false"
                mode_normal "#[bg=#096dd9]"
                mode_tmux "#[bg=#faad14]"
                tab_normal "#[fg=#ffffff] {index}->{name} "
                tab_active "#[fg=#526596,bold] {index}->{name} "
              }
            }
          }
          tab name="Sysinfo" {
            pane command="btop" name="Monitor resource" {}
          }
          tab name="Editor" {
            pane name="Task" {}
          }
          tab name="Debug" {
            pane name="$$$" {}
          }
          tab name="Gemini" {
            pane name="Agent" {}
          }
        }
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
        done < <(nmcli -t -f SSID device wifi list | grep -v '^$' | uniq)
        chosen=$(printf '%s\n' "''${networks[@]}" | rofi -dmenu -no-custom -i -p "Select a WiFi network")
        [ -z "$chosen" ] && exit
        nmcli device wifi connect "$chosen" && notify-send -t 3000 "WiFi" "Connected to $chosen"
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
        **************************************************
        **************************************************
        *********************@@@@@@#%*********************
        ******************@@@@@@@@@@@#%#******************
        *****************@@%%%%%@%%@@%%@@*****************
        ****************@*=---====+++=-:%@****************
        ****************#==-::-=-=+++**:=#****************
        *****************=---:--=--=++=::*****************
        ****************==*+###+==%@#*##:+****************
        ****************=-=*-@*::+%=@%%#:+#-**************
        **************=-=--::-:--==+====:-#***************
        ***************=#-:::::-:=-#+==+=##***************
        ****************-=-::::+++%#+++++#****************
        *****************%*--#%**#%%@*+#%*****************
        ******************#+=#-=+*####%%#*****************
        *******************@#%=-=###%%%*******************
        *******************-+@@%%@%@@@*=@*****************
        ****************@@..--=**%%##%%.@%%***************
        ************@@@@@@:...--=+*##::.@@@@@@@***********
        ******#@@@@@@@@@@@@......+...::#@@@@@@@@@@@@@*****
        ***@@@@@@@@@@@@@@@@........-..:@@@@@@@@@@@@@@@@%**
        **@@@@@@@@@@@@@@@@@-.-....:#:.=@@@@@@@@@@@@@@@@@#*
        **@@@@@@@@@@@@@@@@@%......:=.::@@@@@@@@@@@@@@@@@@*
        *@@@@@@@@@@@@@@@@@@@......:-.::@@@@@@@@@@@@@@@@@@%
        *@@@@@@@@@@@@@@@@@@@-......:=.@@@@@@@@@@@@@@@@@@@@
        *@@@@@@@@@@@@@@@@@@@#.......#.@@@@@@@@@@@@@@@@++@@
        @@@@@@@@@@@@@@@@@@@@@:......%.@@@@@@@@@@@@@@@@@@@@
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
      "*.tex" = {
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
      # Zellij
      zla = "zellij a ?";
      zld = "zellij d ?";
      zls = "zellij ls";
      zlda = "zellij da -y";
      zl = "zellij -s Main";
      # Open
      xof = "xdg-open $(pwd)/?";
    };
    shellAliases = {
      docker = "podman";
      la = "eza -ahl --color never --time-style relative";
      lg = "eza -hl --git --color never --time-style relative";
      ll = "eza -hl --color never --time-style relative";
      ls = "eza -h --color never";
      tree = "eza -T --color never";
      zigfmt = "zig fmt";
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
          blink_interval = 250;
          blink_timeout = 0;
        };
        mouse.hide_when_typing = true;
        window = {
          padding = {
            y = 4;
          };
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
      settings = {
        smol = true;
        telemetry = false;
      };
      package = bunLatest;
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
            text = "echo \"alacritty $(alacritty -V | cut -d ' ' -f2) + zellij $(zellij --version | cut -d ' ' -f2)\"";
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
      plugins = with pkgs.vimPlugins; [
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = builtins.readFile ./nvim/plugins/gitsigns.lua;
        }
        {
          plugin = hlchunk-nvim;
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
          plugin = myVimPlugin "VonHeikemen/fine-cmdline.nvim" "7db181d1cb294581b12a036eadffffde762a118f";
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
        vimtex
      ];
      extraPackages = with pkgs; [
        # LSP and Fmt
        asm-lsp
        asmfmt
        astyle
        bash-language-server
        beautysh
        docker-language-server
        dockerfile-language-server
        gopls
        hclfmt
        htmx-lsp
        jdt-language-server
        lua-language-server
        nil
        nixfmt-rfc-style
        nodePackages.prettier
        rust-analyzer
        rustfmt
        shellcheck
        stylua
        tailwindcss-language-server
        taplo
        terraform-ls
        tex-fmt
        texlab
        typescript-language-server
        vscode-langservers-extracted
        yamlfmt
        yaml-language-server
        zls
      ];
      extraLuaConfig = builtins.readFile ./nvim/init.lua;
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
    zellij = {
      enable = true;
      enableBashIntegration = true;
    };
    zoxide.enable = true;
  };
}
