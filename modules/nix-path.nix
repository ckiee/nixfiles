{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.nix-path;
  nixfiles = ./..; # TODO: remove when adding secrets
in with lib; {
  options.cookie.nix-path = {
    enable = mkEnableOption "Enables usage of the pinned nixpkgs in $NIX_PATH";
  };

  config = mkIf cfg.enable {
    nix.nixPath = map (x: "${x}=/run/current-system/sw/${x}") [
      "nixpkgs"
      "nixos-config" # This actually should point to a path in hosts but it seems just going with the default.nix makes things work...somehow.
    ];
    environment.extraSetup = ''
      ln -s ${pkgs.path} $out/nixpkgs
      ln -s ${nixfiles} $out/nixos-config
    '';
  };
}
