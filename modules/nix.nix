{ lib, config, pkgs, sources, ... }:

with lib;
let
  cfg = config.cookie.nix;
  sources = import ../nix/sources.nix;
in {
  options.cookie.nix = { enable = mkEnableOption "Nix.. I mean, lix!"; };

  imports = [
    (import "${sources.lix-nixos-module}/module.nix"
      (let lix = sources.lix-lix.outPath;
      in {
        inherit lix;
        versionSuffix =
          "pre${builtins.substring 0 8 lix.lastModifiedDate}-${lix.shortRev}";
      }))
  ];

  config = mkIf cfg.enable {
    # patch lix.. they will make it less scuffed eventually..
    nixpkgs.overlays = singleton (final: prev: {
      nixVersions = prev.nixVersions // rec {
        nix_2_18 = prev.nixVersions.nix_2_18.overrideAttrs (prev': {
          doInstallCheck = false;
        });
        stable = nix_2_18;
      };
    });

    # Setup the symlink for our global nixpkgs
    environment.extraSetup = ''
      ln -s ${sources.nixpkgs} $out/nixpkgs
    '';

    nix = {
      settings = {
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;
        experimental-features = "nix-command flakes";
        # https://bmcgee.ie/posts/2023/12/til-how-to-optimise-substitutions-in-nix/
        http-connections = 128;
        max-substitution-jobs = 128;
      };
      nixPath = [
        "nixpkgs=/run/current-system/sw/nixpkgs"
      ]; # Pin the <nixpkgs> channel to our nixpkgs
      # Garbage collect and optimize
      gc = {
        automatic = true;
        options = "--delete-older-than 8d";
        dates = "weekly";
      };
      # Get flakes
      package = pkgs.nix; # sometimes nixUnstable
      registry.nixpkgs = {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = {
          type = "path";
          # also done in ~/git/nixpkgs/nixos/modules/installer/cd-dvd/channel.nix
          # for the installer host (which is flashed onto a usb flash drive)
          # ..so we have to lower priority for this:
          path = mkDefault (if isStorePath sources.nixpkgs.outPath then
            "${builtins.trace "flake registry cleanSource nixpkgs..."
            (lib.cleanSource (builtins.trace "done!" sources.nixpkgs))}"
          else
            toString sources.nixpkgs.outPath);
        };
      };
    };
  };
}
