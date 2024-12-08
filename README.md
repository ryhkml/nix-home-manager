## Nix Home Manager

### Motivation

Nix Home Manager can be enjoyable and comfortable, even though it can be a bit tricky to learn initially, the benefits make it worthwhile.
With Nix Home Manager, I can keep all my configuration settings in a single file instead of having many separate dotfiles.
This makes managing my setup much easier and ensures everything works smoothly across different Linux distributions.
I believe Nix Home Manager is a great tool for managing personal configurations. It helps me stay organized and allows me to easily share my setup.
I invite you to try it out and see how it can make your life easier too!

### Installation

> [!NOTE]
>
> This is my personal best practice how to install Nix Home Manager on all Linux distributions, except immutable distributions.
>
> If you are using an immutable distribution, visit [here](https://github.com/DeterminateSystems/nix-installer).

1. Choose single-user installation, run:

    ```sh
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    . "$HOME"/.nix-profile/etc/profile.d/nix.sh
    ```

    For more information, visit [nixos.org/download](https://nixos.org/download/)

2. Add Home Manager channel, run:

    ```sh
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
    nix-channel --update
    ```

    In the Nix ecosystem, which includes the Nix Home Manager, a channel refers to a method for managing and distributing collections of Nix packages and configurations.
    Channels are essentially repositories of Nix expressions that define both packages and configurations. These channels are regularly updated, allowing users to subscribe to them to receive the latest updates.
    The mentioned command adds a channel named "home-manager", indicating that any package installed through this channel will be updated to the latest version available, as per the unstable branch listed on [search.nixos.org/packages](https://search.nixos.org/packages). For the channel called “nixgl”, you can visit [here](https://github.com/nix-community/nixGL).

3. Run the Home Manager installation command and create the first Home Manager generation:

    ```sh
    nix-shell '<home-manager>' -A install
    echo ". \"\$HOME\"/.nix-profile/etc/profile.d/nix.sh" | tee -a $HOME/.bashrc > /dev/null
    source $HOME/.bashrc
    ```

4. Check home.nix configuration, run:
    ```sh
    cat ~/.config/home-manager/home.nix
    ```

### Next Step

Visit [configuration example](https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration), how to use `home-manager` command.

### Packages

The installed packages include the desktop application, command line interface, Language Server Protocol, and plugins of the package itself.

#### A

1. [alacritty](https://alacritty.org) - A cross-platform OpenGL terminal emulator
1. [angular-language-server](https://github.com/angular/vscode-ng-language-service) - LSP for Angular
1. [astyle](https://astyle.sourceforge.net) - Formatter for C, C++, C++/CLI, Objective-C, C#, and Java

#### B

1. [bat](https://github.com/sharkdp/bat) - Alternative to `cat`
1. [bash-language-server](https://github.com/bash-lsp/bash-language-server) - LSP for Bash
1. [beautysh](https://github.com/lovesegfault/beautysh) - Formatter for Shell
1. [brave](https://brave.com) - Brave browser
1. [bun](https://bun.sh) - Javascript runtime, bundler, test runner, and package manager
1. [btop](https://github.com/aristocratos/btop) - A monitor of resources

#### C

1. [cmus](https://cmus.github.io) - Console music player for Unix-like operating systems
1. [curl](https://curl.se) - You know, right?

#### D

1. [direnv](https://direnv.net) - Unclutter your .profile
1. [dockerfile-language-server-nodejs](https://github.com/rcjsuen/dockerfile-language-server) - LSP for Dockerfile
1. [duf](https://github.com/muesli/duf) - Disk usage or free utility. A better `df` alternative

#### E

1. [editorconfig](https://editorconfig.org) - Enforces consistent coding styles across editors and IDEs
1. [exiftool](https://exiftool.org) - Meta information reader or writer
1. [eza](https://eza.rocks) - A modern alternative to `ls`

#### F

1. [fastfetch](https://github.com/fastfetch-cli/fastfetch) - Neofetch like system information tool
1. [fd](https://github.com/sharkdp/fd) - Alternative to `find`
1. [file](https://darwinsys.com/file) - Shows the type of files
1. [firebase](https://firebase.google.com/docs/cli) - Firebase CLI
1. [fish](https://fishshell.com) - User friendly command line shell
1. [fishPlugins.autopair](https://github.com/jorgebucaran/autopair.fish) - Auto complete matching pairs in the fish command line
1. [fzf](https://github.com/junegunn/fzf) - Command line fuzzy finder

#### G

1. [gnuplot](https://www.gnuplot.info) - Portable command line driven graphing utility for many platforms
1. [go](https://go.dev) - You know, right?
1. [gcloud](https://cloud.google.com/sdk/docs/install) - Google Cloud CLI
1. [gopls](https://github.com/golang/tools/tree/master/gopls) - LSP for Go

#### H

1. [hey](https://github.com/rakyll/hey) - HTTP load generator, ApacheBench (ab) replacement
1. [hyperfine](https://github.com/sharkdp/hyperfine) - Command line benchmarking tool

#### I

1. [id3v2](https://id3v2.sourceforge.net) - Command line editor for id3v2 tags

#### J

1. [java](https://openjdk.java.net) - Open-source Java Development Kit
1. [jdt-language-server](https://github.com/eclipse/eclipse.jdt.ls) - LSP for Java
1. [jq](https://jqlang.github.io/jq) - Lightweight and flexible command line JSON processor

#### L

1. [lazydocker](https://github.com/jesseduffield/lazydocker) - The lazier way to manage everything docker
1. [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git commands

#### N

1. [neovim](https://www.neovim.io) - You gotta know this, right?
1. [ng](https://angular.dev/tools/cli) - Angular CLI
1. [nginx-language-server](https://github.com/pappasam/nginx-language-server) - LSP for nginx.conf
1. [nil](https://github.com/oxalica/nil) - Yet another LSP for Nix
1. [nixgl](https://github.com/nix-community/nixGL) - A wrapper tool for Nix OpenGL application
1. [nix-prefetch-git](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix-prefetch-scripts/default.nix) - Script used to obtain source hashes for fetchgit
1. [nixfmt-rfc-style](https://github.com/NixOS/nixfmt) - Formatter for Nix
1. [nodejsBin](https://nodejs.org/en) - Event-driven I/O framework for the V8 Javascript engine
1. [nodePackages.prettier](https://prettier.io) - Prettier is an opinionated code formatter
1. [nodePackages.vls](https://github.com/vuejs/vetur/tree/master/server) - LSP for Vue
1. [noisetorch](https://github.com/noisetorch/NoiseTorch) - Virtual microphone device with noise supression for PulseAudio

#### P

1. [podman-compose](https://github.com/containers/podman-compose) - Implementation of docker-compose with podman backend

#### R

1. [ripgrep](https://github.com/BurntSushi/ripgrep) - Searcher with the raw speed of grep
1. [rustup](https://www.rustup.rs) - Rust toolchain installer
1. [rust-analyzer](https://rust-analyzer.github.io) - Modular compiler frontend for the Rust language
1. [rustfmt](https://github.com/rust-lang-nursery/rustfmt) - Formatter for Rust

#### S

1. [shellcheck](https://hackage.haskell.org/package/ShellCheck) - Shell script analysis tool
1. [sleek](https://github.com/nrempel/sleek) - Formatter for SQL
1. [stylua](https://github.com/johnnymorganz/stylua) - Formatter for Lua
1. [sqlite](https://www.sqlite.org) - You know, right?
1. [sqls](https://github.com/sqls-server/sqls) - LSP for SQL

#### T

1. [tokei](https://github.com/XAMPPRocky/tokei) - Count your code quickly
1. [trash-cli](https://github.com/andreafrancia/trash-cli) - Command line interface to the freedesktop.org trashcan
1. [typescript](https://www.typescriptlang.org) - You know, right?
1. [typescript-language-server](https://github.com/typescript-language-server/typescript-language-server) - LSP for Typescript using tsserver

#### V

1. [vscode-langservers-extracted](https://github.com/hrsh7th/vscode-langservers-extracted) - LSP extracted from Vscode for HTML/CSS/JSON/ESLint

#### Y

1. [yamlfmt](https://github.com/google/yamlfmt) - Formatter for YAML
1. [yaml-language-server](https://github.com/redhat-developer/yaml-language-server) - LSP for YAML
1. [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Command line tool to download videos from Youtube and other sites

#### Z

1. [zellij](https://zellij.dev) - A terminal workspace
1. [zoxide](https://github.com/ajeetdsouza/zoxide) - Fast `cd` that learns your habits
