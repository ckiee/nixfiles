{ sources, lib, ... }:

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
      _module.args.sources = sources;
      imports = [
        ./polybar
        ./shell.nix
        ./gtk.nix
        ./dunst.nix
        ./keyboard
        ./redshift.nix
        ./nautilus.nix
        ./i3
        ./xcursor.nix
        ./nixpkgs-config.nix
        ./polyprog.nix
        ./weechat.nix
        ./qsynth
        ./picom.nix
        ./mimeapps.nix
        ./remotemacs.nix
        ./st
        ./screen-locker.nix
        ./toot
        ./mangohud.nix
      ];
    };
  };

}
