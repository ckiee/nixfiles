let
  nixos-hardware = builtins.fetchGit {
    url = "https://github.com/NixOS/nixos-hardware.git";
    rev = "267d8b2d7f049d2cb9b7f4a7f981c123db19a868";
  };
in { config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${nixos-hardware}/lenovo/thinkpad/t480s"
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/crypted";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."crypted".device =
    "/dev/disk/by-uuid/f6c95e22-ac8b-40f0-8ce7-536d78dcc51b";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EF7A-172E";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/5fb66e38-bc85-4170-a7f2-8e7ffefc6aae"; }];

}
