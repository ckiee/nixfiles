{ lib, config, pkgs, sources, ... }:

let cfg = config.cookie.nix;
in with lib; {
  options.cookie.nix = { enable = mkEnableOption "Configures Nix"; };

  config = mkIf cfg.enable {
    # Setup the symlink for our global nixpkgs
    environment.extraSetup = ''
      ln -s ${sources.nixpkgs} $out/nixpkgs
    '';

    nix = {
      settings = {
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;
        experimental-features = "nix-command flakes";
      };
      nixPath = [
        "nixpkgs=/run/current-system/sw/nixpkgs"
      ]; # Pin the <nixpkgs> channel to our nixpkgs
      # Garbage collect and optimize
      gc = {
        automatic = true;
        options = "--delete-older-than 8d";
        dates = "weekly";
      };
      # Get flakes
      package = pkgs.nixUnstable;
      registry.nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = {
          type = "path";
          # also done in ~/git/nixpkgs/nixos/modules/installer/cd-dvd/channel.nix
          # for the installer host (which is flashed onto a usb flash drive)
          # ..so we have to lower priority for this:
          path = mkDefault (if isStorePath sources.nixpkgs.outPath then
            "${lib.cleanSource sources.nixpkgs}"
          else
            toString sources.nixpkgs.outPath);
        };
      };
    };
  };
}
