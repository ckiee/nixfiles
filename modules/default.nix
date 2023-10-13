{ ... }:

{
  # Add the options defined below to configuration.nix
  # documentation.nixos.includeAllModules = true;
  # TODO fix nixos-mailserver so that option can work

  imports = [
    # Subfolders (but like, not for single modules)
    ./home
    ./services
    ./collections
    # Other
    ./smartd.nix
    ./sound
    ./hw.nix
    ./sleep.nix
    ./opentabletdriver
    ./slock.nix
    ./fonts.nix
    ./git.nix
    ./gnome
    ./xserver.nix
    ./desktop.nix
    ./systemd-boot.nix
    ./binary-caches.nix
    ./qt.nix
    ./wine.nix
    ./nix.nix
    ./cookie-overlay.nix
    ./secrets.nix
    ./acme.nix
    ./ipban.nix
    ./bindfs.nix
    ./steam.nix
    ./mail-client.nix
    ./doom-emacs
    ./user.nix
    ./wol.nix
    ./restic.nix
    ./command-not-found.nix
    ./shell-utils
    ./raspberry
    ./zfs.nix
    ./state.nix
    ./util
    ./libvirtd.nix
    ./remote-builder.nix
    ./nvidia-autoswitch.nix
    ./tailnet-certs
    ./hostapd.nix
    ./logiops.nix
    ./wireguard.nix
    ./mpd
    ./networkmanager.nix
    ./big.nix
    ./devserv
    ./imperm.nix
    ./firejail
    ./wireshark.nix
    ./cnping
    ./eg.nix
    ./lutris.nix
    ./ledc.nix
    ./systemd-initrd.nix
    ./rkvm.nix
    ./openrgb
    ./wivrn
  ];
}
