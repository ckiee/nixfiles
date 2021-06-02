{ lib, config, pkgs, ... }:

let cfg = config.cookie.nixpkgs-config;
in with lib; {
  options.cookie.nixpkgs-config = {
    enable = mkEnableOption "Enables the user nixpkgs config";
    expr = mkOption {
      type = types.lines;
      default = "thing = true;";
      description = "Nix expression lines to evaluate";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."nixpkgs/config.nix".text = ''
      {pkgs, ...}:

      {
        ${cfg.expr}
      }
    '';
    cookie.nixpkgs-config.expr = "allowUnfree = true;";
  };
}
