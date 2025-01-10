{ config, pkgs, ... }:

{
  system.stateVersion = "23.05";

  # File system configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Boot loader configuration
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];  # Specify your boot device
    version = 2;
  };

  services.caddy = {
    enable = true;
    virtualHosts."nixos.jjk.is" = {
      extraConfig = ''
        respond "Hello World"
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
