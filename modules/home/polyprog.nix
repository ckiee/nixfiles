{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.polyprog;
  deriv = pkgs.writeScriptBin "polyprog" ''
    #!${pkgs.stdenv.shell}

    cleanup() {
    	echo "" >"$XDG_RUNTIME_DIR/polybar_polyprog_msg"
    	for mqueue in /tmp/polybar_mqueue.*; do (echo "hook:module/polyprog1" >> $mqueue &); done
    }

    trap cleanup EXIT
    while read -r line; do
    	echo "$line" >"$XDG_RUNTIME_DIR/polybar_polyprog_msg"
      # some of these subshells will never return
    	for mqueue in /tmp/polybar_mqueue.*; do (echo "hook:module/polyprog1" >> $mqueue &); done
    done </dev/stdin

    cleanup
  '';
in with lib; {
  options.cookie.polyprog = {
    enable = mkEnableOption "Installs the polyprog script, a script that takes lines from stdin and shoves them on the main polybar";
  };

  config = mkIf cfg.enable {
    home.packages = [ deriv ];
  };
}
