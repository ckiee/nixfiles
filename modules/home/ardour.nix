{ lib, config, pkgs, ... }:

let cfg = config.cookie.ardour;

in with lib; {
  options.cookie.ardour = {
    enable = mkEnableOption "Enables ardour, a musicy DAW";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ardour
    ];
    # TODO:
    # <Option name="plugin-path-vst3" value="/home/ckie/.nix-profile/lib/vst3:/run/current-system/sw/lib/vst3:/etc/profiles/per-user/ckie/lib/vst3:/home/ckie/.vst3"/>
    # where value is set to getenv("VST3_PATH")
    home.activation.ardourConfig = let rg = getBin pkgs.ripgrep;
    in hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -e ~/.config/ardour7/config ]; then
        $VERBOSE_ECHO "Setting impure ardour config values"
        $DRY_RUN_CMD mkdir $VERBOSE_ARG ~/Sync/.ardour || true
        $DRY_RUN_CMD mv $VERBOSE_ARG ~/.config/ardour7/config{,.work} &&
        $DRY_RUN_CMD ${rg}/bin/rg \
          '(<Option name="default-session-parent-dir" value=")[^"]+("/>)' ~/.config/ardour7/config.work \
          --passthru -r '$1'"$HOME/Sync/.ardour"'$2' > ~/.config/ardour7/config &&
        $DRY_RUN_CMD rm $VERBOSE_ARG ~/.config/ardour7/config.work
      fi
    '';
  };
}
