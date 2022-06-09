# A memorial for this ~~overengineered~~ridicolous hash function
with lib;
ip = mkOption {
  type = types.str;
  description = "the ip assigned to this peer";
  example = "10.67.75.13";
  default = let
    indexedAlphabet = (imap0 (i: x: { inherit i x; })
      (stringToCharacters "abcdefghijklmnopqrstuvwxyz123456789_?"));
    pow = let
      internal = base: exp: accum:
        if exp <= 1 then base else internal base (exp - 1) (accum * base);
    in base: exp: internal base exp base;
    shiftLeft = val: count: val * (pow 2 count);
    shiftRight = val: count: val / (pow 2 count);
    hash = foldl' bitXor 0 (imap0 (i: ch:
      let alphaCh = findFirst ({ x, i }: x == ch) "?" indexedAlphabet;
      in (mod (shiftLeft alphaCh.i i)
        65535)) # 0xffff, since netmask is a /16 = 16 bits = 2 bytes, -2 since .0 [lm]sb is not valid
      (stringToCharacters config.networking.hostName));
    msbyte = (shiftRight hash 8);
    lsbyte = (bitAnd hash (pow 2 8));
  in "10.67.${toString (msbyte + 1)}.${toString (lsbyte + 1)}";
};
