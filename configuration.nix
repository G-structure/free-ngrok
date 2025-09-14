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

  services.frp.settings = {
    bindPort = 7000;
    auth.method = "oidc";
    auth.oidc.issuer = "https://token.actions.githubusercontent.com";
    auth.oidc.audience = "https://github.com/G-Structure";  # Adjust to your repo or org
  };

  # caddy reverse proxy foo.dreamshell.org to 8080
  services.caddy = {
    enable = true;
    extraConfig = ''
      foo.dreamshell.org {
        reverse_proxy 127.0.0.1:8080
      }
    '';
  };

  # tod0 add backl 7000 when auth is working
  networking.firewall.allowedTCPPorts = [ 7000 80 443 22 ];
  networking.firewall.allowedUDPPorts = [ 7000 80 443 22 ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  users.users.luc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILtZ+LOOnBIm4aSr0zgqEFxNYUnLNEEtkFDC1TWicYQh luc@sanative.ai"
    ];

  };
  # allow no password sudo for luc
  security.sudo.extraConfig = ''
    luc ALL=(ALL) NOPASSWD:ALL
  '';

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

}
