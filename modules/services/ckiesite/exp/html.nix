{ lib ? pkgs.lib, pkgs, ... }:

with builtins;
with lib;

rec {
  done = sym:element/done;
  element = {
    e = true;
    __functor = self: arg:
      if arg == done then with self;
        let
          have = (head args) != (last args);
          set =
            { ${if
                self ? hid && hid != name
                then "id" else null
               } = hid; }
            // (if have then head args else {});
          kv = optionalString (set != {}) (" " +
            (concatStringsSep " "
              (mapAttrsToList (k: v: ''${k}="${v}"'') set)));
        in
        ''
        <${name}${kv}>
          ${
            if isString (last args) then last args
            else concatStringsSep "\n" (mapAttrsToList
              (n: x: if x?e then
                (x // { hid = n; }) done
                else toString x)
              (last args))
          }
        </${name}>''
      else self // { args = self.args ++ singleton arg; };
    args = [ ];
    make = name: element // { inherit name; };
  };
  html = element.make "html";
  body = element.make "body";
  main = element.make "main";
  h1 = element.make "h1";


  index = html { lang = "en"; } {
    body = body {
      main = main {
        hi = h1 "helo";
      };
    };
  };

  render = e: "<!doctype html>${e done}";
  _ = render index;
  Z = trace _ 0;
}

# <html lang="">
#     <head>
#         <meta charset="utf-8">
#         <meta http-equiv="x-ua-compatible" content="ie=edge">
#         <title>Untitled</title>
#         <meta name="description" content="">
#         <meta name="viewport" content="width=device-width, initial-scale=1">
#     </head>
#     <body>
#       <p>hello world!</p>
#     </body>
# </html>
