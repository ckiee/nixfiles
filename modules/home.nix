{ config, pkgs, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "63f299b3347aea183fc5088e4d6c4a193b334a41";
    ref = "release-20.09";
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { pkgs, ... }: {
    imports = [ ./home/xcursor.nix ./home/bash.nix ./home/git.nix ];

    home.packages = with pkgs; [
      wget
      nano
      neofetch
      git
      killall
      htop
      file
      tree
      rsync
    ];

  };
}
