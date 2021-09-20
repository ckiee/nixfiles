{ pkgs, ... }:

{
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  networking.networkmanager.wifi.powersave = true;
  powerManagement.cpuFreqGovernor = "powersave";
  # The SD-card reader is power hungry. Kill it!
  # https://wiki.archlinux.org/title/Lenovo_ThinkPad_T480s#SD_card_reader
  systemd.services."t480s-sdcard" = {
    wantedBy = [ "multi-user.target" ];
    description = "Disable Thinkpad T480s SD-card";
    script = "echo 2-3 >> /sys/bus/usb/drivers/usb/unbind";
  };
}
