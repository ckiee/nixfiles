{ lib, config, pkgs, ... }:

let cfg = config.cookie.cookie-overlay;

in with lib; {
  options.cookie.cookie-overlay = {
    enable = mkEnableOption "Enables the Cookie's private package collection";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (self: super: { cookie = import ../../pkgs; }) ];
    home-manager.users.ron = { ... }: {
      cookie.nixpkgs-config.expr =
        "packageOverrides = pkgs: { cookie = import ${
          ../pkgs
        } { inherit pkgs; }; };";
    };
  };
}
