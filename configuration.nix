{ config, pkgs, ... }:

{

  services.frp.enable = true;
  services.frp.role = "server";
  services.frp.settings = {
     bindPort = 7000;
  };

  # caddy revese proxy foo.example.com to 8080
  services.caddy = {
    enable = true;
    config = ''
      foo.flakery.xyz {
        reverse_proxy 127.0.0.1:8080
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 7000 80 443];
  networking.firewall.allowedUDPPorts = [ 7000 80 443];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
