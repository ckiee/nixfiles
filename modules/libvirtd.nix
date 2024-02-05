{ lib, config, pkgs, ... }:

let cfg = config.cookie.libvirtd;

in with lib; {
  options.cookie.libvirtd = {
    enable = mkEnableOption "Enables VMs with libvirtd";
  };

  config = mkIf cfg.enable {
    users.users.ckie.extraGroups = [ "libvirtd" ];

    # Minimal: Just back up the VM xmls and a few misc small things.
    cookie.restic.paths = [ "/var/lib/libvirt/qemu" ];

    virtualisation = {
      libvirtd = {
        enable = true;
      };
      spiceUSBRedirection.enable = true;
    };
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  };
}
