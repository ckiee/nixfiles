{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.keyd;
  cmd = line: name: # NOTE -u forces single-instance.
    "command(systemd-run -u ${name} --collect --wait --user --machine ckie@.host ${line})";
in {
  options.cookie.keyd = { enable = mkEnableOption "keyd & warpd"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ keyd warpd ];

    home-manager.users.ckie = { config, ... }: {
      xdg.configFile."warpd/config".source = ./warpd.cfg;
    };

    services.keyd = {
      enable = true;
      keyboards = {
        gk600 = {
          ids = [ "0db0:ea47" ];
          settings = {
            main = {
              # "copilot" key
              "leftmeta+leftshift+f23" = "overload(righty, rightcontrol)";
            };

            righty = rec {
              "m" = cmd "${pkgs.warpd}/bin/warpd --hint2" "keyd-warpd";
              "n" = m;
              "space+m" = m;
              "space+n" = m;

              space = cmd "${pkgs.warpd}/bin/warpd --normal" "keyd-warpd";
            };
          };
        };
      };
    };
  };
}
