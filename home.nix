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
            # # F
            fira-code
            firebase-tools
            # # G
            google-cloud-sdk
            # # H
            hey
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
            trash-cli
        ];
        file = {

        };
        sessionVariables = {

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
        bat = {
            enable = true;
            config = {
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
        bun = {
            enable = true;
            settings = {
                mosl = true;
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
                cl = "clear";
                code = "code .";
                la = "eza -al";
                ll = "eza -l";
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
                set -x GPG_TTY (tty)
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
            ];
            userSettings = {
                breadcrumbs = {
                    enabled = false;
                };
                # # Extension https://marketplace.visualstudio.com/items?itemName=GoogleCloudTools.cloudcode
                cloudcode = {
                    # # Google Cloud project id
                    project = "adroit-cortex-391921";
                    # # Gemini code assist
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
                        smoothScrolling = true;
                    };
                };
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
                "[yaml]" = {
                    editor = {
                        tabSize = 2;
                    };
                };
                "[yml]" = {
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