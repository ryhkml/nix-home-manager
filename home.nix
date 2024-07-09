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
            # # B
			bash-language-server
            # # C
            cosign
			(curl.override {
				c-aresSupport = true;
				gsaslSupport = true;
			})
            # # D
			direnv
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
			html-minifier
            http-server
            hurl
            # # J
            jdk22
            jetbrains-mono
            jq
            # # K
			kubernetes
            # # M
			minikube
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
                "--disable-auto-reload"
                "--incognito"
                "--no-crash-upload"
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
                "/" = "cd /";
                ".." = "cd ..";
                c = "clear";
                code = "eza -hl --time-style relative && code .";
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
			};
            shellInit = ''
                set -U fish_greeting
                set -g BUN_INSTALL "$HOME/.bun"
                set -g PATH "$BUN_INSTALL/bin" $PATH
                set -g DOCKER_BUILDKIT 1
                set -g DOCKER_HOST "unix:///run/user/1000/podman/podman.sock"
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
                    detectIndentation = false;
                    fontFamily = "Fira Code";
                    fontLigatures = true;
                    fontSize = 14;
                    insertSpaces = false;
                    letterSpacing = 0.4;
                    lineHeight = 1.6;
                    renderWhitespace = "none";
                    smoothScrolling = true;
                    stickyScroll = {
                        enabled = false;
                    };
                    tabSize = 4;
                    tokenColorCustomizations = {
						# # Disable italic font style
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
					confirmDragAndDrop = false;
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
                files = {
					associations = {
						"**/*-compose.yml" = "dockercompose";
						"**/*-compose*.yml" = "dockercompose";
						"**/*-compose.yaml" = "dockercompose";
						"**/*-compose*.yaml" = "dockercompose";
						"**/Dockerfile*" = "dockerfile";
						"**/.env" = "dotenv";
						"**/.env*" = "dotenv";
						"**/.*ignore" = "ignore";
						"**/*.json" = "json";
					};
					insertFinalNewline = false;
					trimFinalNewlines = false;
                };
                "[nix]" = {
                    editor = {
                        tabSize = 4;
                    };
                };
                "[yaml]" = {
                    editor = {
                        insertSpaces = true;
                        tabSize = 2;
                    };
                };
				# # Extension https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
				"yaml.schemas" = {
					"https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = [
						"**/*-compose.yml"
						"**/*-compose*.yml"
						"**/*-compose.yaml"
						"**/*-compose*.yaml"
					];
				};
            };
        };
        zoxide = {
            enable = true;
        };
    };
}