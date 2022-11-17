{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.nix-index;
  pkg = pkgs.nix-index;
in with lib; {
  options.cookie.nix-index = {
    enable = mkEnableOption
      "Enables nix-index, it provides a command-not-found hook to replace the one we broke";
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      source ${
        pkgs.runCommand "cmd-not-found-ckie.sh" { } ''
          cp ${pkg}/etc/profile.d/command-not-found.sh $out
          substituteInPlace $out --replace "command_not_found_handle () {" "command_not_found_handle_orig () {"
          cat ${
            pkgs.writeText "cmd-not-found-ckie-hook" ''
              # https://github.com/Mic92/dotfiles/blob/8a0c2b646b5056876ccd6f45aed7f57aa95b51a3/home/.zshrc#L162
              command_not_found_handle() {
                NIX_AUTO_RUN=1
                mkdir -p ~/.cache/nix-index
                pushd ~/.cache/nix-index >/dev/null
                if [ ! -e files ] || [[ ! $(find files -mtime +13 -print) ]]; then
                  local filename="index-x86_64-$(uname | tr A-Z a-z)"
                  # -N will only download a new version if there is an update.
                  wget -q -N https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
                  ln -f $filename files
                fi
                popd >/dev/null
                command_not_found_handle_orig "$@"
              }
            ''
          } >> $out
        ''
      }
    '';
  };
}
