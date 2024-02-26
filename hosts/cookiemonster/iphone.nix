{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ ifuse ];

  fileSystems."/mnt/iphone" = {
    device = "${pkgs.ifuse}/bin/ifuse";
    fsType = "fuse";
    # stinky as uid is not guaranteed
    options = [
      "uid=1000"
      "gid=100"
      "noatime"
      "x-systemd.automount"
      "nofail"
      "allow_other"
      "x-systemd.requires=usbmuxd.service"
      "x-systemd.device-bound=/sys/module/apple_mfi_fastcharge/drivers/usb:apple-mfi-fastcharge/1-4"
    ];
  };
}
