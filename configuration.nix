{ config, pkgs, ... }:

{

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

  networking.firewall.allowedTCPPorts = [ 7000 80 443 ];
  networking.firewall.allowedUDPPorts = [ 7000 80 443 ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
