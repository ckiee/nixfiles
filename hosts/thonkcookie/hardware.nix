let
  sources = import ../../nix/sources.nix;
  inherit (sources) nixos-hardware;
in { config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${nixos-hardware}/lenovo/thinkpad/t480s"
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."sncrypt".device =
    "/dev/disk/by-uuid/1b405708-1efc-4844-bd75-ae0e5a40d34e";

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/182F-0E22";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/sng-nix";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
