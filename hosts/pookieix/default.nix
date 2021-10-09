{ config, pkgs, lib, ... }:

# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=hosts/pookieix/default.nix --argstr system aarch64-linux
# build=$(nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=hosts/pookieix/default.nix --argstr system aarch64-linux) && echo $build && nix copy --to ssh://pookieix.local $build
{
  imports = [
    ./hardware.nix
    ../..
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  networking.hostName = "pookieix";

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  services.octoprint = {
    enable = true;
    port = 5000;
  };

  # following rule is prerouting, so we still need to expose this
  networking.firewall.allowedTCPPorts = [ 5000 ];
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 5000
  '';

  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
