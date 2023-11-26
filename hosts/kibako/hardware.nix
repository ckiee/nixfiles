# /dev/sd?1 is bios boot for grub preloader
# Now MBR, Empty 512MB, then one Linux RAID partition per drive
#
# LVM RAID5 /dev/sd?2 :
#   /dev/kibakovg/root
#   LUKS :
#     /dev/mapper/root
#
# do manually inside nixos-enter to avoid quirky OVH rescue netboot system thing:
# NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "dm-raid" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.lvm.enable = true;

  fileSystems."/" = {
    device =
      "/dev/disk/by-uuid/8c7494d9-a0b0-43e8-8bf0-b37c19592ac2"; # /dev/mapper/root (LUKS)
    fsType = "ext4";
    options = [ "x-systemd.device-timeout=3600" ];
  };

  boot.initrd.services.lvm.enable = true;

  # /dev/kibakovg/root
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/669b6690-3d33-4e80-9a2d-ff2fc70a1733";
    # preLVM = false; # XXX: only with script initrd
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/44D4-1747"; # /dev/kibakovg/boot
    fsType = "vfat";
  };

  boot.loader.grub = {
    enable = true;

    configurationLimit = 16;
    copyKernels = true;
    mirroredBoots = [{
      path = "/boot";
      devices = [
        # "/dev/disk/by-id/wwn-0x55cd2e404c748ded-part1"
        # "/dev/disk/by-id/wwn-0x55cd2e414fc48872-part1"
        # "/dev/disk/by-id/wwn-0x55cd2e414d40757a-part1"
        "/dev/disk/by-id/wwn-0x55cd2e404c748ded"
        "/dev/disk/by-id/wwn-0x55cd2e414fc48872"
        "/dev/disk/by-id/wwn-0x55cd2e414d40757a"
      ];
    }];

    # Add LVM and ~~be scared of the system BIOS~~. Version 0163 for DH67BL, from 2018!
    # https://web.archive.org/web/20231124175811/https://community.intel.com/cipcp26785/attachments/cipcp26785/desktop-boards/52349/1/BL_0163_ReleaseNotes.pdf
    extraGrubInstallArgs = [
      # "--modules=nativedisk part_gpt lvm"
      "--modules=part_gpt part_msdos diskfilter mdraid1x lvm"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # boot.swraid.enable = true;
}
