{ config, lib, pkgs, ... }:

{
  nix.buildMachines = [{
    hostName = "pansear";
    system = "x86_64-linux";
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  }];
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
