{ config, lib, pkgs, modulesPath, ... }:

{
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

}
