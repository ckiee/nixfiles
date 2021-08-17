{ options, config, lib, pkgs, ... }:

with lib;
let
  ckMkAliasAndWrapDefsWithPriority = option:
    let
      prio = option.highestPrio or defaultPriority;
      defsWithPrio = map (mkOverride prio) option.definitions;
    in ckMkAliasIfDef option (id (mkMerge defsWithPrio));

  ckMkAliasIfDef = option:
    mkIf (isOption option && option.isDefined
      && ((trace (showOption option.loc) (showOption option.loc))
        != "gtk.gtk3.waylandSupport"));
in {
  options.cookie = {
    home = mkOption {
      type = let this = options.home-manager.users.type.functor.wrapped; in builtins.trace (builtins.toJSON this) this;
      default = { };
      description = "home-manager configuration to be used";
    };
  };

  # This is very scary here; there's a weird nix bug where
  # if I don't explicitly import options at the top this breaks.
  config.home-manager.users.ckie =
    ckMkAliasAndWrapDefsWithPriority options.cookie.home;
  config.home-manager.extraSpecialArgs.name = "ckie";
}
