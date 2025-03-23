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
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        reverse-proxy = nixos-generators.nixosGenerate {
          inherit system;
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
        default = self.packages.${system}.reverse-proxy;
      };
    }) // {
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
    };
}
