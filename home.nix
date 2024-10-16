{ pkgs, ... }:

let
  yaziPlugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "35100e7dc1e02d4e6e407298be40154332941c4d";
    sha256 = "0r4w2013bg090rjk3ic68wg6cxmryhs3a2d9iar3g6c9nl7mv8sc";
  };
in
{
  nixpkgs.config.allowUnfree = true;
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
      # # C
      (curl.override {
        c-aresSupport = true;
        gsaslSupport = true;
      })
      # # D
      direnv
      docker-compose-language-service
      dockerfile-language-server-nodejs
      duf
      # # E
      exiftool
      # # F
      fd
      file
      firebase-tools
      # # G
      gnuplot
      gopls
      google-cloud-sdk
      # # H
      hey
      html-minifier
      hyperfine
      # # I
      id3v2
      imagemagick
      # # J
      java-language-server
      jdk22
      jq
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
      nix-prefetch-git
      nodejs_20
      nodePackages.vls
      # # P
      podman-compose
      poppler
      # # S
      shellcheck
      sqlite
      sqls
      # # T
      tokei
      trash-cli
      typescript
      typescript-language-server
      # # U
      ueberzugpp
      # # Y
      yaml-language-server
      yt-dlp
    ];
    file = { };
    sessionVariables = { };
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager = {
      enable = true;
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
        clock_format = "";
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
            type = "wm";
            key = "Window Manager";
          }
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
    fish = {
      enable = true;
      shellAbbrs = {
        "/" = "cd /";
        ".." = "cd ..";
        bl = "bash --login";
        c = "clear";
        cr = "code -r";
        C = "clear";
        q = "exit";
        Q = "exit";
        # Downloader
        dlmp3 = "yt-dlp --embed-thumbnail -o \"%(channel)s - %(title)s.%(ext)s\" -f bestaudio -x --audio-format mp3 --audio-quality 320 URL";
        # Wifi
        nmconn = "nmcli device wifi connect NETWORK_NAME";
        nmreconn = "nmcli connection down NETWORK_NAME && nmcli connection up NETWORK_NAME";
        nmscan = "nmcli device wifi rescan";
        nmls = "nmcli device wifi list";
        nmup = "nmcli connection up NETWORK_NAME";
        nmdown = "nmcli connection down NETWORK_NAME";
        nmdnsv4 = "nmcli connection modify NETWORK_NAME ipv4.dns";
        nmdnsv6 = "nmcli connection modify NETWORK_NAME ipv6.dns";
        nv = "neovide";
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
        set -gx GOPATH "$HOME/.go"
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
    go = {
      enable = true;
      goPath = ".go";
    };
    lazygit = {
      enable = true;
      settings = {
        git = {
          merging = {
            args = "-S";
          };
          mainBranches = [ "master" "main" "dev" "next" ];
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
            require("gitsigns").setup({
              signs = {
                add          = { text = "A" },
                change       = { text = "C" },
                delete       = { text = "D" },
                topdelete    = { text = "-" },
                changedelete = { text = "~" },
                untracked    = { text = "U" },
              },
              signs_staged = {
                add          = { text = "A" },
                change       = { text = "C" },
                delete       = { text = "D" },
                topdelete    = { text = "-" },
                changedelete = { text = "~" },
                untracked    = { text = "U" },
              },
            })
          '';
        }
        {
          plugin = lightline-vim;
          config = ''
            function! GitsignsHead()
              return get(b:, "gitsigns_head", "")
            endfunction
            let g:lightline = {
              \ "colorscheme": "wombat",
              \ "active": {
              \   "left": [["mode", "paste"], ["gitbranch", "readonly", "filename", "modified"]],
              \   "right": [["lineinfo"], ["percent"], ["filetype"]],
              \ },
              \ "component_function": {
              \   "gitbranch": "GitsignsHead"
              \ },
              \ }
          '';
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            require("ibl").setup({
              debounce = 100,
              indent = { char = "·" },
            })
          '';
        }
        lsp-zero-nvim
        nvim-lspconfig
        nvim-cmp
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            local lsp_zero = require("lsp-zero")
            local lsp_attach = function(client, bufnr)
              local opts = {buffer = bufnr}
              vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
              vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
              vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
              vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
              vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
              vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
              vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
              vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
              vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
              vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end
            lsp_zero.extend_lspconfig({
              sign_text = true,
              lsp_attach = lsp_attach,
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
            -- Bash
            require("lspconfig").bashls.setup{}
            -- Dockerfile
            require("lspconfig").dockerls.setup{}
            -- Go
            require("lspconfig").gopls.setup{}
            -- Java
            require("lspconfig").java_language_server.setup{}
            -- Nix
            require("lspconfig").nil_ls.setup{}
            -- SQL
            require("lspconfig").sqls.setup{}
            -- Typescript
            require("lspconfig").ts_ls.setup{}
            -- Vue
            require("lspconfig").vuels.setup{}
            -- YAML
            require("lspconfig").yamlls.setup{
              filetypes = { "yaml" },
              settings = {
                yaml = {
                  schemas = {
                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose.yaml",
                  },
                },
              }
            }
          '';
        }
        vim-vsnip
        cmp-vsnip
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require("cmp")
            local cmp_format = require("lsp-zero").cmp_format({ details = true })
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
              formatting = cpm_format,
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
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require("telescope").setup{
              pickers = {
                find_files = {
                  theme = "dropdown",
                },
                live_grep = {                              
                  theme = "dropdown",
                },
                help_tags = {
                  theme = "dropdown",
                }
              },
              extensions = {
                fzf = {
                  case_mode = "smart_case",
                  fuzzy = true,
                  override_file_sorter = true,
                  override_generic_sorter = true,
                }
              }
            }
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files)
            vim.keymap.set("n", "<leader>fg", builtin.live_grep)
            vim.keymap.set("n", "<leader>fh", builtin.help_tags)
            require("telescope").load_extension("fzf")
          '';
        }
        {
          plugin = harpoon;
          type = "lua";
          config = ''
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")
            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<A-e>", ui.toggle_quick_menu)
            vim.keymap.set("n", "<A-1>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<A-2>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<A-3>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<A-4>", function() ui.nav_file(4) end)
          '';
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = ''
            require("nvim-autopairs").setup()
          '';
        } 
        vim-visual-multi
      ];
      extraLuaConfig = ''
        vim.scriptencoding = "utf-8"
        vim.opt.encoding = "utf-8"
        vim.opt.fileencoding = "utf-8"
        vim.opt.wildignore:append({
          "*/node_modules/*",
          "*/target/*",
          "*/dist/*",
          "*/.angular/*",
          "*/.git/*",
        })
        vim.cmd [[highlight CustomCursor guifg=NONE guibg=#FFFFF]]
        vim.opt.guicursor = ""
        vim.opt.nu = true
        -- Tab
        vim.opt.tabstop = 4
        vim.opt.softtabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "yaml", "nix" },
            callback = function()
              vim.opt_local.tabstop = 2
              vim.opt_local.softtabstop = 2
              vim.opt_local.shiftwidth = 2
          end,
        })
        vim.opt.smartindent = true
        vim.opt.wrap = false
        vim.opt.backup = false
        vim.opt.hlsearch = false
        vim.opt.incsearch = true
        vim.opt.endofline = false
        vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
        vim.opt.undofile = true
        vim.opt.termguicolors = false
        vim.opt.guicursor = "a:ver25-CustomCursor"
        vim.opt.updatetime = 50
        --
        vim.g.mapleader = " "
        vim.keymap.set("n", "<leader>ee", vim.cmd.Ex) 
        vim.keymap.set("n", "<C-z>", "<cmd>undo<CR>")
        vim.keymap.set("n", "<C-y>", "<cmd>redo<CR>")
        vim.keymap.set("n", "<leader>qa", function() vim.cmd("qa!") end)
        vim.keymap.set("n", "<leader>hm", "<cmd>cd ~/.config/home-manager<CR>")
        vim.keymap.set("n", "<leader>dc", "<cmd>cd ~/Documents/code<CR>")
        -- Greatest remap ever
        vim.keymap.set({ "n", "x" }, "<leader>p", [["0p]])
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
        vim.keymap.set("n", "<leader>Y", [["+Y]])
        vim.cmd([[
          function! DuplicateLine()
            normal! yyp
          endfunction
        ]])
        vim.api.nvim_set_keymap("n", "<C-S-Down>", ":call DuplicateLine()<CR>", {noremap = true, silent = true})
        --
        vim.keymap.set("i", "<C-c>", "<Esc>")
        vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", {silent = true})
        vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", {silent = true})
        -- Undotree
        vim.keymap.set("n", "<leader><F1>", vim.cmd.UndotreeToggle)
        -- Git
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        -- Neovide config goes here
        if vim.g.neovide then
          vim.g.neovide_transparency = 0.97
          vim.g.neovide_padding_top = 0
          vim.g.neovide_padding_bottom = 0
          vim.g.neovide_padding_right = 0
          vim.g.neovide_padding_left = 0
          vim.g.neovide_cursor_animation_length = 0.1
          vim.g.neovide_cursor_trail_size = 0.5
          -- Copy/paste
          vim.api.nvim_set_keymap('v', '<sc-c>', '"+y', {noremap = true})
          vim.api.nvim_set_keymap('n', '<sc-v>', 'l"+P', {noremap = true})
          vim.api.nvim_set_keymap('v', '<sc-v>', '"+P', {noremap = true})
          vim.api.nvim_set_keymap('c', '<sc-v>', '<C-o>l<C-o>"+<C-o>P<C-o>l', {noremap = true})
          vim.api.nvim_set_keymap('i', '<sc-v>', '<ESC>l"+Pli', {noremap = true})
          vim.api.nvim_set_keymap('t', '<sc-v>', '<C-\\><C-n>"+Pi', {noremap = true})
        end
      '';
      viAlias = true;
      vimAlias = true;
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
      ];
      userSettings = {
        breadcrumbs = {
          enabled = false;
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
          guides = {
            highlightActiveBracketPair = false;
          };
          insertSpaces = false;
          letterSpacing = 0.4;
          lightbulb = {
            enabled = "off";
          };
          lineHeight = 1.6;
          matchBrackets = "never";
          minimap = {
            enabled = false;
          };
          renderLineHighlight = "none";
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
          compactFolders = false;
          confirmDelete = false;
          confirmDragAndDrop = false;
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
            defaultProfile = {
              linux = "fish";
            };
            fontFamily = "FiraCode Nerd Font";
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
          zoomLevel = 2;
        };
        workbench = {
          activityBar = {
            location = "top";
          };
          # # Extension https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-themes
          colorTheme = "Black Waves";
          # # Extension https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-icontheme-nomo-dark
          iconTheme = "chalice-icon-theme";
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
            "**/config" = "plaintext";
            "**/conf" = "plaintext";
            "**/*.conf" = "plaintext";
            "**/*.cfg" = "plaintext";
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
          exclude = {
            "**/.git" = true;
            "**/.svn" = true;
            "**/.hg" = true;
            "**/CVS" = true;
            "**/.DS_Store" = true;
            "**/.angular" = true;
            "**/node_modules" = true;
            "**/home-manager/result" = true;
          };
          watcherExclude = {
            "**/.angular/*/**" = true;
            "**/.database/*/**" = true;
            "**/.git/objects/**" = true;
            "**/.git/subtree-cache/**" = true;
            "**/.hg/store/**" = true;
            "**/target" = true;
            "**/node_modules/**" = true;
            "**/home-manager/result" = true;
          };
          insertFinalNewline = false;
          trimFinalNewlines = false;
        };
        search = {
          exclude = {
            # Workspace
            "**/.angular" = true;
            "**/.database" = true;
            "**/node_modules" = true;
            "**/target" = true;
            "**/dist" = true;
            "**/tls" = true;
            "**/home-manager/result" = true;
          };
          followSymlinks = false;
          maxResults = 1000;
        };
        "[nix]" = {
          editor = {
            insertSpaces = true;
            tabSize = 2;
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
        # # https://marketplace.visualstudio.com/items?itemName=yy0931.vscode-sqlite3-editor
        "sqlite3-editor" = {
          "ui.minimizePanel" = true;
          telemetry = "deny";
        };
        # # https://marketplace.visualstudio.com/items?itemName=golang.Go
        go = {
          gopath = "/home/ryhkml/.go";
        };
        gopls = {
          ui.semanticTokens = true;
        };
        # #
        "gitlens.telemetry.enabled" = false;
      };
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yz";
      settings = {
        manager = {
          ratio = [ 1 5 2 ];
          sort_by = "natural";
          sort_dir_first = true;
          show_hidden = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
          image_delay = 100;
        };
        plugin = {
          prepend_fetchers = [
            {
              id    = "mime";
              "if"  = "!mime";
              name  = "*";
              run   = "mime-ext";
              prio  = "high";
            }
          ];
        };
      };
      theme = {
        filetype = {
          rules = [
            { name = "*"; fg = "#ffffff"; }
            { name = "*/"; fg = "#8ab6db"; }
          ];
        };
        icon = {
          dirs = [
            { name = "*"; text = ""; }
          ];
          exts = [
            { name = "*"; text = ""; }
          ];
          files = [
            { name = "*"; text = ""; }
          ];
        };
      };
      plugins = {
        mime-ext = "${yaziPlugins}/mime-ext.yazi";
        no-status = "${yaziPlugins}/no-status.yazi";
      };
      initLua = ''
        -- Remove status bar
        require("no-status"):setup()
        -- Mime-ext
        require("mime-ext"):setup{
          fallback_file1 = false,
        }
      '';
    };
    zoxide = {
      enable = true;
    };
  };
}
