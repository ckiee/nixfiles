{ lib, ... }:

with lib;

let
  sources = import ../../nix/sources.nix;
  inherit (sources) home-manager;
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager = {
    # Just incase..
    useGlobalPkgs = true;
    #
    users.ckie = { ... }: {
      imports = [
        ./polybar
        ./shell.nix
        ./gtk.nix
        ./dunst.nix
        ./keyboard
        ./redshift.nix
        ./nautilus.nix
        ./i3.nix
        ./xcursor.nix
        ./nixpkgs-config.nix
        ./mpd.nix
        ./polyprog.nix
        ./weechat.nix
        ./qsynth
        ./picom.nix
        ./mimeapps.nix
        ./remotemacs.nix
      ];
    };
  };

}
