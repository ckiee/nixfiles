{ lib, pkgs, ... }:

let util = import ./util.nix { inherit lib pkgs; };
in {
  _module.args.util = util;
  home-manager.users.ckie = { ... }: { _module.args.util = util; };
}
