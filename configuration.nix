{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
    # set default editor to vim 
  environment.variables = { EDITOR = "nvim"; };
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.direnv.enable = true;

  systemd.services.vscode-server = {
    description = "vscode serve-web";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.User = "robertwendt";
    script = ''
      ${pkgs.vscode}/bin/code serve-web --without-connection-token --host 0.0.0.0 --port 4321 --extensions-dir /Users/robertwendt/.vscode/extensions | ${pkgs.nix}/bin/nix run github:r33drichards/fix-vscode-server ${pkgs.nodejs}/bin/node
    '';
    serviceConfig.WorkingDirectory = "/Users/robertwendt";
    serviceConfig.Environment = "PATH=${pkgs.git}/bin:${pkgs.nix}/bin:/run/current-system/sw/bin:/usr/bin:/bin";

  };



  # enable k3s
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
    "--write-kubeconfig-mode 644"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # docker socket
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];

  # make nocodb depend on create-dir
  virtualisation.oci-containers.backend = "podman";
}
