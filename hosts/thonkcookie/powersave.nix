{ pkgs, ... }:

{
  powerManagement.powertop.enable = true;
  networking.networkmanager.wifi.powersave = true;
}
