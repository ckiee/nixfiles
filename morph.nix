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
      let originalFn = import (networkPkgs.path + "/nixos/lib/eval-config.nix");
      in originalFn (if extraArgs.name == "_metadata" && check then
        evalConfigArgs // {
          baseModules = [
            ({ ... }: {
              _module.args.pkgs = networkPkgs;
              _module.args.nodes = extraArgs.nodes;
              _module.check = false;
            })
          ];
          # extraArgs = evalConfigArgs.extraArgs // { pkgs = networkPkgs; };
        }
      else
        evalConfigArgs // {
          modules = modules ++ [ ({ ... }: { deployment.tags = [ "real" ]; }) ];
        });

  };

  # Tailscale hosts
  "bokkusu" = import ./hosts/bokkusu;
  "cookiemonster" = import ./hosts/cookiemonster;
  "drapion" = import ./hosts/drapion;
  "pookieix" = import ./hosts/pookieix;
  "thonkcookie" = import ./hosts/thonkcookie;
  # Special
  "_metadata" = import ./hosts/_metadata;
}
