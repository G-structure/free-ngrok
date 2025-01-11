{ config, pkgs, ... }:

{

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
