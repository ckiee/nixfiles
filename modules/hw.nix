{ config, lib, ... }:

let
  cfg = config.cookie.hardware;
  nixos-hardware = builtins.fetchGit {
    url = "https://github.com/NixOS/nixos-hardware.git";
    rev = "267d8b2d7f049d2cb9b7f4a7f981c123db19a868";
  };
in with lib; {
  options.cookie.hardware = {
    t480s = mkEnableOption "Enables Thinkpad T480s specific hardware quirks";
  };

  imports = [ "${nixos-hardware}/lenovo/thinkpad/t480s"];
    # ++ optional cfg.t480s ("${nixos-hardware}/lenovo/thinkpad/t480s");
}
