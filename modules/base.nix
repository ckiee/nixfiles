{ config, pkgs, ... }:

{
  imports = [ ./cachix.nix ];
  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball
  #     "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #       inherit pkgs;
  #     };
  # };

  nix.trustedUsers = [ "root" "@wheel" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = [ "ntfs" ];
  networking.networkmanager.enable = true;
  time.timeZone = "Israel";
  nixpkgs.config.allowUnfree = true;
  boot.tmpOnTmpfs = true; # i have no idea why this isnt the default
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 8d";

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.syncthing = {
    enable = true;
    user = "ron";
    dataDir = "/home/ron";
  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    neofetch
    git
    killall
    htop
    file
    cachix
    nix-prefetch-github # i just use this so much
    inetutils
    binutils-unwrapped
    pciutils
    usbutils
  ];

  programs.gnupg.agent.enable = true;

  services.openssh.enable = true;

  users.users.ron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUV0RXaIzC4jtsdTPSlYoNbhtV+lyf334Hk74s3628N0k4GIuN6NJXpZDyWCV0v08/yRIVR8c7xSoUWqvREAsWdmSm7i8Dn3hjeM3SYZKn8XpKLYMJMBdCaPx4cmpuqgHmXZ+JMzNSAz1YjmPOKlYsXzOgKB1lHtMNH8PlMlVWBF+JP5xsHeyrj1J4BYyOdkQgxLOuRManwYHOIMTCcDs6+uYeBEDowpmYIm/+5jP7/bG3Mg6mTsNTAHQg9O3DI65BO/ub+P1G4z72CPF0nR3b9sem7bQcAP6FxxuNRIM1/vhVOAdTz2duW+QQOfCzSyO0Hvee6Mcs9o9xHHp4/lnj ronthecookie"
    ];
    initialPassword = config.networking.hostName;
  };
}
