{ lib, config, pkgs, ... }:

let cfg = config.cookie.wivrn;

in with lib; {
  options.cookie.wivrn = { enable = mkEnableOption "wivrn"; };

  config = mkIf cfg.enable {
    # services.avahi = mkIf cfg.enable {
    #   enable = true;
    #   publish = {
    #     enable = true;
    #     userServices = true;
    #   };
    # };
    #
    # Above comment for wivrn dev, but now there's a NixOS module:
    services.wivrn = {
      enable = true;
      highPriority = true;
      defaultRuntime = true;
    };
  };
}
