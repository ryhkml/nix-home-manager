{ config, lib, pkgs, ... }:

let
  # A wrapper function for nix OpenGL application
  # Big thanks from https://github.com/nix-community/nixGL/issues/44
  nixgl = import <nixgl> {};
  nixglWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
    mkdir $out
    ln -s ${pkg}/* $out
    rm $out/bin
    mkdir $out/bin
    for bin in ${pkg}/bin/*; do
      wrapped_bin=$out/bin/$(basename $bin)
      echo "exec ${lib.getExe' nixgl.auto.nixGLDefault "nixGL"} $bin \"\$@\"" > $wrapped_bin
      chmod +x $wrapped_bin
    done
  '';
  # Vim plugins
  # Some Vim plugins is not available in nixpkgs
  myVimPlugin = repo: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = "HEAD";
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };
  # Angular CLI
  # Angular CLI is not available in nixpkgs
  angularCli = pkgs.stdenv.mkDerivation rec {
    pname = "static-angular-cli";
    version = "18.2.10";
    src = builtins.fetchGit {
      url = "https://github.com/ryhkml/static-angular-cli.git";
      rev = "958dbe268b4f83413cd63b67b5fcbe1b6f7ce537";
    };
    buildPhase = ''
      mkdir -p $out/bin
      ln -s ${src}/node_modules/@angular/cli/bin/ng.js $out/bin/ng
      chmod +x $out/bin/ng
    '';
    installPhase = ''
      mkdir -p $out/lib/node_modules
      cp -r ${src}/node_modules $out/lib/
    '';
  };
  # LSP for Angular is outdated in nixpkgs
  angularLanguageServer = builtins.fetchGit {
    url = "https://github.com/ryhkml/static-angular-language-server.git";
    rev = "ef8fe1eae993c4b5d4afaeab79496cf28025409d"; 
  };
  # Bun only for x86_64-linux
  # Bun version in nixpkgs is outdated
  bunBin = pkgs.stdenv.mkDerivation rec {
    pname = "bun";
    version = "1.1.33";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      sha256 = "0n58padshfgf1wrfi7mxni7m1h2hwx4w4msjz5qw8jd7snkha0m0";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    phases = [ "unpackPhase" "installPhase" ];
    unpackPhase = ''
      runHook preUnpack
      mkdir $out
      runHook postUnpack
      unzip $src -d $out
    '';
    installPhase =  ''
      runHook preInstall
      mkdir -p $out/bin
      mv $out/bun-linux-x64/bun $out/bin/bun
      chmod +x $out/bin/bun
      runHook postInstall
    ''; 
  };
  # Firebase CLI only for Linux
  # Firebase CLI version in nixpkgs is outdated
  firebaseToolsCli = pkgs.stdenv.mkDerivation rec {
    pname = "firebase-tools";
    version = "13.23.0";
    src = pkgs.fetchurl {
      url = "https://github.com/firebase/firebase-tools/releases/download/v${version}/firebase-tools-linux";
      sha256 = "092w6mf15ygsbjniv312dnid6cv9ly0mi2038dxpf1zvpa4v352a";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/firebase
      chmod +x $out/bin/firebase
    '';
  };
  # Google Cloud CLI only for x86_64-linux
  # Google Cloud CLI version in nixpkgs is outdated
  # Btw, size of Google Cloud CLI reaches ~500MB💀
  gcloudCli = pkgs.stdenv.mkDerivation rec {
    pname = "google-cloud-sdk";
    version = "498.0.0";
    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-${version}-linux-x86_64.tar.gz";
      sha256 = "0kybk4p5rbg0m9v04cn12q8dg30f0a2xw5i79640bmifrkdwsfsz";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xzf $src --strip-components=1 -C $out
      # Prevent collision between 2 LICENSE
      mv $out/LICENSE $out/share/doc/LICENSE-google-cloud-sdk
    '';
  };
  # Nodejs only for x86_64-linux
  # Nodejs version in nixpkgs is outdated
  nodejsBin = pkgs.stdenv.mkDerivation rec {
    pname = "nodejs";
    version = "22.10.0";
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
      sha256 = "0qjhnxw78p6nw63xrfi0xa8x7nkshx2nyy5b3z13pklbi9jr2rs0";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/doc
      tar -xJf $src --strip-components=1 -C $out
      # Prevent collision between 2 LICENSE
      mv $out/LICENSE $out/share/doc/LICENSE-nodejs
    '';
  };
  # Oh-my-posh only for x86_64-linux
  # Oh-my-posh version in nixpkgs is outdated
  ohMyPoshBin = pkgs.stdenv.mkDerivation rec {
    pname = "oh-my-posh";
    version = "23.20.3";
    src = pkgs.fetchurl {
      url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
      sha256 = "1w9dgpww17a7gmn3gfy3jwbyvx2x3y1smc3ygssi4770p6q4n1hq";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/oh-my-posh
      chmod +x $out/bin/oh-my-posh
    '';
  };
  # Yazi
  # Yazi plugins is not available in nixpkgs
  yaziPlugins = builtins.fetchGit {
    url = "https://github.com/yazi-rs/plugins.git";
    rev = "4f1d0ae0862f464e08f208f1807fcafcd8778e16";
  };
  #
  pathHome = builtins.getEnv "HOME";
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
      (nixglWrap brave)
      # # C
      cmus
      (curl.override {
        c-aresSupport = true;
        gsaslSupport = true;
      })
      # # D
      duf
      # # E
      exiftool
      # # F
      file
      firebaseToolsCli
      # # G
      gnuplot
      gcloudCli
      # # H
      hey
      hyperfine
      # # I
      id3v2
      imagemagick
      inlyne
      # # N
      nix-prefetch-git
      nodejsBin
      # # P
      podman-compose
      poppler
      # # S
      sqlite
      # # T
      tokei
      trash-cli
      typescript
      # # U
      ueberzugpp
      # # Y
      yt-dlp
    ];
    file = {
      ".angular-config.json".text = builtins.toJSON {
        "$schema" = "${angularCli}/lib/node_modules/@angular/cli/lib/config/schema.json";
        version = 1;
        cli = {
          completion.prompted = true;
          # Disable telemetry
          analytics = false;
        };
        projects = {};
      };
      ".bunfig.toml".text = ''
        mosl = true
        telemetry = false
        [install.cache]
        disable = true
      '';
      ".config/inlyne/inlyne.toml".text = ''
        theme = "Light"
        [font-options]
        regular-font = "FiraCode Nerd Font"
        monospace-font = "FiraCode Nerd Font"
      '';
    };
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
    };
  };

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      {
        name = "autopair";
        src = autopair.src;
      }
    ];
    shellAbbrs = {
      "/" = "cd /";
      ".." = "cd ..";
      c = "clear";
      C = "clear";
      q = "exit";
      Q = "exit";
      # Greatest abbreviations downloader ever
      dlmp3 = "yt-dlp --embed-thumbnail -o \"%(channel)s - %(title)s.%(ext)s\" -f bestaudio -x --audio-format mp3 --audio-quality 320 ?";
      dlmp4 = "yt-dlp --embed-thumbnail -S res,ext:mp4:m4a --recode mp4 ?";
      # Git
      gitpt = "set TAG_NAME (jq .version package.json -r); and git tag -s $TAG_NAME -m \"(date +'%Y/%m/%d')\"; and git push origin --tag";
      # Wifi
      getnm = "set NETWORK_NAME (nmcli -t -f NAME connection show --active | head -n 1)";
      nmwon = "nmcli radio wifi on";
      nmwoff = "nmcli radio wifi off";
      nmwconn = "nmcli device wifi connect $NETWORK_NAME";
      nmreconn = "nmcli connection down $NETWORK_NAME; and nmcli connection up $NETWORK_NAME";
      nmwscan = "nmcli device wifi rescan";
      nmwls = "nmcli device wifi list";
      nmactive = "nmcli connection show --active";
      nmup = "nmcli connection up $NETWORK_NAME";
      nmdown = "nmcli connection down $NETWORK_NAME";
      nmdnsv4-cloudflare = "nmcli connection modify $NETWORK_NAME ipv4.dns \"1.1.1.1,1.0.0.1\"";
      nmdnsv6-cloudflare = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2606:4700:4700::1111,2606:4700:4700::1001\"";
      nmdnsv4-quad9 = "nmcli connection modify $NETWORK_NAME ipv4.dns \"9.9.9.9,149.112.112.112\"";
      nmdnsv6-quad9 = "nmcli connection modify $NETWORK_NAME ipv6.dns \"2620:fe::fe,2620:fe::9\"";
      # Greatest abbreviations ever
      fv = "fd -H -I -E .angular -E .git -E node_modules | fzf --reverse | xargs -r nvim";
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
      if status is-interactive
        and not set -q TMUX
          exec tmux new-session -A -s Main
      end
      set -U fish_greeting
      set -gx DOCKER_BUILDKIT 1
      set -gx DOCKER_HOST unix:///run/user/1000/podman/podman.sock
      set -gx GOPATH $HOME/.go
      set -gx GPG_TTY (tty)
      set -gx NODE_OPTIONS --max-old-space-size=8192
    '';
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        shell = {
          program = "${config.home.profileDirectory}/bin/fish";
        };
        live_config_reload = false;
        font = {
          normal = {
            family = "FiraCode Nerd Font";
            style = "Regular";
          };
          size = 15;
        };
        colors = {
          primary.foreground = "#ffffff";
          primary.background = "#000000";
          normal.red = "#ff4d4f";
          normal.blue = "#615296";
          normal.green = "#52c41a";
          normal.yellow = "#faad14";
          normal.black = "#000000";
          normal.white = "#ffffff";
          normal.cyan = "#528796";
          normal.magenta = "#528796";
        };
        cursor = {
          style = {
            shape = "Beam";
            blinking = "Always";
          };
          blink_interval = 500;
          blink_timeout = 0;
        };
        window = {
          decorations = "None";
            padding = {
              x = 3;
              y = 3;
            };
            dynamic_padding = true;
            opacity = 0.96;
        };
        selection.save_to_clipboard = true;
      };
      package = nixglWrap pkgs.alacritty;
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
        show_battery = false;
        temp_scale = "celsius";
        update_ms = 1000;
        clock_format = "";
      };
    };
    bun = {
      enable = true;
      package = bunBin;
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
    fzf = {
      enable = true;
      changeDirWidgetCommand = "fd -t d -L 2>/dev/null";
      defaultCommand = "fd -L -H -I -E .git 2>/dev/null";
      fileWidgetCommand = "fd -L -t f -t l 2>/dev/null";
    };
    go = {
      enable = true;
      goPath = ".go";
    };
    java = {
      enable = true;
      package = pkgs.jdk22;
    };
    jq.enable = true;
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
              local options = { buffer = bufnr }
              vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", options)
              vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", options)
              vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", options)
              vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", options)
              vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", options)
              vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", options)
              vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", options)
              vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", options)
              vim.keymap.set({"n", "x"}, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", options)
              vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", options)
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
            require("lspconfig").jdtls.setup{}
            -- Nginx
            require("lspconfig").nginx_language_server.setup{}
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
                  no_ignore = true,
                  file_ignore_patterns = { ".angular", ".git", "node_modules" },
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
                "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "comment",
                "bash", "css", "dockerfile", "go", "hcl", "html", "http", "java", "javascript",
                "nginx", "nix", "scss", "sql", "pem", "toml", "typescript", "yaml", "xml",
                "gitattributes", "gitcommit", "gitignore", "git_config" 
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
          # https://github.com/slugbyte/lackluster.nvim
          plugin = myVimPlugin "slugbyte/lackluster.nvim" "6d206a3af7dd2e8389eecebab858e7d97813fc0c";
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
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require("lualine").setup({
              options = {
                theme = "lackluster",
              },
              sections = {
                lualine_x = { "filetype" },
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
      ];
      extraPackages = with pkgs; [
        # LSP and Fmt
        bash-language-server
        dockerfile-language-server-nodejs
        gopls
        jdt-language-server
        nginx-language-server
        nil
        nixpkgs-fmt
        nodePackages.vls
        shellcheck
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
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
        vim.opt.clipboard = "unnamedplus"
        -- Filetype
        local function set_filetype_conf()
          vim.bo.filetype = "conf"
        end
        local function set_filetype_dotenv()
          vim.bo.filetype = "dotenv"
        end
        vim.api.nvim_create_augroup("FiletypeConfig", { clear = true })
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
        -- Number
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
        local options = { noremap = true, silent = true }
        vim.g.mapleader = " "
        vim.keymap.set("n", "<C-z>", "<cmd>undo<CR>")
        vim.keymap.set("n", "<C-y>", "<cmd>redo<CR>")
        vim.keymap.set("n", "<leader>ee", function() vim.cmd("Ex") end)
        vim.keymap.set("n", "<leader>qa", function() vim.cmd("qa!") end)
        -- Yank/Paste/Delete
        vim.keymap.set("n", "ci", '"_ci', options)
        vim.keymap.set("n", "cw", '"_cw', options)
        vim.keymap.set("n", "di", '"_di', options)
        vim.keymap.set({ "n", "v" }, "dd", '"_dd', options)
        vim.keymap.set({ "n", "v" }, "D", '"_D', options)
        vim.keymap.set("n", "x", '"_x', options)
        vim.keymap.set("n", "X", '"_X', options)
        -- Tab
        vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", options)
        vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", options)
        --
        vim.keymap.set("i", "<C-c>", "<Esc>")
        vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", {silent = true})
        vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", {silent = true})
        -- Undotree
        vim.keymap.set("n", "<leader><F1>", vim.cmd.UndotreeToggle)
        -- Neovide config goes here
        if vim.g.neovide then
          vim.g.neovide_transparency = 0.97
          vim.g.neovide_padding_top = 0
          vim.g.neovide_padding_bottom = 0
          vim.g.neovide_padding_right = 0
          vim.g.neovide_padding_left = 0
        end
        vim.api.nvim_create_autocmd("VimLeave", {
          pattern = "*",
          callback = function()
            vim.o.guicursor = "a:ver1"
          end,
        })
        vim.o.showcmd = false
      '';
      viAlias = true;
      vimAlias = true;
    };
    neovide = {
      enable = true;
      settings = {
        fork = false;
        frame = "full";
        idle = true;
        maximized = false;
        neovim-bin = "${config.home.profileDirectory}/bin/nvim";
        no-multigrid = false;
        srgb = false;
        tabs = true;
        theme = "dark";
        title-hidden = true;
        vsync = true;
        wsl = false;
        font = {
          normal = [ "FiraCode Nerd Font" ];
          size = 15.5;
        };
      };
      package = nixglWrap pkgs.neovide;
    };
    oh-my-posh = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      package = ohMyPoshBin;
      settings = {
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
        blocks = [
          {
            alignment = "left";
            segments = [
              {
                foreground = "#615296";
                style = "plain";
                template = "# ";
                type = "root";
              }
              {
                foreground = "#ffffff";
                style = "plain";
                template = "{{ .UserName }}-{{ .HostName }} ";
                type = "session";
              }
              {
                foreground = "#615296";
                properties.style = "agnoster_short";
                style = "plain";
                template = "at {{ .Path }} ";
                type = "path";
              }
              {
                foreground = "#615296";
                properties = {
                  branch_icon = "";
                  fetch_upstream_icon = false;
                };
                style = "plain";
                template = " HEAD:{{ .UpstreamIcon }}{{ .HEAD }}";
                type = "git";
              }
            ];
            type = "prompt";
          }
          {
            alignment = "right";
            segments = [
              {
                foreground = "#615296";
                properties = {
                  threshold = 0;
                };
                style = "plain";
                template = " {{ .FormattedMs }}";
                type = "executiontime";
              }
            ];
            type = "prompt";
          }
          {
            alignment = "left";
            newline = true;
            segments = [
              {
                foreground = "#615296";
                foreground_templates = [ "{{ if gt .Code 0 }}#ff4d4f{{ end }}" ];
                properties.always_enabled = true;
                style = "plain";
                template = "> ";
                type = "status";
              }
            ];
            type = "prompt";
          }
        ];
        version = 2;
      };
    };
    ripgrep.enable = true;
    sqls = {
      enable = true;
      settings = {
        lowercaseKeywords = false;
        connections = [
          {
            driver = "sqlite3";
            dataSourceName ="${pathHome}/Documents/code/tasks-server/.database/tasks-test.db";
          }
        ];
      };
    };
    tmux = {
      enable = true;
      mouse = true;
      shortcut = "a";
      baseIndex = 1;
      disableConfirmationPrompt = true;
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
        set -s escape-time 0
        # Status bar
        set-option -g status-right ""
        # Window
        bind -n M-Right next-window
        bind -n M-Left previous-window
        bind-key -n M-S-Left swap-window -t -1\; select-window -t -1
        bind-key -n M-S-Right swap-window -t +1\; select-window -t +1
        bind-key , command-prompt "rename-window '%%'"
        # Pane
        set -g pane-active-border "fg=#615296"
        set -ag pane-active-border bg=default
        # Yazi
        set -g allow-passthrough all
        set -ag update-environment TERM
        set -ag update-environment TERM_PROGRAM
      '';
      shell = "${config.home.profileDirectory}/bin/fish";
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yz";
      settings = {
        manager = {
          ratio = [ 2 2 4 ];
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
            { name = "*/"; fg = "#526596"; }
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
          with_files = {
            config = "text/plain",
            [".env"] = "text/plain",
            [".env.development"] = "text/plain",
            [".env.example"] = "text/plain",
            [".env.local"] = "text/plain",
            [".env.production"] = "text/plain",
            [".env.test"] = "text/plain",
            ["Dockerfile"] = "text/plain",
            [".dockerignore"] = "text/plain",
            [".gcloudignore"] = "text/plain",
            [".gitattributes"] = "text/plain",
            [".gitignore"] = "text/plain",
          },
          fallback_file1 = false,
        }
      '';
    };
    zoxide.enable = true;
  };
}
