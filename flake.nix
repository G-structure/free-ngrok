{ config, pkgs, ... }:

{
  packages.reverse-proxy = nixos-generators.nixosGenerate {
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
}
