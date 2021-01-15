{ config, pkgs, ... }: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "Paper";
      package = pkgs.paper-gtk-theme;
    };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };
}
