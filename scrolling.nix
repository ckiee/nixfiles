{ config, pkgs, ... }:

{
  services.xserver.libinput.naturalScrolling = true;
  # this is inverted for some reason, go figure
  services.xserver.inputClassSections = [''
    Identifier "EnableNatrualScrollingforTrackPoint"
    Driver "libinput"
    MatchIsPointer "on"
    Option "NaturalScrolling" "false"
  ''];
}
