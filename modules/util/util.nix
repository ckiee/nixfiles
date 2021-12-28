{ lib, pkgs }:

with lib;
with builtins;

rec {
  /* Resolve a "#Requires: " line using `pkgs` attributes

     Example:
       mkRequiresScriptTextWithName "wrapped-fooer" "some\n#Requires: bash\nmore"
       => <derivation "/nix/store/...wrapped-fooer">
  */
  mkRequiresScriptTextWithName = let prefix = "#Requires: ";
  in name: text:
  pkgs.writeScript name ''
    #!${pkgs.bash}/bin/bash
    ${(concatMapStringsSep "\n" (line:
      if hasPrefix prefix line then
        "export PATH=$PATH:${
          makeBinPath (map (pkgAttrId: pkgs.${pkgAttrId})
            (splitString " " (removePrefix prefix line)))
        }"
      else
        line) (splitString "\n" text))}
  '';


  /* Read a text file and resolve a "#Requires: " line using `pkgs` attributes

     Example:
       mkRequiresScript ./some_script
       => <a script with an "export PATH" line>
  */
  mkRequiresScript = path: mkRequiresScriptTextWithName "wrapped-${baseNameOf path}" (readFile path);
}
