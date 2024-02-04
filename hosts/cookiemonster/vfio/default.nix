{ config, lib, pkgs, ... }:

let cfg = config.cookie.libvirtd;

in with lib; {
  # see also: cookie.libvirtd
  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

    boot.kernelParams = [
      # VFIO: AMD Raphael iGPU + HDMI audio (probably redundant)
      "vfio-pci.ids=1002:164e,1002:1640"

      # VFIO: 6700XT, for dumping the Raphael firmware:
      # "vfio-pci.ids=1002:73df"

      # something something igpu specific hacky hack
      # from https://www.reddit.com/r/VFIO/comments/16mrk6j/amd_7000_seriesraphaelrdna2_igpu_passthrough/
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
    ];

    # drop em firmware images in they/them
    systemd.services.libvirtd-config.script = mkAfter ''
      # symbolic, always file (no stupid disambiguation depending on if name exists), force
      ln -sTf ${./fw} /run/libvirt/ckie-firmware
      ln -sTf ${pkgs.virtiofsd} /run/libvirt/virtiofsd
    '';

    # TODO: use HM programs.looking-glass-client.enable:
    environment.systemPackages = with pkgs; [ looking-glass-client ];

    cookie.user.extraGroups = [ "qemu-libvirtd" ];
    systemd.tmpfiles.rules =
      [ "f /dev/shm/looking-glass 0660 root qemu-libvirtd -" ];

    # expose pipewire-pulse
    services.pipewire.extraConfig =
      assert config.cookie.sound.pipewire.enable; {
        pipewire-pulse."30-localhost-net-publish"."pulse.cmd" = [{
          cmd = "load-module";
          args =
            "module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1";
        }];
      };

    home-manager.users.ckie = { ... }: {
      systemd.user.services.scream = {
        Unit = {
          Description = "Scream VFIO/Pulse/TCP4 lo";
          After = [ "pipewire-pulse.service" "pipewire.service" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };

        Service = {
          Type = "simple";
          Restart = "on-failure";
          ExecStart = "${pkgs.scream}/bin/scream";
        };
      };

      programs.looking-glass-client.enable = true;
    };

  };
}
