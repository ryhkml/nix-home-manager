{ config, pkgs, ... }:

{
    nixpkgs = {
        config = {
            allowUnfree = true;
        };
    };

    home = {
        username = "<USERNAME>";
        homeDirectory = "/home/<USERNAME>";
        stateVersion = "<VERSION>";
        packages = with pkgs; [
            # # C
            cosign
            curl
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
            # # L
            # libgcc # # <- Uncomment for Fedora 40 Work Station
            # # N
            nodejs_22
            # # R
            rustup
            # # T
            tree
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
        };
        btop = {
            enable = true;
            settings = {
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
            ];
            extensions = [
                # # Dark Reader
                "eimadpbcbfnmbkopoojfekhnkhdbieeh"
                # # Privacy Badger
                "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
                # # uBlock Origin 💀
                "cjpalhdlnbpafiamejdnhcphjbkeiagm"
            ];
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
        fzf = {
            enable = true;
        };
        git = {
            enable = true;
            userName = "<USERNAME>";
            userEmail = "<EMAIL>";
            ignores = [
                ".env"
                "note.txt"
            ];
            extraConfig = {
                init = {
                    defaultBranch = "main";
                };
            };
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
                git = {
                    confirmSync = false;
                };
                terminal = {
                    integrated = {
                        cursorBlinking = true;
                        cursorStyle = "line";
                    };
                };
                workbench = {
                    activityBar = {
                        location = "top";
                    };
                    # # Extension https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-themes
                    colorTheme = "Visual Studio 2017 Dark - C++";
                    # # Extension https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-icontheme-nomo-dark
                    iconTheme = "vs-nomo-dark";
                    startupEditor = "none";
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