{ config, pkgs, lib, modulesPath, ... }:

with lib;

{
  imports = [
    ../..
    # ./install.nix TODO fix, it's broken atm because we call eval-config without passing some _module.args through
    "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  networking = {
    hostName = "installer";
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  cookie = {
    collections.media.enable = true;
    xserver.enable = true;
    sound = {
      enable = true;
      pulse.enable = true;
    };
    slock.enable = true;
    fonts.enable = true;
    gnome.enable = true;
    qt.enable = true;
    logiops.enable = true;
    ledc.enable = true;
    services = {
      avahi.enable = true;
      tailscale.enable = false;
    };
  };

  home-manager.users.ckie = { pkgs, ... }: {
    cookie = {
      polybar.enable = true;
      gtk.enable = true;
      dunst.enable = true;
      keyboard.enable = true;
      redshift.enable = true;
      nautilus.enable = true;
      i3.enable = true;
      xcursor.enable = true;
      st.enable = true;
    };
    services.rsibreak.enable = true;
    home.stateVersion = "22.11";
  };

  services.getty.autologinUser = mkForce "ckie";
  users.users.ckie.hashedPassword = mkForce "";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
