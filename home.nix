{ config, pkgs, ... }:

{
    nixpkgs.config.allowUnfree = true;
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "<USERNAME>";
    home.homeDirectory = "/home/<USERNAME>";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "<VERSION>";

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = [
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')

        # # b
        pkgs.bat
        pkgs.bitwarden-desktop
        pkgs.btop
        # # c
        pkgs.cargo
        pkgs.cosign
        pkgs.curl
        # # d
        pkgs.discord
        # # f
        pkgs.fira-code
        pkgs.firebase-tools
        # # g
        pkgs.gnomeExtensions.mute-spotify-ads
        pkgs.google-cloud-sdk
        # # h
        pkgs.hey
        pkgs.hurl
        # # j
        pkgs.jdk22
        pkgs.jetbrains-mono
        pkgs.jq
        # # n
        pkgs.nodejs_22
        # # o
        pkgs.obs-studio
        # # r
        pkgs.rustc
        # # s
        pkgs.spotify
        pkgs.tree
    ];

    fonts.fontconfig = {
        enable = true;
    };

    # Bun
    programs.bun = {
        enable = true;
        settings = {
            mosl = true;
        };
    };

    # Chromium
    programs.chromium = {
        enable = true;
        commandLineArgs = [
            "--incognito"
        ];
        extensions = [
            # # Dark Reader
            "eimadpbcbfnmbkopoojfekhnkhdbieeh"
            # # Privacy Badger
            "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
            # # uBlock Origin
            "cjpalhdlnbpafiamejdnhcphjbkeiagm"
        ];
    };

    # Fastfetch
    programs.fastfetch = {
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
                "break"
                "title"
                "separator"
                "os"
                {
                    type = "host";
                    format = "{?2}{2}{?}{?5} ({5}){?}";
                }
                "kernel"
                {
                    type = "de";
                    key = "Desktop Environment";
                }
                "break"
                "chassis"
                "board"
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
                {
                    type = "display";
                    key = "Resolution";
                }
                "battery"
                "bluetooth"
                "locale"
                "break"
            ];
        };
    };

    # Git
    programs.git = {
        enable = true;
        userName = "<USERNAME>";
        userEmail = "<EMAIL>";
    };

    # Vim
    programs.vim = {
        enable = true;
        extraConfig = ''
            set nocompatible
            filetype on
            filetype plugin on
            filetype indent on
            syntax on
            set number
            set expandtab
            set nowrap
        '';
    };

    # Vscode
    programs.vscode = {
        enable = true;
        keybindings = [
            {
                key = "ctrl+shift+down";
                command = "editor.action.copyLinesDownAction";
                when = "editorTextFocus && !editorReadonly";
            }
            {
                key = "ctrl+k ctrl+s";
                command = "workbench.action.files.saveFiles";
            }
        ];
        userSettings = {
            editor = {
                cursorSmoothCaretAnimation = "on";
                cursorStyle = "line";
                fontFamily = "Fira Code";
                fontLigatures = true;
                fontSize = 14;
                letterSpacing = 0.4;
                lineHeight = 1.6;
                renderWhitespace = "none";
                smoothScrolling = true;
                tabSize = 4;
            };
        };
    };

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        # # You can also set the file content immediately.
        # ".gradle/gradle.properties".text = ''
        #   org.gradle.console=verbose
        #   org.gradle.daemon.idletimeout=3600000
        # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/fdradmin/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
        # EDITOR = "emacs";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}