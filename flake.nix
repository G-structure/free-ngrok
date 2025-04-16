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
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        frpcConfig = ./frpc.toml;
      in
      {

      packages = {
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
              imports = [ "${modulesPath}/virtualisation/google-compute-image.nix" ];
            })
            ./configuration.nix 
          ];
        };
        default = self.packages.${system}.reverse-proxy;
      };
      nixosConfigurations = {
        reverse-proxy-gcp = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs.inputs = inputs;
          modules = [ /etc/nixos/configuration.nix ./configuration.nix ];
        };
      };




      apps = {
        reverse-proxy-client = flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "frpc";
            text = ''
              ${pkgs.frp}/bin/frpc -c ${frpcConfig}
            '';
          };
        };
      };
    });
}
