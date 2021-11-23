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
    ./sound.nix
    ./hw.nix
    ./sleep.nix
    ./opentabletdriver.nix
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
    ./metadata.nix
    ./bindfs.nix
    ./steam.nix
    ./mail-client.nix
    ./doom-emacs.nix
    ./user-alias.nix
    ./wol.nix
    ./restic.nix
    ./command-not-found.nix
    ./shell-utils
    ./raspberry
    ./st.nix
    ./zfs.nix
  ];
}
