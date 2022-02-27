{ sources, lib, config, pkgs, ... }:

let
  cfg = config.cookie.st;
  st = (pkgs.st.overrideAttrs (_: rec {
    version = "ckie";
    src = sources.st;
  }));
in with lib; {
  options.cookie.st = {
    enable = mkEnableOption "Enables the suckless terminal";
  };

  config = { home.packages = singleton st; };
}
