## Nix Home Manager Configuration

### Installation
> [!WARNING]
> This is my personal best practice how to install Nix home-manager on all Linux distributions, except immutable Linux distributions

1. Choose single-user installation, run:
	```sh
	sh <(curl -L https://nixos.org/nix/install) --no-daemon
	```
	For more information, visit [nixos.org/download](https://nixos.org/download/)

2. Add the appropriate Home Manager channel, run:
	```sh
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update
	```
	> [!IMPORTANT]
	> Make sure you use the unstable nixpkgs channel as well

	```sh
	home-manager https://github.com/nix-community/home-manager/archive/master.tar.gz
	nixpkgs https://nixos.org/channels/nixpkgs-unstable
	```
	In the Nix ecosystem, which includes the Nix home-manager, a channel refers to a method for managing and distributing collections of Nix packages and configurations. Channels are essentially repositories of Nix expressions that define both packages and configurations. These channels are regularly updated, allowing users to subscribe to them to receive the latest updates. The mentioned command adds a channel named "home-manager", indicating that any package installed through this channel will be updated to the latest version available, as per the unstable branch listed on [search.nixos.org/packages](https://search.nixos.org/packages).

3. Run the Home Manager installation command and create the first Home Manager generation:
	```sh
	nix-shell '<home-manager>' -A install
	```

4. Done, you can check home.nix:
	```sh
	cat ~/.config/home-manager/home.nix
	```

## Next Step
Visit [nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration](https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration) how to use `home-manager` command.

## Key Points About Channels
- **Collection of Packages:** A channel in Nix is a repository that contains a set of Nix expressions. These expressions define packages, configurations, and other build instructions. Each channel can be seen as a curated set of software and configurations. You can run the command below to view the channel list:
	```sh
	nix-channel --list
	```

- **Home-Manager Specifics:** In the context of home-manager, channels are used to fetch the latest configurations and package definitions for managing user environments. home-manager can be pointed to different channels to use different sets of configurations or package definitions.

Channels offer an organized method to handle and distribute package collections and configurations. They ensure that environments are updated with the latest software versions and settings, thereby enhancing the efficiency and reliability of system and environment management.