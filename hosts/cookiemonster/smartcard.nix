{ config, lib, pkgs, ... }:

{
  services.pcscd = { enable = true; };
  services.vsmartcard-vpcd.enable = true;
  environment.systemPackages = with pkgs; [ pcsc-tools ];
}
