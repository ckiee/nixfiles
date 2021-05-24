{ pkgs, ... }:

{
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  networking.networkmanager.wifi.powersave = true;
  powerManagement.cpuFreqGovernor = "powersave";
}
