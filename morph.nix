with builtins;

let
  sources = import ./nix/sources.nix;
  networkPkgs = import sources.nixpkgs { allowUnfree = true; };
in {
  network = {
    pkgs = networkPkgs;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
    evalConfig =
      # This is a wrapper around the NixOS evalConfig to add an edge-case for our _metadata host
      evalConfigArgs@{ extraArgs ? { }, specialArgs ? { }, modules, check ? true
      , prefix ? [ ] }:
      let
        originalFn = import (networkPkgs.path + "/nixos/lib/eval-config.nix");
        isMetadata = extraArgs.name == "_metadata" && check;
      in originalFn
      ((removeAttrs evalConfigArgs [ "extraArgs" "specialArgs" "check" ]) // {
        modules = modules ++ [
          ({ ... }: {
            _module = {
              check = if isMetadata then false else check;
              args = extraArgs;
            };
            deployment.tags = networkPkgs.lib.optional (!isMetadata) "real";
          })
        ];
      } // (if isMetadata then {
        baseModules = [ ({ ... }: { _module.args.pkgs = networkPkgs; }) ];
      } else
        { }));
  };

  # Tailscale hosts
  "bokkusu" = import ./hosts/bokkusu;
  "cookiemonster" = import ./hosts/cookiemonster;
  "drapion" = import ./hosts/drapion;
  "pookieix" = import ./hosts/pookieix;
  "thonkcookie" = import ./hosts/thonkcookie;
  "pansear" = import ./hosts/pansear;
  # Special
  "_metadata" = import ./hosts/_metadata;
}
