{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.polyprog;
  deriv = pkgs.writeScriptBin "polyprog" ''
    #!${pkgs.stdenv.shell}

    cleanup() {
    	echo "" >"$XDG_RUNTIME_DIR/polybar_polyprog_msg"
    	echo "hook:module/polyprog1" >>/tmp/polybar_mqueue.*
    }

    trap cleanup EXIT
    while read -r line; do
    	echo "$line" >"$XDG_RUNTIME_DIR/polybar_polyprog_msg"
    	echo "hook:module/polyprog1" >>/tmp/polybar_mqueue.*
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
