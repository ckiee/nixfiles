{ config, pkgs, lib, modulesPath, ... }:

with lib;
with builtins;

{
  imports = [ ../.. "${modulesPath}/virtualisation/google-compute-image.nix" ];
  networking.hostName = mkForce "eg"; # gce might not like this, but it's needed for secrets etc
  networking.networkmanager.enable = mkForce false;

  cookie = {
    big.enable = false; # minimal machine
    state = {
      sshPubkey =
        # just my personal one since this machine gets its sshPubkey shortly
        # after the only boot it will ever experience.
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3uTwzSSMAPg84fwbNp2cq9+BdLFeA1VzDGth4zCAbz https://ckie.dev";
    };
  };

  home-manager.users.ckie.home.stateVersion = "22.11";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
