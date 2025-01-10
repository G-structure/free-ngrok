{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }: {
    nixosConfigurations.reverse-proxy = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./nixos-configuration.nix
      ];
    };

    packages.x86_64-linux = {
      reverse-proxy = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
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
  };
}
