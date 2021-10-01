{ pkgs, ... }:

{
  powerManagement.powertop.enable = true;

  # Lenovo does not support this, but we turn it on anyway
  # because we can!
  boot.kernelParams = [ "pcie_aspm=force" ];

  services.tlp = {
    enable = true;
    settings = {
      # Most of the defaults are okay, but we want
      # to utilize our now-enabled ASPM
      PCIE_ASPM_ON_BAT = "powersupersave"; # ON_AC default
    };
  };
  networking.networkmanager.wifi.powersave = true;
  powerManagement.cpuFreqGovernor = "powersave";
  # iwlwifi experimental powersave
  # https://wiki.archlinux.org/title/Power_management#Intel_wireless_cards_(iwlwifi)
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1
    options iwlmvm power_scheme=3

    # This is in the Arch wiki but it adds random
    # 100ms spikes that I do not like..
    # options iwlwifi uapsd_disable=0
  '';

  # The SD-card reader is power hungry. Kill it!
  # https://wiki.archlinux.org/title/Lenovo_ThinkPad_T480s#SD_card_reader
  systemd.services."t480s-sdcard" = {
    wantedBy = [ "multi-user.target" ];
    description = "Disable Thinkpad T480s SD-card";
    script = ''
      echo 2-3 >> /sys/bus/usb/drivers/usb/bind || true
      echo 2-3 >> /sys/bus/usb/drivers/usb/unbind
    '';
  };
}
