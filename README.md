## Nix Home Manager Configuration

### Installation
> [!WARNING]
>
> This is my personal best practice how to install Nix home-manager on all Linux distributions, except immutable Linux distributions.
>
> If you are using an immutable distribution, visit this [repository](https://github.com/DeterminateSystems/nix-installer).

1. Choose single-user installation, run:
	```sh
	sh <(curl -L https://nixos.org/nix/install) --no-daemon
	```
	For more information, visit [nixos.org/download](https://nixos.org/download/)

2. Add the appropriate home manager channel, run:
	```sh
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && nix-channel --update
	```

	Make sure you use the unstable nixpkgs channel as well, run:
	```sh
	nix-channel --list
	```

	The response should be:
	```sh
	home-manager https://github.com/nix-community/home-manager/archive/master.tar.gz
	nixpkgs https://nixos.org/channels/nixpkgs-unstable
	```
	
	In the Nix ecosystem, which includes the Nix home-manager, a channel refers to a method for managing and distributing collections of Nix packages and configurations. Channels are essentially repositories of Nix expressions that define both packages and configurations. These channels are regularly updated, allowing users to subscribe to them to receive the latest updates. The mentioned command adds a channel named "home-manager", indicating that any package installed through this channel will be updated to the latest version available, as per the unstable branch listed on [search.nixos.org/packages](https://search.nixos.org/packages).

3. Run the home manager installation command and create the first home manager generation:
	```sh
	nix-shell '<home-manager>' -A install
	```

4. Check home.nix configuration, run:
	```sh
	cat ~/.config/home-manager/home.nix
	```

## Next Step
Visit [nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration](https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration) how to use `home-manager` command.