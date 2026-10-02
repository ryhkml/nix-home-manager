{
  description = "Home Manager configuration for ryhkml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Neovim 0.11.x plus its plugin and vimUtils set. nixpkgs-unstable is already
    # on 0.12.x, and plugins must come from the same source as the editor they
    # are built against.
    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    # vscode-langservers-extracted 4.10.0: last commit before nixpkgs switched to
    # extracting from vscodium, which ships json/css servers that crash on start.
    nixpkgs-langservers.url = "github:NixOS/nixpkgs/ff77533172372be5d4b8566100c73e96d9c57a50";

    # Ghostty, bumped independently of the main nixpkgs input.
    nixpkgs-ghostty.url = "github:NixOS/nixpkgs/624af665418d3c65d544145b4d34ad696439570e";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      # x86_64 only: bun, codegraph, gcloud, nodejs and rtk all fetch linux-x64
      # release binaries.
      system = "x86_64-linux";
      mkPkgs =
        src:
        import src {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      homeConfigurations."ryhkml" = home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs nixpkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit (inputs) nixgl;
          pkgs2511 = mkPkgs inputs.nixpkgs-2511;
          pkgsLangservers = mkPkgs inputs.nixpkgs-langservers;
          pkgsGhostty = mkPkgs inputs.nixpkgs-ghostty;
        };
      };
    };
}
