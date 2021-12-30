{ lib, config, pkgs, ... }:

let cfg = config.cookie.libvirtd;

in with lib; {
  options.cookie.libvirtd = {
    enable = mkEnableOption "Enables VMs with libvirtd";
  };

  config = mkIf cfg.enable {
    users.users.ckie.extraGroups = [ "libvirtd" ];

    virtualisation = {
      libvirtd = { enable = true; };
      spiceUSBRedirection.enable = true;
    };
  };
}
