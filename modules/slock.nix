{ lib, config, pkgs, ... }:

let cfg = config.cookie.slock;
in with lib; {
  options.cookie.slock = {
    enable = mkEnableOption "slock screen locker";
  };

  config = mkIf cfg.enable {
    programs.slock.enable = true;

    nixpkgs.overlays = [
      (self: super: {
        slock = super.slock.override {
          conf = ''
            /* user and group to drop privileges to */
            static const char *user  = "nobody";
            static const char *group = "nogroup";

            static const char *colorname[NUMCOLS] = {
            	[INIT] =   "#eb64b9",   /* after initialization */
            	[INPUT] =  "#ffe261",   /* during input */
            	[FAILED] = "#ff665b",   /* wrong password */
            };

            /* treat a cleared input like a wrong password (color) */
            static const int failonclear = 0;'';
        };
      })
    ];

    # TODO set the i3 locker here instead of in xsession
  };
}
