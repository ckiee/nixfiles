{ ... }:

{
  imports = [
    # Subfolders
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
  ];
}
