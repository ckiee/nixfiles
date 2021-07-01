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
      trustedUsers = [ "root" "@wheel" ];
      nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ]; # Pin the <nixpkgs> channel to our nixpkgs
      # Garbage collect and optimize
      gc = {
        automatic = true;
        options = "--delete-older-than 8d";
        dates = "weekly";
      };
      autoOptimiseStore = true;
      # Get flakes
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
