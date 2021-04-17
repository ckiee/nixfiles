###
THIS FILE IS DEAD (syntax errors intentional)
###
{ config, pkgs, ... }:
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { pkgs, ... }: {
    imports = [ ./home/bash.nix ./home/git.nix ];

    # home.packages = with pkgs; [
    #   wget
    #   neofetch
    #   git
    #   killall
    #   htop
    #   file
    #   tree
    #   rsync
    #   ffmpeg-full
    #   yarn
    #   nodejs
    # ];
    # for nodejs
    # home.sessionPath = [ "~/.yarn/bin" ];
  };
}
