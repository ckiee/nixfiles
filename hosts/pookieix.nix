{ config, pkgs, ... }: {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../modules/base.nix
    ../modules/home.nix
  ];

  networking.hostName = "pookieix";

  services.octoprint = {
    enable = true;
    port = 5000;
  };
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 5000
  '';

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # Mainline doesn't work yet
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
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
