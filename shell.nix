{ ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  inherit (pkgs) lib;
  bpkg = pkgs.writeScriptBin "bpkg" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    nix-build "$COOKIE_TOPLEVEL/pkgs" -A "$@"
  '';
  rager = pkgs.writeScriptBin "rager" ''
    export PATH=$PATH:${lib.makeBinPath (with pkgs; [ rage mo ])}
        set -e
        export COOKIE_RAGER_BUILD=1
        export COOKIE_TOPLEVEL="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
        cd "$COOKIE_TOPLEVEL"
        function show_help {
          >&2 echo "Usage: rager {encrypt,decrypt}"
        }
        case "$1" in
          encrypt)
            for machine in "$(mo build morph.nix)/"*
              do "$machine"/sw/cookie-rager-encrypt
            done
            ;;
          decrypt)
            tmp=$(mktemp -d)
            find "$(pwd)/encrypted" -type f -exec cp -st "$tmp" {} +
            if [ -d secrets ]
            then
              >&2 echo "not continuing with existing secrets directory"
              exit 1
            fi
            mkdir secrets
            for f in "$tmp"/*
              do rage -di ~/.ssh/id_rsa -o secrets/"$(basename "$f")" "$f"
            done
            rm -rf "$tmp"
            ;;
          *)
            show_help
            exit 1
            ;;
        esac
      '';
  mo = pkgs.writeScriptBin "mo" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel) ${pkgs.morph}/bin/morph $@
  '';
in pkgs.mkShell {
  buildInputs = with pkgs; [
    niv
    mo
    nix-prefetch-scripts
    nix-prefetch-github
    bpkg
    rager
  ];
}
