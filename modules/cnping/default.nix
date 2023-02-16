{ lib, config, pkgs, ... }:

let cfg = config.cookie.cnping;

in with lib; {
  options.cookie.cnping = {
    enable = mkEnableOption "Enables the cnping program";
  };

  config = mkIf cfg.enable {
    programs.cnping = {
      enable = true;
      package = pkgs.cnping.overrideAttrs (prev: {
        patches = (prev.patches or [ ])
          ++ [ ./0001-Use-trans-color-scheme.patch ];
      });
    };
  };
}
