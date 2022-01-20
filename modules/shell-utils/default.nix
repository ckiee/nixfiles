{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.cookie.shell-utils;

  deriv = pkgs.runCommandLocal "ckie-shell-utils" {
    ckiePath = makeBinPath (with pkgs; [ rsync wget coreutils xclip ripgrep curl hostname jq config.nix.package ]);
    inherit (pkgs) bash;
  } ''
    mkdir -p $out/bin
    for script in ${./scripts}/*;
      do substituteAll "$script" "$out/bin/$(basename $script)"
      chmod +x "$out/bin/$(basename $script)"
    chmod +x "$out"
    done
  '';
in with lib; {
  options.cookie.shell-utils = {
    enable = mkEnableOption "Enables various shell utilities";
  };

  config = mkIf cfg.enable { environment.systemPackages = singleton deriv; };
}
