{ config, lib, pkgs, sources, ... }:

let cfg = config.cookie.libvirtd;

in with lib; {
  # see also: cookie.libvirtd
  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];

    boot.kernelParams = [
      # VFIO: AMD Raphael iGPU + HDMI audio (probably redundant)
      # 1022:15b6 (now present) is the top USB controller for the USB2 port sandwiched between
      #           the builtin HDMI and another USB2 port. Maybe it also controls that one. Probably. Haven't checked.
      "vfio-pci.ids=1002:164e,1002:1640,1022:15b6"

      # Adding the USB controller (#3) started spamming the kernel logs:
      # > [442702.246274] vfio-pci 0000:13:00.3: Refused to change power state from D0 to D3hot
      # Trying https://www.reddit.com/r/VFIO/comments/ykyyk0/deleted_by_user/iuxfho1/
      # Untested.
      "vfio-pci.disable_idle_d3=1"

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
      ln -sTf ${sources.osx-kvm} /run/libvirt/osx-kvm
      ln -sTf ${pkgs.virtiofsd} /run/libvirt/virtiofsd
    '';

    virtualisation.libvirtd.hooks.qemu."10-vfio-manager" = pkgs.writeShellScript "vfio-qemu-hook" ''
      set -euo pipefail
      # Dynamically VFIO bind/unbind the USB with the VM starting up/stopping
      if [[ "$1" =~ "win10|ventura" ]]; then
        [ "$2" = "prepare" ] && virsh nodedev-reattach pci_0000_13_00_3
        [ "$2" = "release" ] && virsh nodedev-detach pci_0000_13_00_3
      fi
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
