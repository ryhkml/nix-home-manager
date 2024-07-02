## Nix Home Manager Configuration

### Installation
⚠️This is my personal best practice how to install Nix home-manager on all Linux distributions
1. Choose single-user installation, run:
	```sh
	sh <(curl -L https://nixos.org/nix/install) --no-daemon
	```
	For more information, visit [nixos.org/download](https://nixos.org/download/)

2. Add the appropriate Home Manager channel, run:
	```sh
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

	nix-channel --update
	```
	In Nix and its ecosystem, including the Nix home-manager, a channel is a way to manage and distribute sets of Nix packages and configurations. Channels are essentially collections of Nix expressions, which define packages and configurations, that are kept up to date and can be subscribed to for updates. The command above adds a channel called "home-manager", which means the package you install will get the latest version according to [search.nixos.org/packages](https://search.nixos.org/packages) (unstable).

3. Run the Home Manager installation command and create the first Home Manager generation:
	```sh
	nix-shell '<home-manager>' -A install
	```

4. Visit home.nix, run:
	```sh
	cd ~/.config/home-manager

	cat home.nix
	```

## Next Step
Visit [nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration](https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration) how to use `home-manager` command.

## Key Points About Channels
- **Collection of Packages:** A channel in Nix is a repository that contains a set of Nix expressions. These expressions define packages, configurations, and other build instructions. Each channel can be seen as a curated set of software and configurations. You can run the command below to view the channel list:
	```sh
	nix-channel --list
	```

- **Home-Manager Specifics:** In the context of home-manager, channels are used to fetch the latest configurations and package definitions for managing user environments. home-manager can be pointed to different channels to use different sets of configurations or package definitions.

Channels provide a structured way to manage and distribute package collections and configurations, keeping the environments up to date with the latest software versions and configurations, making system and environment management more efficient and reliable.