{ lib, config, pkgs, ... }:

let cfg = config.cookie.wivrn;

in with lib; {
  options.cookie.wivrn = { enable = mkEnableOption "wivrn"; };

  # FIXME: Move this. This is only for testing until we package WiVRn as a
  # nixpkgs NixOS module.
  config = mkIf cfg.enable {
    services.avahi = mkIf cfg.enable {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
