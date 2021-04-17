{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      signByDefault = true;
      key = "6F5B32DE5E5FA80C";
    };
    userEmail = "me@ronthecookie.me";
    userName = "Ron B";
    extraConfig = {
      pull = {
        rebase = true;
        ff = "only";
      };
      rebase = { autoStash = true; };
    };
  };
}
