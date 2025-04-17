{ config, pkgs, ... }:

{
  # Enable Flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.frp.enable = true;
  services.frp.role = "server";

  services.frp.settings = { bindPort = 7000; };

  environment.etc."keycloak-database-pass".text = "PWD";
  services.keycloak = {
    enable = true;
    settings = {
      http-port = 8888;
      http-host = "127.0.0.1";
      hostname = "localhost";
      http-enabled = true;
      hostname-strict-https = false;
    };
    database.passwordFile = "/etc/keycloak-database-pass";
    initialAdminPassword = "admin"; # Change this in production!

  };

  # caddy revese proxy foo.example.com to 8080
  services.caddy = {
    enable = true;
    extraConfig = ''
      foo.flakery.xyz {
        reverse_proxy 127.0.0.1:8080
      }
      keycloak.flakery.xyz {
        reverse_proxy 127.0.0.1:8888
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 7000 80 443 22 ];
  networking.firewall.allowedUDPPorts = [ 7000 80 443 22 ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  users.users.f = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAP8SjrX4AUD65sOxlfRqGoWeKp1LH4O9E68STTNFQ1 f@fs-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9tjvxDXYRrYX6oDlWI0/vbuib9JOwAooA+gbyGG/+Q robertwendt@Roberts-Laptop.local"
    ];

  };
  # allow no password sudo for f
  security.sudo.extraConfig = ''
    f ALL=(ALL) NOPASSWD:ALL
  '';

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

}
