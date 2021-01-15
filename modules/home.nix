{ config, pkgs, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { pkgs, ... }: {
    imports = [
      ./home/bash.nix
      ./home/git.nix
      ./home/dunst.nix
      ./home/picom.nix
      ./home/kitty.nix
      ./home/doom.nix
    ];

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
      ffmpeg
      yarn
      nodejs
    ];

  };
}
