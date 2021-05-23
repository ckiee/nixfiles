{ lib, config, pkgs, ... }:

let cfg = config.cookie.slock;
in with lib; {
  options.cookie.slock = {
    enable = mkEnableOption "Enables the slock screen locker";
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
            	[INIT] =   "#1b1720",   /* after initialization */
            	[INPUT] =  "#27212e",   /* during input */
            	[FAILED] = "#ffe261",   /* wrong password */
            };

            /* treat a cleared input like a wrong password (color) */
            static const int failonclear = 0;'';
        };
      })
    ];

    # TODO set the i3 locker here instead of in xsession
  };
}
