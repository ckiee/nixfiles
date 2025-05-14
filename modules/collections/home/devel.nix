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
      bun # also js
      rustup
      cargo-edit
      cargo-watch
      maven
      gcc
      gh
      gdb
      man-pages
      platformio
      elmPackages.elm
      elmPackages.elm-format
      tokei # LOC stats
      racket-minimal
      jdk
      git-cinnabar
      mercurialFull
      # jetbrains.idea-community # way too good to use emacs for java. TODO unbreak
      nixpkgs-review
      logisim-evolution
      nix-init # Generate Nix packages from URLs with hash prefetching, dependency inference, license detection, and more
      mongodb-compass
      insomnia # http playground
      flyctl # fly.io cli
      heroku
    ];
    # TODO Make a programs.yarn in nixpkgs/home-manager to replace this:
    home.sessionPath = [ "~/.yarn/bin" "~/.pnpm/bin" ];
    programs.bash.initExtra = "export PNPM_HOME=~/.pnpm/bin";
  };
}
