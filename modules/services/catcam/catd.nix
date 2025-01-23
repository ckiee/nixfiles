{ lib, config, pkgs, ... }@margs:

with lib;

let
  cfg = config.cookie.services.catcam;
  util = import ../util.nix margs;
in {
  config = mkIf cfg.enable (mkMerge [
    (util.mkService "catd" {
      noDefaultTarget = true;
      description = "catcam's catd";
      script = ''
        bin=./catcam
        [ -e $bin ] || bin=${../../../secrets/catd}

        export NODE_ENV=production
        exec $bin
      '';
      path = with pkgs; [ bun ffmpeg ];

      secrets.env = {
        source = "./secrets/catd.env";
        dest = "/var/lib/catd/.env";
        permissions = "0400";
      };
    })
    {
      systemd.services.catd = {
        wantedBy = mkForce [ ];
        startAt = "10,13,16,19:00:00";
      };
    }
  ]);
}
