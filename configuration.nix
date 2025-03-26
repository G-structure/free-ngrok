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

  systemd.services.assign-eip = {
    description = "Assign Elastic IP to instance";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ awscli2 curl ];
    script = ''
      ELASTIC_IP="35.155.79.59"
      INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
      ALLOCATION_ID=$(aws ec2 describe-addresses --public-ips $ELASTIC_IP --query 'Addresses[0].AllocationId' --output text)
      ASSOCIATION_ID=$(aws ec2 describe-addresses --public-ips $ELASTIC_IP --query 'Addresses[0].AssociationId' --output text)

      if [ "$ASSOCIATION_ID" != "None" ]; then
        echo "Elastic IP is already associated with another instance. Disassociating..."
        aws ec2 disassociate-address --association-id "$ASSOCIATION_ID"
      fi

      aws ec2 associate-address --instance-id "$INSTANCE_ID" --allocation-id "$ALLOCATION_ID"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RestartSec = 32;
      Restart = "on-failure";
    };
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

  networking.firewall.allowedTCPPorts = [ 7000 80 443 22 ];
  networking.firewall.allowedUDPPorts = [ 7000 80 443 22 ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  users.users.f = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAP8SjrX4AUD65sOxlfRqGoWeKp1LH4O9E68STTNFQ1 f@fs-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9tjvxDXYRrYX6oDlWI0/vbuib9JOwAooA+gbyGG/+Q robertwendt@Roberts-Laptop.local"
    ];

  };

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

}
