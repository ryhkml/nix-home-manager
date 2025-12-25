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
    version = "1.3.5";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "0sa6vg1ya9z66d157rnaz69hg77pv1gkn8cn1czfmvsaj9mdhlbh";
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
    version = "22.21.1";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "121whz4vkqdwl66nbpvqj27hy1y0jkr9cpnvk15z4zsan8q3y3b8";
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
    url = "https://github.com/dj95/zjstatus/releases/download/v0.21.1/zjstatus.wasm";
    sha256 = "06mfcijmsmvb2gdzsql6w8axpaxizdc190b93s3nczy212i846fw";
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
            pane name="Test" {}
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
          config = ''
            -- https://github.com/lewis6991/gitsigns.nvim
            require("gitsigns").setup({
              signs = {
                add          = { text = "+" },
                change       = { text = "|" },
                delete       = { text = "x" },
                topdelete    = { text = "^" },
                changedelete = { text = "~" },
                untracked    = { text = "!" },
              },
              signs_staged = {
                add          = { text = "SA" },
                change       = { text = "SC" },
                delete       = { text = "SX" },
                topdelete    = { text = "S^" },
                changedelete = { text = "S~" },
                untracked    = { text = "SU" },
              },
            })
          '';
        }
        {
          plugin = hlchunk-nvim;
          type = "lua";
          config = ''
            -- https://github.com/shellRaining/hlchunk.nvim
            require("hlchunk").setup({
              chunk = {
                enable = true,
                use_treesitter = false,
                chars = {
                  horizontal_line = "─",
                  vertical_line = "│",
                  left_top = "╭",
                  left_bottom = "╰",
                  right_arrow = ">",
                },
                max_file_size = 2 * 1024 * 1024,
                style = "#708090",
                duration = 250,
                delay = 500,
                exclude_filetypes = {
                  aerial = true,
                  dashboard = true,
                  Dockerfile = true,
                  conf = true,
                  txt = true
                }
              },
              indent = {
                enable = true,
                chars = {
                  ""
                },
                filter_list = {
                  function(v)
                    return v.level ~= 1
                  end
                },
                exclude_filetypes = {
                  aerial = true,
                  dashboard = true
                }
              }
            })
          '';
        }
        # https://github.com/neovim/nvim-lspconfig
        nvim-lspconfig
        {
          plugin = luasnip;
          type = "lua";
          config = ''
            -- https://github.com/L3MON4D3/LuaSnip
            require("luasnip.loaders.from_vscode").lazy_load()
          '';
        }
        # https://github.com/b0o/SchemaStore.nvim
        SchemaStore-nvim
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            -- https://github.com/hrsh7th/nvim-cmp
            local cmp = require("cmp")
            cmp.setup({
              snippet = {
                expand = function(args)
                  require("luasnip").lsp_expand(args.body)
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
                { name = "luasnip" },
              }, {
                { name = "buffer" },
              })
            })
          '';
        }
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            -- https://github.com/hrsh7th/cmp-nvim-lsp
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
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            -- ASM
            vim.lsp.enable("asm_lsp")
            -- Bash
            vim.lsp.enable("bashls")
            -- C
            vim.lsp.enable("clangd")
            -- CSS
            vim.lsp.config("cssls", {
              capabilities = capabilities
            })
            vim.lsp.enable("cssls")
            -- Dockerfile
            vim.lsp.config("dockerls", {
              settings = {
                docker = {
                  languageserver = {
                    formatter = {
                      ignoreMultilineInstructions = true
                    }
                  }
                }
              }
            })
            vim.lsp.enable("dockerls")
            -- HTML
            vim.lsp.config("html", {
              capabilities = capabilities
            })
            vim.lsp.enable("html")
            -- HTMX
            --vim.lsp.enable("htmx")
            -- Go
            vim.lsp.enable("gopls")
            -- Java
            --vim.lsp.enable("jdtls")
            -- JSON
            local json_schemas = require("schemastore").json.schemas {
              select = {
                "angular.json",
                "Firebase",
                "package.json",
                "tsconfig.json"
              }
            }
            table.insert(json_schemas, {
              name = "OpenAPI 3.0",
              description = "OpenAPI 3.0 Specification",
              fileMatch = { "**/openapi/*.json", "openapi.json" },
              url = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
            })
            vim.lsp.config("jsonls", {
              settings = {
                json = {
                  schemas = json_schemas,
                  validate = {
                    enable = true
                  }
                }
              }
            })
            vim.lsp.enable("jsonls")
            -- LaTeX
            vim.lsp.enable("texlab")
            -- Lua
            vim.lsp.enable("stylua")
            -- Nix
            vim.lsp.config("nil_ls", {
              settings = {
                ["nil"] = {
                  formatting = {
                    command = { "nixfmt" }
                  }
                }
              }
            })
            vim.lsp.enable("nil_ls")
            -- R
            vim.lsp.enable("r_language_server")
            -- Rust
            vim.lsp.config("rust_analyzer", {
              settings = {
                ["rust-analyzer"] = {
                  diagnostics = {
                    enable = false
                  }
                }
              }
            })
            vim.lsp.enable("rust_analyzer")
            -- Tailwindcss
            vim.lsp.enable("tailwindcss")
            -- Terraform
            vim.lsp.enable("terraformls")
            -- Typescript
            vim.lsp.enable("ts_ls")
            -- YAML
            vim.lsp.config("yamlls", {
              settings = {
                yaml = {
                  schemas = {
                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose.{yaml,yml}",
                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose-*.{yaml,yml}"
                  }
                }
              }
            })
            vim.lsp.enable("yamlls")
            -- Zig
            vim.lsp.enable("zls")
            -- Disable log
            vim.lsp.set_log_level("off")
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
                  "^target/",
                  "%.min%.css$",
                  "%.min%.js$"
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
                    "^target/",
                    "%.min%.css$",
                    "%.min%.js$"
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
          plugin = nvim-treesitter;
          type = "lua";
          config = ''
            -- https://github.com/nvim-treesitter/nvim-treesitter
            local dir_parser = os.getenv("HOME") .. "/.vim/parsers"
            vim.opt.runtimepath:append(dir_parser)
            require("nvim-treesitter.configs").setup{
              ensure_installed = {
                "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "comment", "diff",
                "asm", "angular",
                "bash",
                "c", "css",
                "dockerfile",
                "go", "gomod", "gosum", "gitattributes", "gitcommit", "gitignore", "git_config",
                "hcl", "html",
                "java", "javascript", "json",
                "kdl",
                "latex",
                "nix",
                "scss", "ssh_config", "sql", "sway",
                "r", "rust",
                "terraform", "toml", "typescript",
                "yaml",
                "xml",
                "zig", "ziggy",
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
          plugin = myVimPlugin "slugbyte/lackluster.nvim" "b247a6f51cb43e49f3f753f4a59553b698bf5438";
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
                popup = "#191919",
                menu = "#000000",
                telescope = "#000000",
              }
            })
            vim.cmd.colorscheme("lackluster")
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
                "html",
                "css",
                "scss",
                "sass",
                "less",
                "javascript",
                "typescript",
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
                asm = { "asmfmt" },
                c = { "clang-format" },
                css = { "prettier" },
                fish = { "fish_indent" },
                go = { "gofmt" },
                hcl = function(bufnr)
                  local filename = vim.api.nvim_buf_get_name(bufnr)
                  if filename:match("%.pkr.hcl$") or filename:match("%.pkrvars.hcl$") then
                    return { "packer_fmt" }
                  end
                  return { "hcl" }
                end,
                html = { "prettier" },
                java = { "astyle" },
                javascript = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                less = { "prettier" },
                lua = { "stylua" },
                nix = { "nixfmt" },
                r = { "styler" },
                rust = { "rustfmt" },
                scss = { "prettier" },
                sh = { "beautysh" },
                tex = { "tex-fmt" },
                tf = { "terraform_fmt" },
                toml = { "taplo" },
                typescript = { "prettier" },
                yaml = { "yamlfmt" },
                zig = { "zigfmt" },
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
              notify_no_formatters = false,
              -- Custom formatters and overrides for built-in formatters
              formatters = {
                astyle = {
                  prepend_args = {
                    "--style=java",
                    "-t4",
                    "--add-braces"
                  }
                },
                beautysh = {
                  prepend_args = {
                    "--indent-size", "4",
                    "--tab"
                  }
                },
                nixfmt = {
                  prepend_args = {
                    "--width=100"
                  }
                },
                prettier = {
                  prepend_args = function(self, ctx)
                    if ctx.filename:match("%.md$") then
                      return {
                        "--print-width", "100",
                        "--tab-width", "4",
                        "--trailing-comma", "none",
                        "--embedded-language-formatting", "auto"
                      }
                    end
                    return {
                      "--print-width", "100",
                      "--use-tabs",
                      "--tab-width", "4",
                      "--trailing-comma", "none",
                      "--embedded-language-formatting", "auto"
                    }
                  end
                },
                ["tex-fmt"] = {
                  prepend_args = {
                    "--wraplen", "100",
                    "--usetabs",
                    "--nowrap"
                  }
                }
              }
            })
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
          plugin = myVimPlugin "VonHeikemen/fine-cmdline.nvim" "7db181d1cb294581b12a036eadffffde762a118f";
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
                exclude = { ".github", ".gitmodules", ".gitignore", ".gitattributes" }
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
            -- https://github.com/nanozuki/tabby.nvim
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
                    { " Nvim ", hl = theme.head },
                    line.sep("", theme.head, theme.fill),
                  },
                  line.tabs().foreach(function(tab)
                    local hl = tab.is_current() and theme.current_tab or theme.tab
                    return {
                      line.sep("", hl, theme.fill),
                      PlainTabName(tab.name()),
                      line.sep("", hl, theme.fill),
                      hl = hl,
                      margin = " ",
                    }
                  end),
                  line.spacer(),
                  {
                    line.sep("", theme.tail, theme.fill),
                    { " EMBRACE TRADITION ", hl = theme.tail },
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
        {
          plugin = myVimPlugin "nvzone/showkeys" "cb0a50296f11f1e585acffba8c253b9e8afc1f84";
          type = "lua";
          config = ''
            -- https://github.com/nvzone/showkeys
            require("showkeys").setup({
              timeout = 2,
              maxkeys = 6,
              show_count = true
            })
          '';
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
          "*.min.css",
          "*.min.js"
        })
        -- Filetype
        local function set_filetype_c()
          vim.bo.filetype = "c"
        end
        local function set_filetype_conf()
          vim.bo.filetype = "conf"
        end
        local function set_filetype_json()
          vim.bo.filetype = "json"
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
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = { ".firebaserc" },
          callback = set_filetype_json,
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
        vim.opt.scrolloff = 10
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
        "--glob=!node_modules/*"
        "--glob=!target/*"
        "--glob=!*.min.css"
        "--glob=!*.min.js"
      ];
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default.userSettings = {
        breadcrumbs = {
          enabled = false;
        };
        codesnap = {
          containerPadding = "4px";
        };
        editor = {
          cursorSmoothCaretAnimation = "on";
          cursorStyle = "line";
          detectIndentation = false;
          fontFamily = "FiraCode Nerd Font";
          fontSize = 14;
          insertSpaces = false;
          letterSpacing = 0.4;
          lineHeight = 1.6;
          minimap = {
            enabled = false;
          };
          renderWhitespace = "none";
          smoothScrolling = true;
          stickyScroll = {
            enabled = false;
          };
          tabSize = 4;
        };
        explorer = {
          confirmDragAndDrop = false;
          compactFolders = false;
          confirmDelete = false;
          fileNesting = {
            patterns = {
              "Cargo.toml" = "Cargo.lock";
              "*.sqlite" = "\${capture}.\${extname}-*";
              "*.db" = "\${capture}.\${extname}-*";
              "*.sqlite3" = "\${capture}.\${extname}-*";
              "*.db3" = "\${capture}.\${extname}-*";
              "*.min.css" = "\${capture}.\${extname}-*";
              "*.min.js" = "\${capture}.\${extname}-*";
              "*.sdb" = "\${capture}.\${extname}-*";
              "*.s3db" = "\${capture}.\${extname}-*";
            };
          };
        };
        extensions = {
          autoUpdate = "onlyEnabledExtensions";
          ignoreRecommendations = true;
        };
        git = {
          autofetch = true;
          confirmSync = false;
        };
        security = {
          workspace = {
            trust = {
              banner = "never";
              enabled = true;
              startupPrompt = false;
            };
          };
        };
        terminal = {
          integrated = {
            cursorBlinking = true;
            cursorStyle = "line";
            hideOnStartup = "always";
            smoothScrolling = true;
            tabs = {
              enabled = false;
            };
          };
        };
        update = {
          mode = "none";
        };
        window = {
          menuBarVisibility = "toggle";
          restoreFullscreen = true;
          title = "Code";
          titleBarStyle = "native";
          zoomLevel = 2;
        };
        workbench = {
          activityBar = {
            location = "top";
          };
          colorTheme = "Visual Studio Dark";
          preferredDarkColorTheme = "Visual Studio Dark";
          iconTheme = "vscode-jetbrains-icon-theme-2023-dark";
          list = {
            smoothScrolling = true;
          };
          remoteIndicator = {
            showExtensionRecommendations = false;
          };
          startupEditor = "none";
          trustedDomains = {
            promptInTrustedWorkspace = true;
          };
        };
      };
    };
    zellij = {
      enable = true;
      enableBashIntegration = true;
    };
    zoxide.enable = true;
  };
}
