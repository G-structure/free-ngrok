{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-generators = {
    url = "github:nix-community/nixos-generators";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-generators, ... }:
    {
      reverse-proxy = nixpkgs.lib.nixosSystem
        {
          system = "x86_64-linux";
          modules = [
            ({ modulesPath, ... }: {
              imports = [
                "${modulesPath}/virtualisation/amazon-image.nix"
              ];
            })
            ./configuration.nix
          ];
        };
    };
}
