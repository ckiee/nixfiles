{ lib, config, pkgs, ... }:

let cfg = config.cookie.nix;
in with lib; {
  options.cookie.nix = { enable = mkEnableOption "Configures Nix"; };

  config = mkIf cfg.enable {
    # Setup the symlink for our global nixpkgs
    environment.extraSetup = ''
      ln -s ${pkgs.path} $out/nixpkgs
    '';

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 8d";
        dates = "weekly";
      };
      autoOptimiseStore = true;
      trustedUsers = [ "root" "@wheel" ];
      nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
    };
  };
}
