{ config, lib, pkgs, ... }:

let
  cfg = config.cookie.git;
  mail-util = pkgs.callPackage ./services/mailserver/util.nix { };
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
      default = (builtins.head
        (mail-util.process (fileContents ../secrets/email-salt) [ "git" ]));
      description = "Email to use with git";
      example = default;
    };
    signingKey = mkOption rec {
      type = types.str;
      default = "13E79449C0525215";
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
