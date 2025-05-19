{ lib, config, pkgs, ... }:

let cfg = config.cookie.logiops;

in with lib; {
  options.cookie.logiops = {
    enable = mkEnableOption "Enables Logiops for my MX Master 3";
  };

  config = mkIf cfg.enable {
    services.logiops = {
      enable = true;
      package = pkgs.logiops_0_2_3;

      settings = {
        devices = [{
          name = "Wireless Mouse MX Master 3";
          smartshift = {
            on = true;
            # 0 means always in hyperfast mode, 50 means (almost) always in click-to-click mode.
            threshold = 37;
          };
          hiresscroll = {
            hires = true;
            invert = false;
            target = false;
          };
          dpi = 980;

          buttons = [
            {
              cid = 195; # 0xc3
              action = {
                type = "Gestures";
                gestures = [
                  ({
                    direction = "Up";
                    mode = "OnRelease";
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_UP" ];
                    };
                  })
                  ({
                    direction = "Down";
                    mode = "OnRelease";
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_DOWN" ];
                    };
                  })
                  ({
                    direction = "Left";
                    mode = "OnRelease";
                    action = {
                      type = "CycleDPI";
                      dpis = [ 980 ];
                    };
                  })
                  ({
                    direction = "Right";
                    mode = "OnRelease";
                    action = { type = "ToggleSmartshift"; };
                  })
                  ({
                    direction = "None";
                    mode = "NoPress";
                  })
                ];
              };
            }
            {
              cid = 196; # 0xc4
              action = {
                type = "Keypress";
                keys = [ "KEY_A" ];
              };
            }
          ];
        }];
      };
    };
  };
}
