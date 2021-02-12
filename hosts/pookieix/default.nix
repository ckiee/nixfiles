{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ../../modules/base.nix ../../modules/home.nix ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  networking.hostName = "pookieix";

  services.octoprint = {
    enable = true;
    port = 5000;
  };
  networking.firewall.allowedTCPPorts =
    [ 5000 ]; # this is just weird iptables stuff
  users.users.octoprint.extraGroups = [ "dialout" ];
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 5000
  '';

  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}
