{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  # https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Cloud#Manually (just virtio_gpu, not nvme)
  boot.initrd.kernelModules = [ "nvme" "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];

  boot.initrd.luks.devices."root".device =
    "/dev/disk/by-uuid/8e9a873f-cc55-449f-9174-7d7c9f84bddd";
  fileSystems."/" = {
    device = "/dev/mapper/root";
    fsType = "ext4";
    options = [ "x-systemd.device-timeout=3600" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/475D-55F3";
    fsType = "vfat";
  };

  cookie.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    configurationLimit = 16;
    copyKernels = true;
    efiSupport = true;
    devices = [ "/dev/disk/by-partuuid/25c42fcc-0e74-f04f-b2f6-98cef9d774a0" ];
  };

  swapDevices = [ ];

  cookie.nixpkgs.arch = "aarch64-linux";
}
