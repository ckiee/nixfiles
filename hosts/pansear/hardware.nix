{ config, lib, pkgs, modulesPath, ... }:
with lib;

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "ata_piix" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2182ff14-faa1-4ec7-b9a7-03ae63690baa";
    fsType = "ext4";
    options = [ "x-systemd.device-timeout=1800" ];
  };

  boot.initrd.luks.devices."root".device = # LVM device
    "/dev/disk/by-uuid/b28c8276-5d34-4dfd-a62f-94d63327b93a";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/649A-B53C";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # chonk is a 12tb external WD hdd that gets automounted after boot
  # this took a while but it finally works.. pls copy
  cookie.secrets.chonk-keyfile = {
    source = "./secrets/wd-chonk-keyfile";
    permissions = "0400";
  };
  # fucking bollocks override to get it to be decrypted before the keyfile is used
  systemd.services.chonk-keyfile-key = {
    unitConfig.DefaultDependencies = false;
    before = [ "systemd-cryptsetup@chonkcrypt.service" ];
    after = [
      "cryptsetup-pre.target"
      "local-fs-pre.target"
      "systemd-udevd-kernel.socket"
    ];
    wantedBy = mkForce [
      "systemd-cryptsetup@chonkcrypt.service" # the service generated from the crypttab entry
    ];
  };
  environment.etc."crypttab".text = ''
    chonkcrypt  UUID=87205375-ddb2-4d4d-b428-4641c722beca ${config.cookie.secrets.chonk-keyfile.dest} noauto,nofail,x-systemd.device-timeout=10
  '';
  systemd.tmpfiles.rules = [
    "d  /mnt/chonk 0755 ckie users -"
    "d  /mnt/chonk/ckie 0700 ckie users -"
  ];
  fileSystems."/mnt/chonk" = {
    device = "/dev/disk/by-uuid/83d694c1-9cf0-4404-9e7f-f462a4c924d2";
    fsType = "ext4";
    neededForBoot = false;
  };
  # https://github.com/leana8959/.files/blob/3c34320911b1778da885b9e91be5011d699476a0/nix/nixosModules/named/vanadium/fs.nix#L51
  systemd.mounts = [{
    what = "/dev/disk/by-uuid/83d694c1-9cf0-4404-9e7f-f462a4c924d2";
    where = "/mnt/chonk";
    options = lib.concatStringsSep "," [
      "noauto"
      "x-systemd.automount"
      "x-systemd.mount-timeout=10"
      "x-systemd.idle-timeout=10min"
      "nofail"
    ];
    mountConfig = {
      Type = "ext4";
      TimeoutSec = "10s";
    };
    unitConfig = {
      Requires = [ "systemd-cryptsetup@chonkcrypt.service" ];
      After = [ "systemd-cryptsetup@chonkcrypt.service" ];
      PropagatesStopTo = [ "systemd-cryptsetup@chonkcrypt.service" ];
    };
  }];

  hardware.nvidia.open = false; # old gpu
}
