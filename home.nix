{ config, pkgs, ... }:

{
    nixpkgs = {
        config = {
            allowUnfree = true;
        };
    };

    home = {
        username = "ryhkml";
        homeDirectory = "/home/ryhkml";
        stateVersion = "24.05";
        packages = with pkgs; [
            # # C
            cosign
            # # D
            duf
            # # E
            exiftool
            # # F
            fira-code
            firebase-tools
            # # G
            google-cloud-sdk
            gping
            # # H
            hey
            http-server
            hurl
            # # J
            jdk22
            jetbrains-mono
            jq
            # # N
            nodejs_20
            # # R
            rustup
            # # T
            tldr
            trash-cli
            # # Y
            yaml-language-server
        ];
        file = {

        };
        sessionVariables = {

        };
    };

    editorconfig = {
        enable = true;
        settings = {
            "*" = {
                charset = "utf-8";
                end_of_line = "lf";
                trim_trailing_whitespace = true;
                insert_final_newline = false;
                indent_style = "tab";
                indent_size = 4;
            };
            "*.{yaml,yml}" = {
                indent_style = "space";
                indent_size = 2;
            };
        };
    };

    fonts = {
        fontconfig = {
            enable = true;
        };
    };

    programs = {
        home-manager = {
            enable = true;
        };
        # #
        # #
        aria2 = {
            enable = true;
            settings = {
                max-connection-per-server = 16;
                retry-wait = 120;
                split = 16;
            };
        };
        bat = {
            enable = true;
            config = {
                italic-text = "never";
                pager = "less -FR";
                theme = "base16";
            };
        };
        btop = {
            enable = true;
            settings = {
                color_theme = "adapta";
                show_battery = false;
                temp_scale = "celsius";
                update_ms = 1000;
            };
        };
        chromium = {
            enable = true;
            commandLineArgs = [
                "--incognito"
                "--no-default-browser-check"
            ];
            extensions = [
                # # uBlock Origin 💀
                "cjpalhdlnbpafiamejdnhcphjbkeiagm"
            ];
        };
        eza = {
            enable = true;
        };
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
                    "locale"
                    "break"
                ];
            };
        };
        fish = {
            enable = true;
            shellAbbrs = {
                ".." = "cd ..";
                c = "clear";
                code = "code .";
                home = "cd $HOME";
                la = "eza -ahl --time-style relative";
                ll = "eza -hl --time-style relative";
                ls = "eza";
                rm = "trash-put";
                tree = "eza -T";
                q = "exit";
            };
            shellAliases = {
                docker = "podman";
                docker-compose = "podman-compose";
            };
            shellInit = ''
                set -U fish_greeting
                set -g BUN_INSTALL "$HOME/.bun"
                set -g PATH "$BUN_INSTALL/bin" $PATH
                set -g GPG_TTY (tty)
                set -g NODE_OPTIONS "--max-old-space-size=8192"
            '';
        };
        fzf = {
            enable = true;
        };
        ripgrep = {
            enable = true;
        };
        vscode = {
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
                {
                    key = "ctrl+alt+'";
                    command = "find-it-faster.findFiles";
                }
                {
                    key = "ctrl+alt+;";
                    command = "find-it-faster.findWithinFiles";
                }
            ];
            userSettings = {
                breadcrumbs = {
                    enabled = false;
                };
                # # Extension https://marketplace.visualstudio.com/items?itemName=GoogleCloudTools.cloudcode
                cloudcode = {
                    project = "adroit-cortex-391921";
                    duetAI = {
                        project = "adroit-cortex-391921";
                    };
                };
                editor = {
                    bracketPairColorization = {
                        enabled = false;
                    };
                    cursorSmoothCaretAnimation = "on";
                    cursorStyle = "line";
                    fontFamily = "Fira Code";
                    fontLigatures = true;
                    fontSize = 14;
                    letterSpacing = 0.4;
                    lineHeight = 1.6;
                    renderWhitespace = "none";
                    smoothScrolling = true;
                    stickyScroll = {
                        enabled = false;
                    };
                    tabSize = 4;
                    tokenColorCustomizations = {
                        textMateRules = [
                            {
                                scope = [
                                    "comment"
                                    "comment.line"
                                    "comment.block"
                                    "comment.block.documentation"
                                    "punctuation.definition.comment"
                                ];
                                settings = {
                                    fontStyle = "";
                                };
                            }
                        ];
                    };
                };
                explorer = {
                    confirmDelete = false;
                };
                extensions = {
                    autoUpdate = "onlyEnabledExtensions";
                };
                # # Extension https://marketplace.visualstudio.com/items?itemName=TomRijndorp.find-it-faster
                find-it-faster = {
                    general = {
                        batTheme = "Visual Studio Dark+";
                        killTerminalAfterUse = true;
                    };
                };
                git = {
                    confirmSync = false;
                };
                security = {
                    workspace = {
                        trust = {
                            banner = "never";
                            enabled = true;
                            startupPrompt = "never";
                        };
                    };
                };
                terminal = {
                    integrated = {
                        cursorBlinking = true;
                        cursorStyle = "line";
                        defaultProfile = {
                            linux = "fish";
                        };
                        hideOnStartup = "always";
                        smoothScrolling = true;
                    };
                };
                update.mode = "none";
                window = {
                    newWindowDimensions = "maximized";
                    restoreFullscreen = true;
                };
                workbench = {
                    activityBar = {
                        location = "top";
                    };
                    # # Extension https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-themes
                    colorTheme = "Visual Studio 2017 Dark - C++";
                    # # Extension https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-icontheme-nomo-dark
                    iconTheme = "vs-nomo-dark";
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
                # # Configuration files
                "[json]" = {
                    editor = {
                        tabSize = 4;
                    };
                };
                "[yaml],[yml]" = {
                    editor = {
                        tabSize = 2;
                    };
                };
            };
        };
        zoxide = {
            enable = true;
        };
    };
}