{ ... }:

let
  sources = import ../../nix/sources.nix;
  inherit (sources) home-manager;
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { ... }: {
    imports = [
      ./polybar.nix
      ./bash.nix
      ./gtk.nix
      ./dunst.nix
      ./emacs.nix
      ./keyboard.nix
      ./redshift.nix
      ./st.nix
      ./nautilus.nix
      ./i3.nix
      ./xcursor.nix
      ./school-schedule.nix
      ./nixpkgs-config.nix
      ./mpd.nix
      ./polyprog.nix
      ./weechat.nix
      ./qsynth.nix
    ];
  };
}
