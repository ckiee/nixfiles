{ lib, config, pkgs, ... }:

let cfg = config.cookie.apple-fastcharge;

in with lib; {
  options.cookie.apple-fastcharge = {
    enable = mkEnableOption "apple-fastcharge";
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ACTION=="add", DRIVER=="apple-mfi-fastcharge", RUN+="/bin/sh -c 'echo Fast > /sys/class/power_supply/apple_mfi_fastcharge/charge_type'"
    '';
  };
}
