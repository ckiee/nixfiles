{ config, pkgs, lib, ... }:

{
  services.xserver.libinput.naturalScrolling = true;
  # this is inverted for some reason, go figure
  # need to do this after libinput xorg config stuff
  services.xserver.config = (lib.mkAfter ''
    Section "InputClass" 
      Identifier "Set NatrualScrolling for TrackPoint"
      Driver "libinput"
      MatchIsPointer "on" 
      Option "NaturalScrolling" "off"
    EndSection
  '');
}
