{ ... }:

{
  imports = [
    # Supporting
    ./postgres.nix
    ./nginx.nix
    # System
    ./avahi.nix
    ./ssh.nix
    ./prometheus.nix
    # User
    ./minecraft.nix
    ./grafana.nix
    ./coredns.nix
    ./znc.nix
    # Home baked
    ./ronthecookieme.nix
    ./rtc-files.nix
    ./comicfury.nix
    ./owo-bot.nix
    ./ffg-bot.nix
    ./redirect-farm.nix
  ];
}
