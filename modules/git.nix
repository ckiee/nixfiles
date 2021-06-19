{ config, lib, pkgs, ... }:

let cfg = config.cookie.git;
in with lib; {
  options.cookie.git = {
    enable = mkEnableOption "Enables and configures git";
    name = mkOption rec {
      type = types.str;
      default = "ckie";
      description = "Username to use with git";
      example = default;
    };
    email = mkOption rec {
      type = types.str;
      default = "me@ronthecookie.me";
      description = "Email to use with git";
      example = default;
    };
    signingKey = mkOption rec {
      type = types.str;
      default = "6F5B32DE5E5FA80C";
      description = "GPG signing key to use with git";
      example = default;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { ... }: {
      programs.git = {
        enable = true;
        signing = {
          signByDefault = true;
          key = cfg.signingKey;
        };
        userEmail = cfg.email;
        userName = cfg.name;
        extraConfig = {
          pull = {
            rebase = true;
            ff = "only";
          };
          rebase = { autoStash = true; };
          init = { defaultBranch = "main"; };
        };
      };
    };
    programs.gnupg.agent.enable = true;
  };
}
