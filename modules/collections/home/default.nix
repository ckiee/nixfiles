{ sources, ... }:

let inherit (sources) home-manager;
in {
  home-manager.users.ckie = { ... }: { imports = [ ./devel.nix ./chat.nix ]; };
}
