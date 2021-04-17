{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cookie.hw;
  nixos-hardware = builtins.fetchGit {
    url = "https://github.com/NixOS/nixos-hardware.git";
    rev = "874830945a65ad1134aff3a5aea0cdd2e1d914ab";
  };
in {
  options.cookie.hw = {
    t480s = mkEnableOption "Enables Thinkpad T480s specific quirks";
  };

  # imports = mkIf cfg.t480s [ "${nixos-hardware}/lenovo/thinkpad/t480s" ];
}
