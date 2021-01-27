{ config, pkgs, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "e44faef21c38e3885cf2ed874ea700d3f0260448";
    ref = "master";
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { pkgs, ... }: {
    imports = [
      ./home/bash.nix
      ./home/git.nix
      ./home/dunst.nix
      # ./home/graphical/picom.nix
      ./home/kitty.nix
      ./home/doom.nix
      ./home/resume-fix-pulseaudio.nix
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
