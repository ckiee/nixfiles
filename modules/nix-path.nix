{ lib, config, pkgs, ... }:

let cfg = config.cookie.nix-path;

in with lib; {
  options.cookie.nix-path = {
    enable = mkEnableOption "Enables usage of the pinned nixpkgs in $NIX_PATH";
  };

  config = mkIf cfg.enable {
    nix.nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
    environment.extraSetup = "ln -s ${pkgs.path} $out/nixpkgs";
  };
}
