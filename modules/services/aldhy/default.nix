{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.aldhy;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.aldhy = {
    enable = mkEnableOption "Enables the aldhy distributed nix evaluator";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/aldhy";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "aldhy" {
      home = cfg.folder;
      description = "aldhy";
      # secrets.env = {
      #   source = "./secrets/aldhy.env";
      #   dest = "${cfg.folder}/.env";
      #   permissions = "0400";
      # };
      script = ''
      '';
    })
  ]);
}
