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
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      frpcConfig = ./frpc.toml;
    in {
      nixosConfigurations = {
        "reverse-proxy-gcp" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ({ modulesPath, ... }: {
              imports =
                [ "${modulesPath}/virtualisation/google-compute-image.nix" ];
            })
            ./configuration.nix
          ];
        };
      };

      packages.${system} = {
        reverse-proxy = nixos-generators.nixosGenerate {
          inherit system;
          format = "amazon";
          modules = [
            ({ modulesPath, ... }: {
              imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
            })
            ./configuration.nix
            ({ ... }: { amazonImage.sizeMB = 16 * 1024; })
          ];
        };
        reverse-proxy-gcp = nixos-generators.nixosGenerate {
          inherit system;
          format = "gce";
          modules = [
            ({ modulesPath, ... }: {
              imports =
                [ "${modulesPath}/virtualisation/google-compute-image.nix" ];
            })
            ./configuration.nix
          ];
        };
        default = self.packages.${system}.reverse-proxy;
      };

      apps.${system} = {
        reverse-proxy-client = flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "frpc";
            text = ''
              ${pkgs.frp}/bin/frpc -c ${frpcConfig}
            '';
          };
        };
      };
    };
}
