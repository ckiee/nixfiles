{ ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "e44faef21c38e3885cf2ed874ea700d3f0260448";
    ref = "master";
  };
in {
  imports = [ (import "${home-manager}/nixos") ];

  home-manager.users.ron = { ... }: {
    imports = [
      ./polybar.nix
      ./bash.nix
      ./git.nix
      ./gtk.nix
      ./dunst.nix
      ./emacs.nix
      ./keyboard.nix
      ./redshift.nix
      ./st.nix
    ];
  };
}
