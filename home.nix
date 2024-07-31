{ config, pkgs, ... }:

{
    nixpkgs.config.allowUnfree = true;
	# To update the overlays package
	# Run "home-manager build" first, then "home-manager switch"
	# If the overlays package has no changes, simply run the "home-manager switch"
    nixpkgs.overlays = [
        (import ./packages/vscodium.nix)
    ];

    home = {
        username = "ryhkml";
        homeDirectory = "/home/ryhkml";
        stateVersion = "24.05";
        packages = with pkgs; [
            # # B
			bash-language-server
			bitwarden-desktop
            # # C
            cosign
			(curl.override {
				c-aresSupport = true;
				gsaslSupport = true;
			})
            # # D
			direnv
			discord
            duf
            # # E
            exiftool
            # # F
			fd
			file
            firebase-tools
            # # G
            google-cloud-sdk
            # # H
            hey
			html-minifier
            http-server
            # # I
			insomnia
            # # J
            jdk22
            jq
            # # K
			kubernetes
            # # M
			minikube
            # # N
            (nerdfonts.override {
                fonts = [
                    "EnvyCodeR"
                    "FiraCode"
                    "JetBrainsMono"
                    "Meslo"
                    "ZedMono"
                ];
            })
			nil
			nixpkgs-fmt
            nodejs_20
            # # P
			podman-compose
            # # R
            rustup
            # # S
			sd
			spotify
			sqlcipher
			sqlite
            # # T
			telegram-desktop
            trash-cli
            # # Y
            yaml-language-server
        ];
        file = {

        };
        sessionVariables = {

        };
    };

    fonts.fontconfig.enable = true;
        
    programs = {
        home-manager = {
            enable = true;
        };
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
		firefox = {
			enable = true;
            policies = {
                BackgroundAppUpdate = false;
                BlockAboutSupport = true;
                DisableAppUpdate = true;
                DisableFeedbackCommands = true;
                DisableFirefoxStudies = true;
                DisableTelemetry = true;
                DNSOverHTTPS = {
                    Enabled = true;
                    ProviderURL = "https://cloudflare-dns.com/dns-query";
                    Fallback = true;
                };
                ExtensionUpdate = true;
                HardwareAcceleration = true;
                HttpsOnlyMode = "force_enabled";
                ManualAppUpdateOnly = true;
                PictureInPicture = {
                    Enabled = true;
                    Locked = true;
                };
                PromptForDownloadLocation = true;
                SanitizeOnShutdown = {
                    Cache = true;
                    Cookies = false;
                    History = true;
                    Sessions = false;
                    SiteSettings = false;
                    OfflineApps = false;
                    Locked = true;
                };
                SearchSuggestEnabled = false;
                ShowHomeButton = false;
                TranslateEnabled = false;
            };
		};
        fish = {
            enable = true;
            shellAbbrs = {
                "/" = "cd /";
                ".." = "cd ..";
                c = "clear";
                C = "clear";
                hm = "cd ~/.config/home-manager";
                q = "exit";
                Q = "exit";
            };
			shellAliases = {
				code = "codium";
				docker = "podman";
                la = "eza -ahlT --color never -L 1 --time-style relative";
                lg = "eza -hlT --git --color never -L 1 --time-style relative";
                ll = "eza -hlT --color never -L 1 --time-style relative";
                ls = "eza -hT --color never -L 1";
                rm = "trash-put";
                tree = "eza -T --color never";
			};
            shellInit = ''
                set -U fish_greeting
                set -gx BUN_INSTALL "$HOME/.bun"
                set -gx PATH "$BUN_INSTALL/bin" $PATH
                set -gx DOCKER_BUILDKIT 1
                set -gx DOCKER_HOST "unix:///run/user/1000/podman/podman.sock"
                set -gx GPG_TTY (tty)
                set -gx NODE_OPTIONS "--max-old-space-size=8192"
            '';
        };
        fzf = {
            enable = true;
			changeDirWidgetCommand = "fd -t d -L 2>/dev/null";
			defaultCommand = "fd -L -H -E .git 2>/dev/null";
			fileWidgetCommand = "fd -L -t f -t l 2>/dev/null";
        };
        nix-index = {
            enable = true;
        };
        oh-my-posh = {
            enable = true;
            useTheme = "xtoys";
        };
        ripgrep = {
            enable = true;
        };
        vscode = {
            enable = true;
			package = pkgs.vscodium;
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
                    fontFamily = "FiraCode Nerd Font";
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
                                    "comment.block"
                                    "comment.block.documentation"
                                    "comment.line"
                                    "constant"
                                    "constant.character"
                                    "constant.character.escape"
                                    "constant.numeric"
                                    "constant.numeric.integer"
                                    "constant.numeric.float"
                                    "constant.numeric.hex"
                                    "constant.numeric.octal"
                                    "constant.other"
                                    "constant.regexp"
                                    "constant.rgb-value"
                                    "emphasis"
                                    "entity"
                                    "entity.name"
                                    "entity.name.class"
                                    "entity.name.function"
                                    "entity.name.method"
                                    "entity.name.section"
                                    "entity.name.selector"
                                    "entity.name.tag"
                                    "entity.name.type"
                                    "entity.other"
                                    "entity.other.attribute-name"
                                    "entity.other.inherited-class"
                                    "invalid"
                                    "invalid.deprecated"
                                    "invalid.illegal"
                                    "keyword"
                                    "keyword.control"
                                    "keyword.operator"
                                    "keyword.operator.new"
                                    "keyword.operator.assignment"
                                    "keyword.operator.arithmetic"
                                    "keyword.operator.logical"
                                    "keyword.other"
                                    "markup"
                                    "markup.bold"
                                    "markup.changed"
                                    "markup.deleted"
                                    "markup.heading"
                                    "markup.inline.raw"
                                    "markup.inserted"
                                    "markup.italic"
                                    "markup.list"
                                    "markup.list.numbered"
                                    "markup.list.unnumbered"
                                    "markup.other"
                                    "markup.quote"
                                    "markup.raw"
                                    "markup.underline"
                                    "markup.underline.link"
                                    "meta"
                                    "meta.block"
                                    "meta.cast"
                                    "meta.class"
                                    "meta.function"
                                    "meta.function-call"
                                    "meta.preprocessor"
                                    "meta.return-type"
                                    "meta.selector"
                                    "meta.tag"
                                    "meta.type.annotation"
                                    "meta.type"
                                    "punctuation.definition.string.begin"
                                    "punctuation.definition.string.end"
                                    "punctuation.separator"
                                    "punctuation.separator.continuation"
                                    "punctuation.terminator"
                                    "storage"
                                    "storage.modifier"
                                    "storage.type"
                                    "string"
                                    "string.interpolated"
                                    "string.other"
                                    "string.quoted"
                                    "string.quoted.double"
                                    "string.quoted.other"
                                    "string.quoted.single"
                                    "string.quoted.triple"
                                    "string.regexp"
                                    "string.unquoted"
                                    "strong"
                                    "support"
                                    "support.class"
                                    "support.constant"
                                    "support.function"
                                    "support.other"
                                    "support.type"
                                    "support.type.property-name"
                                    "support.variable"
                                    "variable"
                                    "variable.language"
                                    "variable.name"
                                    "variable.other"
                                    "variable.other.readwrite"
                                    "variable.parameter"
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
                        defaultProfile = {
                            linux = "fish";
                        };
                        fontFamily = "FiraCode Nerd Font";
                        hideOnStartup = "always";
                        smoothScrolling = true;
                    };
                };
                update = {
					mode = "none";
				};
                window = {
                    restoreFullscreen = true;
					title = "VSCodium";
                };
                workbench = {
                    activityBar = {
                        location = "top";
                    };
                    # # Extension https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-themes
                    colorTheme = "JetBrains New Dark";
                    # # Extension https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-icontheme-nomo-dark
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
					watcherExclude = {
                        "**/.angular/*/**" = true;
                        "**/.database/*/**" = true;
                        "**/.git/objects/**" = true;
                        "**/.git/subtree-cache/**" = true;
                        "**/.hg/store/**" = true;
                        "**/node_modules/*/**" = true;
                    };
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
				# # Extension https://marketplace.visualstudio.com/items?itemName=adpyke.codesnap
				codesnap = {
					containerPadding = "8px";
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
				# # https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide
                "nix.enableLanguageServer" = true;
	            "nix.serverPath" = "nil";
                "nix.serverSettings" = {
                    nil = {
                        diagnostics = {
                            ignored = [
                                "unused_binding"
                                "unused_with"
                            ];
                        };
                        formatting = {
                            command = [
                                "nixpkgs-fmt"
                            ];
                        };
                    };
                };
                # # https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
                "redhat.telemetry.enabled" = false;
            };
        };
        zoxide = {
            enable = true;
        };
    };

	# Create new Telegram desktop app icon
	xdg.desktopEntries."org.telegram.desktop" = {
		name = "Telegram";
		comment = "Official desktop version of Telegram messaging app";
		genericName = "Messaging App";
		exec = "telegram-desktop -- %u";
		icon = "telegram";
		terminal = false;
		categories = [
			"Chat"
			"InstantMessaging"
			"Network"
		];
		mimeType = [
			"x-scheme-handler/tg"
			"x-scheme-handler/telegram"
		];
		settings = {
			StartupWMClass = "TelegramDesktop";
		};
    };
}