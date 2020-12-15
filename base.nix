{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (
      builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz"
    ) {
      inherit pkgs;
    };
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Israel";
  nixpkgs.config.allowUnfree = true;
  services.syncthing = {
    enable = true;
    user = "ron";
    dataDir = "/home/ron";
  };
  environment.systemPackages = with pkgs; [
    wget
    nano
    neofetch
    git
    gnupg
    pinentry
    pinentry_qt
    killall
    htop
  ];

  programs.gnupg.agent.enable = true;

  users.users.ron = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUV0RXaIzC4jtsdTPSlYoNbhtV+lyf334Hk74s3628N0k4GIuN6NJXpZDyWCV0v08/yRIVR8c7xSoUWqvREAsWdmSm7i8Dn3hjeM3SYZKn8XpKLYMJMBdCaPx4cmpuqgHmXZ+JMzNSAz1YjmPOKlYsXzOgKB1lHtMNH8PlMlVWBF+JP5xsHeyrj1J4BYyOdkQgxLOuRManwYHOIMTCcDs6+uYeBEDowpmYIm/+5jP7/bG3Mg6mTsNTAHQg9O3DI65BO/ub+P1G4z72CPF0nR3b9sem7bQcAP6FxxuNRIM1/vhVOAdTz2duW+QQOfCzSyO0Hvee6Mcs9o9xHHp4/lnj ronthecookie"
    ];
  };
}
