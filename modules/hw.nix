{ config, lib, pkgs, ... }:

let
  cfg = config.cookie.hardware;
in with lib; {
  options.cookie.hardware = {
    t480s = mkEnableOption "Enables Thinkpad T480s specific hardware quirks";
  };

  # We need to do this after the libinput Xorg config
  config.services.xserver.config = mkIf cfg.t480s (mkAfter ''
    Section "InputClass"
      Identifier "Set NatrualScrolling for TrackPoint"
      Driver "libinput"
      MatchIsPointer "on"
      Option "NaturalScrolling" "off"
      Option "Tapping" "off"
    EndSection
  '');
}
