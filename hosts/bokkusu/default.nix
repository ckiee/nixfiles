{ config, pkgs, ... }: {
  imports = [ ./hardware.nix ../.. ];

  cookie = {
    services = {
      owo-bot.enable = true;
    };
  };

  networking.hostName = "bokkusu";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUV0RXaIzC4jtsdTPSlYoNbhtV+lyf334Hk74s3628N0k4GIuN6NJXpZDyWCV0v08/yRIVR8c7xSoUWqvREAsWdmSm7i8Dn3hjeM3SYZKn8XpKLYMJMBdCaPx4cmpuqgHmXZ+JMzNSAz1YjmPOKlYsXzOgKB1lHtMNH8PlMlVWBF+JP5xsHeyrj1J4BYyOdkQgxLOuRManwYHOIMTCcDs6+uYeBEDowpmYIm/+5jP7/bG3Mg6mTsNTAHQg9O3DI65BO/ub+P1G4z72CPF0nR3b9sem7bQcAP6FxxuNRIM1/vhVOAdTz2duW+QQOfCzSyO0Hvee6Mcs9o9xHHp4/lnj ronthecookie"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
