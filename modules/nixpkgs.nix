{ sources, lib, config, pkgs, ... }:

let cfg = config.cookie.nixpkgs;

in with lib; {
  options.cookie.nixpkgs = {
    arch = mkOption {
      type = types.str;
      description = "the CPU architecture to configure this node for";
      default = "x86_64-linux";
    };
  };

  config = {
    nixpkgs = {
      pkgs = import sources.nixpkgs {
        config = { allowUnfree = true; };
        system = cfg.arch;
      };
      localSystem.system = cfg.arch;
    };
  };
}
