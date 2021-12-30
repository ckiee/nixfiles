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
    ./gnome.nix
    ./xserver.nix
    ./desktop.nix
    ./systemd-boot.nix
    ./caches.nix
    ./qt5.nix
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
    ./st
    ./zfs.nix
    ./machine-info.nix
    ./util
    ./libvirtd.nix
  ];
}
