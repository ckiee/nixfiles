{ config, lib, pkgs, ... }:

with lib; {
  fileSystems = {
    "/" = mkForce (if config.cookie.imperm.enable then {
      device = "none";
      fsType = "tmpfs";
    } else {
      device = "/dev/vda1";
      fsType = "ext4";
    });
    "/nix" = mkIf config.cookie.imperm.enable (mkForce {
      device = "/dev/vda1";
      fsType = "ext4";
    });
  };

  services.qemuGuest.enable = true;
}
