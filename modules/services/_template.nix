{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.foo;

in with lib; {
  options.cookie.services.foo = {
    enable = mkEnableOption "Enables the foo service";
  };

  config = mkIf cfg.enable { };
}
