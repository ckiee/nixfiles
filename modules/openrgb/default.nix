{ lib, config, pkgs, ... }:

let cfg = config.cookie.openrgb;

in with lib; {
  options.cookie.openrgb = { enable = mkEnableOption "openrgb"; };

  config = mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      motherboard = config.cookie.hardware.motherboard;
      extraOptions =
        [ "--profile" "${./. + "/${config.networking.hostName}.orp"}" ];
    };
  };
}
