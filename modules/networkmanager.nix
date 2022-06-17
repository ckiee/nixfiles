{ lib, config, pkgs, ... }:

let cfg = config.cookie.networkmanager;

in with lib; {
  options.cookie.networkmanager = {
    enable = mkEnableOption "Enables NetworkManager tweaks";
  };

  config = mkMerge [
    {
      cookie.networkmanager.enable =
        mkDefault config.networking.networkmanager.enable;
    }
    (mkIf cfg.enable {
      # TODO: report to upstream, the freedesktop gitlab is making us wait
      # for approval.
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        "${pkgs.networkmanager}/bin/nm-online -q";
    })
  ];
}
