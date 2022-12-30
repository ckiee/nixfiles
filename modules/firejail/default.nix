{ lib, config, pkgs, ... }:

let cfg = config.cookie.firejail;

in with lib; {
  options.cookie.firejail = {
    enable = mkEnableOption "Enables firejail";
    package = mkOption {
      type = types.package;
      default = pkgs.firejail;
      description = "Firejail package used";
      readOnly = true; # is a constant from the upstream NixOS module for now
    };
    mk = mkOption {
      readOnly = true;
      description = "Utility function to make a wrappedBinaries entry";
      default = name:
        { pkg, profile ? name, bin ? name }: {
          ${bin} = {
            executable = "${getBin pkg}/bin/${bin}";
            profile =
              "${config.cookie.firejail.package}/etc/firejail/${profile}.profile";
          };
        };
    };
  };

  config = mkIf cfg.enable {
    programs.firejail.enable = true;
  };
}
