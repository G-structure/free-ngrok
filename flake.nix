{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, flake-utils, ... }@inputs:
    let
      system = "aarch64-linux";
    in
    {
      nixosConfigurations = {
        test = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs.inputs = inputs;
          modules = [
            /etc/nixos/configuration.nix
            ./configuration.nix
          ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (host: {
      packages.${host} = {
        reverse-proxy = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "amazon";
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                "${modulesPath}/virtualisation/amazon-image.nix"
              ];
            })
            ./configuration.nix
            ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
          ];
        };
      };
    });
}
