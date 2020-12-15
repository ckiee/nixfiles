{ config, pkgs, ... }:

{
  programs.slock.enable = true;

  nixpkgs.config.packageOverrides = pkgs:
    {
      slock = pkgs.slock.override {
        conf =
          ''/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "#80f442",     /* after initialization */
	[INPUT] =  "#f4e842",   /* during input */
	[FAILED] = "#f44242",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 0;'';
      };
    };
}
