{ config, lib, pkgs, ... }:

let
  cfg = config.cookie.collections.devel;

  sources = import ../../../nix/sources.nix;
  ms = import sources.nixpkgs-master { };
in with lib; {

  options.cookie.collections.devel = {
    enable = mkEnableOption "Enables some development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_latest
      (yarn.override { nodejs = nodejs_latest; })
      rustup
      maven
      gcc
      gh
      gdb
      manpages
      platformio
      elmPackages.elm
      elmPackages.elm-format
    ];
    # TODO Make a programs.yarn in nixpkgs/home-manager to replace this:
    home.sessionPath = [ "~/.yarn/bin" ];
  };
}
