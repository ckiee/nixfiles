{ ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  inherit (pkgs) lib;
  bpkg = pkgs.writeScriptBin "bpkg" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    nix-build "$COOKIE_TOPLEVEL/pkgs" -A "$@"
  '';
  # throw is a keyword
  throwDeriv = pkgs.writeScriptBin "throw" ''
    mo deploy morph.nix switch --passwd --on $@
  '';
  rager = pkgs.writeScriptBin "rager" ''
        export PATH=$PATH:${lib.makeBinPath (with pkgs; [ rage mo ])}
        set -e
        export COOKIE_RAGER_BUILD=1
        export COOKIE_TOPLEVEL="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
        cd "$COOKIE_TOPLEVEL"
        function show_help {
          >&2 echo "Usage: rager {encrypt,decrypt,wrap}"
        }
        case "$1" in
          encrypt)
            if [ ! -d secrets ]
            then
              >&2 echo "no unencrypted secrets to encrypt"
              exit 1
            fi

            for machine in "$(mo build morph.nix)/"*
              do "$machine"/sw/cookie-rager-encrypt
            done
            rm -rf secrets
            ;;
          decrypt)
            tmp=$(mktemp -d)
            find "$(pwd)/encrypted" -type f -exec cp -nst "$tmp" {} + || true
            if [ -d secrets ]
            then
              >&2 echo "not continuing with existing secrets directory"
              rm -rf "$tmp"
              exit 1
            fi
            mkdir secrets
            for f in "$tmp"/*
                do out=secrets/"$(basename "$f")"
                rage -di ~/.ssh/id_rsa -o "$out" "$f"
                chmod 600 "$out"
            done
            rm -rf "$tmp"
            ;;
          wrap)
            self="$0"
            do_encrypt=0
            if [ ! -d secrets ]; then
              $self decrypt
              do_encrypt=1
            fi
            shift
            $@ || true
            if [ "$do_encrypt" != "0" ]; then
              $self encrypt
            fi
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
    throwDeriv
  ];
}
