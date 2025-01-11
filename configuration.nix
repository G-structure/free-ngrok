{ config, pkgs, ... }:

{

  systemd.services.vscode-server = {
    description = "vscode serve-web";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.User = "alice";
    script = ''
      ${pkgs.vscode}/bin/code serve-web --without-connection-token --host 0.0.0.0 --port 4321 --extensions-dir /home/alice/.vscode/extensions | ${pkgs.nix}/bin/nix run github:r33drichards/fix-vscode-server ${pkgs.nodejs}/bin/node
      # useful for debugging
      # ${pkgs.nix}/bin/nix run /home/alice/fix-vscode-server ${pkgs.nodejs}/bin/node

    '';
    serviceConfig.WorkingDirectory = "/home/alice";
    serviceConfig.Environment = "PATH=${pkgs.git}/bin:${pkgs.nix}/bin:/run/current-system/sw/bin:/usr/bin:/bin";

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
