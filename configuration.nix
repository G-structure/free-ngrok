{ config, pkgs, ... }:

{
  # Enable Flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [ cloud-utils ];

  services.frp.enable = true;
  services.frp.role = "server";

  services.frp.settings = { bindPort = 7000; };

  environment.etc."keycloak-database-pass".text = "PWD";
  services.postgresql.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "rwendt1337@gmail.com";
    certs = {
      "flakery.xyz" = {
        domain = "keycloak.flakery.xyz";
        webroot = "/var/lib/acme/acme-challenge/";
        email = "rwendt1337@gmail.com";
      };
    };
  };

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "keycloak.flakery.xyz";
      ssl-certificate-path = "/var/lib/acme/flakery.xyz/cert.pem";
      ssl-certificate-key-path = "/var/lib/acme/flakery.xyz/key.pem";
    };

    database = {
      type = "postgresql";
      createLocally = true;
      username = "keycloak";
      passwordFile = "/etc/keycloak-database-pass";
    };
    initialAdminPassword = "admin"; # Change this in production!

  };

  # caddy revese proxy foo.example.com to 8080
  services.caddy = {
    enable = true;
    extraConfig = ''
      foo.flakery.xyz {
        reverse_proxy 127.0.0.1:8080
      }
    '';
  };
 
  # tod0 add backl 7000 when auth is working
  networking.firewall.allowedTCPPorts = [  80 443 22 ];
  networking.firewall.allowedUDPPorts = [  80 443 22 ];

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
