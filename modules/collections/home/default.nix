{ ... }:

let
  sources = import ../../../nix/sources.nix;
  inherit (sources) home-manager;
in {
  home-manager.users.ron = { ... }: {
    imports = [
      ./devel.nix
    ];
  };
}
