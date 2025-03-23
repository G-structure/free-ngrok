{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
    # set default editor to vim 
  environment.variables = { EDITOR = "nvim"; };
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
 
 services.frp.enable = true;
 services.frp.settings = {
   serverPort = 7000;
 };

  networking.firewall.allowedTCPPorts = [
    7000
  ];
  networking.firewall.allowedUDPPorts = [
    7000
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
