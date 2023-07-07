{ lib, config, pkgs, ... }:

let cfg = config.cookie.foo;

in with lib; {
  options.cookie.foo = {
    enable = mkEnableOption "foo";
  };

  config = mkIf cfg.enable { };
}
