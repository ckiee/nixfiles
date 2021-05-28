{ config, lib, pkgs, ... }:

let cfg = config.cookie.devel;
in with lib; {

  options.cookie.devel = {
    enable = mkEnableOption "Enables some development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nodejs yarn rustup maven gcc gh gdb manpages ];
    # TODO Make a programs.yarn in nixpkgs to replace this:
    home.sessionPath = [ "~/.yarn/bin" ];
  };
}
