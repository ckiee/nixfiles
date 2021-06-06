{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
}
