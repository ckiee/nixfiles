{ lib, config, pkgs, ... }:

let cfg = config.cookie.nixpkgs-config;
in with lib; {
  options.cookie.nixpkgs-config = {
    enable = mkEnableOption "Enables the user nixpkgs config";
  };

  config = mkIf cfg.enable {
    xdg.configFile."nixpkgs/config.nix".source = ../../ext/nixpkgs-home.nix;
  };
}
