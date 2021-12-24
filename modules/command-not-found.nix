{ sources, lib, config, pkgs, ... }:

let
  cfg = config.cookie.command-not-found;
  ncs = (import (sources.nixos-channel-scripts + "/default.nix") { });
in with lib; {
  options.cookie.command-not-found = {
    enable = mkEnableOption
      "Enables command-not-found quirks for the cookie.nix option";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ ncs.overlay ];
    environment.systemPackages = with pkgs; [ nixos-channel-native-programs ];
  };
}
