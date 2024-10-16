{ lib, pkgs, ... }:

let
  # Build my own function clone from Github
  cloneFromGitHub = repo: ref: builtins.fetchGit {
    url = "https://github.com/${repo}.git";
    ref = ref;
  };
  # Build my own function for vim plugins
  # Some vim plugins is not available in nixpkgs
  myVimPlugin = repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = "HEAD";
    src = cloneFromGitHub repo "HEAD";
  };
  # Angular
  # Angular CLI is not available in nixpkgs
  angularCli = pkgs.stdenv.mkDerivation rec {
    pname = "static-angular-cli";
    version = "18.2.8";
    src = cloneFromGitHub "ryhkml/static-angular-cli" "HEAD";
    buildPhase = ''
      mkdir -p $out/bin
      ln -s ${src}/node_modules/@angular/cli/bin/ng.js $out/bin/ng
      chmod +x $out/bin/ng
    '';
  };
  # LSP for Angular is outdated in nixpkgs
  angularLanguageServer = cloneFromGitHub "ryhkml/static-angular-language-server" "HEAD";
  # Yazi
  # Yazi plugins is not available in nixpkgs
  yaziPlugins = cloneFromGitHub "yazi-rs/plugins" "HEAD";
in
{
  nixpkgs.config.allowUnfree = true;
  
  home = {
    username = "ryhkml";
    homeDirectory = "/home/ryhkml";
    stateVersion = "24.05";
    packages = with pkgs; [
      # # A
      angularCli
      # # B
      bash-language-server
      # # C
      cmus
      (curl.override {
        c-aresSupport = true;
        gsaslSupport = true;
      })
      # # D
      dockerfile-language-server-nodejs
      duf
      # # E
      exiftool
      # # F
      file
      firebase-tools
      # # G
      gnuplot
      gopls
      google-cloud-sdk
      # # H
      hey
      hyperfine
      # # I
      id3v2
      imagemagick
      # # J
      java-language-server
      jdk22
      jq
      # # N
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
      # # V
      vscode-langservers-extracted
      # # Y
      yaml-language-server
      yt-dlp
    ];
    file = {};
    sessionVariables = {};
  };

  programs = {
    home-manager.enable = true;
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
        color_theme = "adapta";
        show_battery = false;
        temp_scale = "celsius";
        update_ms = 1000;
        clock_format = "";
      };
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
    fd = {
      enable = true;
      hidden = true;
      ignores = [ ".git/" ".angular/" ".database/" "node_modules/" "target/" ];
      extraOptions = [ "-tf" ];
    };
    fish = {
      enable = true;
      shellAbbrs = {
        "/" = "cd /";
        ".." = "cd ..";
        c = "clear";
        C = "clear";
        q = "exit";
        Q = "exit";
        # Greatest abbreviations downloader ever
        dlmp3 = "yt-dlp --embed-thumbnail -o \"%(channel)s - %(title)s.%(ext)s\" -f bestaudio -x --audio-format mp3 --audio-quality 320 URL";
        dlmp4 = "yt-dlp --embed-thumbnail -S res,ext:mp4:m4a --recode mp4 URL";
        # Git
        gitpt = "set tag_name (jq .version package.json -r); and git tag -s $tag_name -m \"(date +'%Y/%m/%d')\"; and git push origin --tag";
        # Wifi
        nmwon = "nmcli radio wifi on";
        nmwoff = "nmcli radio wifi off";
        nmwconn = "nmcli device wifi connect NETWORK_NAME";
        nmreconn = "set net_name NETWORK_NAME; and nmcli connection down $net_name; and sleep 0.1; and nmcli connection up $net_name";
        nmwscan = "nmcli device wifi rescan";
        nmwls = "nmcli device wifi list";
        nmactive = "nmcli connection show --active";
        nmup = "nmcli connection up NETWORK_NAME";
        nmdown = "nmcli connection down NETWORK_NAME";
        nmdnsv4-cloudflare = "nmcli connection modify NETWORK_NAME ipv4.dns \"1.1.1.1,1.0.0.1\"";
        nmdnsv6-cloudflare = "nmcli connection modify NETWORK_NAME ipv6.dns \"2606:4700:4700::1111,2606:4700:4700::1001\"";
        nmdnsv4-quad9 = "nmcli connection modify NETWORK_NAME ipv4.dns \"9.9.9.9,149.112.112.112\"";
        nmdnsv6-quad9 = "nmcli connection modify NETWORK_NAME ipv6.dns \"2620:fe::fe,2620:fe::9\"";
        # Neovide
        nv = "fd | fzf --reverse | xargs -r neovide";
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
            -- https://github.com/lewis6991/gitsigns.nvim
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
            -- https://github.com/lukas-reineke/indent-blankline.nvim
            require("ibl").setup{
              debounce = 100,
              indent = {
                char = "·",
              },
              scope = {
                enabled = false,
              },
            }
          '';
        }
        lsp-zero-nvim
        nvim-lspconfig
        nvim-cmp
        {
          plugin = cmp-nvim-lsp;
          type = "lua";
          config = ''
            -- https://github.com/neovim/nvim-lspconfig
            local lsp_zero = require("lsp-zero")
            local lsp_attach = function(client, bufnr)
              local opts = {buffer = bufnr}
              vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
              vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
              vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
              vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
              vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
              vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
              vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
              vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
              vim.keymap.set({"n", "x"}, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
              vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
            end
            lsp_zero.extend_lspconfig({
              sign_text = true,
              lsp_attach = lsp_attach,
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
            -- Angular
            local cmd = {
              "${angularLanguageServer}/node_modules/.bin/ngserver",
              "--stdio",
              "--tsProbeLocations",
              "${angularLanguageServer}/node_modules",
              "--ngProbeLocations",
              "${angularLanguageServer}/node_modules",
            }
            require("lspconfig").angularls.setup{
              cmd = cmd,
              on_new_config = function(new_config, new_root_dir)
                new_config.cmd = cmd
              end,
            }
            -- Bash
            require("lspconfig").bashls.setup{}
            -- CSS
            require("lspconfig").cssls.setup{}
            -- Dockerfile
            require("lspconfig").dockerls.setup{}
            -- Go
            require("lspconfig").gopls.setup{}
            -- HTML
            require("lspconfig").html.setup{}
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
            -- https://github.com/hrsh7th/nvim-cmp
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
            -- https://github.com/nvim-telescope/telescope.nvim
            require("telescope").setup{
              pickers = {
                find_files = {
                  hidden = true,
                },
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
                "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
                "bash", "css", "dockerfile", "go", "html", "java", "javascript",
                "nix", "sql", "typescript", "yaml",
              },
              sync_install = false,
              auto_install = true,
              parser_install_dir = dir_parser,
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
              indent = {
                enable = true
              }
            }
          '';
        }
        {
          plugin = vim-closetag;
          config = ''
            let g:closetag_filenames = "*.html,*.xhtml"
            let g:closetag_xhtml_filenames = "*.xhtml"
            let g:closetag_filetypes = "html,xhtml"
            let g:closetag_xhtml_filetypes = "xhtml"
            let g:closetag_emptyTags_caseSensitive = 1
            let g:closetag_shortcut = ">"
            let g:closetag_close_shortcut = "<leader>>"
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
          plugin = myVimPlugin "slugbyte/lackluster.nvim";
          type = "lua";
          config = ''
            local lackluster = require("lackluster")
            lackluster.setup({
              tweak_color = {
                lack = "default",
                luster = "default",
                orange = "default",
                yellow = "default",
                green = "default",
                blue = "default",
                read = "default",
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
                virtualtext = "■",
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
        -- Cursor
        vim.opt.guicursor = {
          "n-v-c:block-Cursor/lCursor",
          "i-ci-ve:ver25-Cursor/lCursor",
          "r-cr:hor20",
          "o:hor50",
        }
        vim.opt.nu = true
        vim.opt.cursorline = true
        vim.opt.cursorlineopt = "number"
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
        vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
        vim.opt.undofile = true
        vim.opt.termguicolors = false
        vim.opt.updatetime = 50
        --
        vim.g.mapleader = " "
        vim.keymap.set("n", "<C-z>", "<cmd>undo<CR>")
        vim.keymap.set("n", "<C-y>", "<cmd>redo<CR>")
        vim.keymap.set("n", "<leader>ee", function() vim.cmd("Ex") end)
        vim.keymap.set("n", "<leader>qa", function() vim.cmd("qa!") end)
        -- Tab
        vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", {noremap = true, silent = true})
        vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", {noremap = true, silent = true})
        -- Yank
        vim.keymap.set({"n", "x"}, "<leader>p", [["0p]])
        vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
        vim.keymap.set("n", "<leader>Y", [["+Y]])
        -- Duplicate
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
          vim.g.neovide_transparency = 0.95
          vim.g.neovide_padding_top = 0
          vim.g.neovide_padding_bottom = 0
          vim.g.neovide_padding_right = 0
          vim.g.neovide_padding_left = 0
        end
        -- Copy/Paste
        vim.o.clipboard = "unnamedplus"
        vim.api.nvim_set_keymap("n", "<C-S-c>", '"+yy', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("n", "<C-S-v>", '""_dP', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("v", "<C-S-c>", '"+y', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("v", "<C-S-v>", '""_dP', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("i", "<C-S-v>", '<C-r>+', {noremap = true, silent = true})
        vim.api.nvim_set_keymap("i", "<C-S-c>", '<Esc>"+yyi', {noremap = true, silent = true})
        -- End
        vim.o.showcmd = false
      '';
      viAlias = true;
      vimAlias = true;
    };
    oh-my-posh = {
      enable = true;
      useTheme = "xtoys";
    };
    ripgrep.enable = true;
    tmux = {
      enable = true;
      mouse = true;
      shortcut = "a";
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = yank;
          extraConfig = ''
            set -g @yank_selection_mouse "clipboard"
          '';
        }
        {
          plugin = nord;
        }
      ];
      extraConfig = ''
        # Status bar
        set-option -g status-right ""
        # Window
        bind -n M-Right next-window
        bind -n M-Left previous-window
        bind-key -n M-S-Left swap-window -t -1\; select-window -t -1
        bind-key -n M-S-Right swap-window -t +1\; select-window -t +1
      '';
      shell = "/home/ryhkml/.local/bin/fish-login";
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
    zoxide.enable = true;
  };
}
