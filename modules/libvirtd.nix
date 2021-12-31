{ lib, config, pkgs, ... }:

let cfg = config.cookie.libvirtd;

in with lib; {
  options.cookie.libvirtd = {
    enable = mkEnableOption "Enables VMs with libvirtd";
  };

  config = mkIf cfg.enable {
    users.users.ckie.extraGroups = [ "libvirtd" ];

    virtualisation = {
      libvirtd = {
        enable = true;
        package = pkgs.libvirt.override {
          # I hate dnsmasq, it ends up in my dreams and breaks my builds
          # in weird ways and takes over my ports and attacks my fleet and is just rude!
          # Maybe it's not it's fault, but it has caused so many problems due to it's environment.
          # I wish I could help it but the best I can do is to hide it, away from it's abusers.
          dnsmasq = pkgs.writeShellScriptBin "dnsmasq" "sleep infinity";
        };
      };
      spiceUSBRedirection.enable = true;
    };
    boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  };
}
