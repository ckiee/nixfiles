{ lib, config, pkgs, ... }:

let cfg = config.cookie.ardour;

in with lib; {
  options.cookie.ardour = {
    enable = mkEnableOption "Enables ardour, a musicy DAW";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ardour ];
    home.activation.ardourConfig = let rg = getBin pkgs.ripgrep;
    in hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -e ~/.config/ardour6/config ]; then
        $VERBOSE_ECHO "Setting impure ardour config values"
        $DRY_RUN_CMD mkdir $VERBOSE_ARG ~/Sync/.ardour || true
        $DRY_RUN_CMD mv $VERBOSE_ARG ~/.config/ardour6/config{,.work} &&
        $DRY_RUN_CMD ${rg}/bin/rg \
          '(<Option name="default-session-parent-dir" value=")[^"]+("/>)' ~/.config/ardour6/config.work \
          --passthru -r '$1'"$HOME/Sync/.ardour"'$2' > ~/.config/ardour6/config &&
        $DRY_RUN_CMD rm $VERBOSE_ARG ~/.config/ardour6/config.work
      fi
    '';
  };
}
