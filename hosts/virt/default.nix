{ config, pkgs, modulesPath, ... }: {
  imports = [ ../.. ./qemu.nix (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "virt";
  networking.firewall.enable = false;

  home-manager.users.ckie = { pkgs, ... }: {
    cookie.collections.devel.enable = true;
  };
  cookie = {
    desktop = {
      enable = true;
    };
    sound = {
      pulse.enable = true;
      pipewire.enable = false;
    };
    services = {
      syncthing.enable = true;
      printing.enable = true;
      tailscale.autoconfig = false;
    };
    systemd-boot.enable = true;
    hardware.t480s.enable = true;
    smartd.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
