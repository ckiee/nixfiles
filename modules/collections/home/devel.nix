{ sources, config, lib, pkgs, ... }:

let
  cfg = config.cookie.collections.devel;

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
      cargo-edit
      cargo-watch
      maven
      gcc
      gh
      gdb
      manpages
      platformio
      elmPackages.elm
      elmPackages.elm-format
      tokei # LOC stats
      racket-minimal
      jdk
      git-cinnabar
      mercurialFull
    ];
    # TODO Make a programs.yarn in nixpkgs/home-manager to replace this:
    home.sessionPath = [ "~/.yarn/bin" ];
  };
}
