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
