### Code taken from nix-rice/color.nix
{ lib, ... }:
let
  inherit (builtins) getAttr hasAttr;
  inherit (lib.lists) foldl all drop head last tail;
  inherit (lib.strings) stringToCharacters toUpper match floatToString concatStringsSep;
  inherit (lib.trivial) max min toHexString;
  ## 8BIT
  # Check if `v` is in 8Bit format
  _is8Bit = (a: b: v: (v <= max a b) && (v >=min a b)) 0.0 255.0;

  ## UNARY
  # Check if input is in [0, 1]
  _isUnary = (a: b: v: (v <= max a b) && (v >=min a b)) 0.0 1.0;

  # Parse input for hex triplet
  #
  # Es: _match3hex "001122" => ["00" "11" "22"]
  _match3hex = match "([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})";
  
  # Parse input for hex quadruplet
  #
  # Es: _match3hex "00112233" => ["00" "11" "22" "33"]
  _match4hex = match "([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})";

  # Parse a single hexadecimal digit to an integer
  _parseDigit = c:
    let
      k = toUpper c;
      dict = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
    in
    assert(hasAttr k dict);
    getAttr k dict;

  # Convert an hexadecimal string to an integer
  _hexToDec = s:
    let
      characters = stringToCharacters s;
      values = map _parseDigit characters;
    in
    foldl (acc: n: acc * 16 + n) 0 values;

  # Convert decimal to hex
  _decToHex =
    toHexString;

in
rec {
  # RGBA constructor
  #
  # Uses [0,255] float representation for all fields
  rgba = { r, g, b, a ? 255.0 }:
    let
      c = { inherit r g b a; };
    in
    assert(isRgba c); c;

  # Check if input is a valid RGBA color
  isRgba = c:
    let
      hasAttributes = all (k: hasAttr k c) [ "r" "g" "b" "a" ];
      validRanges = all (k: _is8Bit (getAttr k c)) [ "r" "g" "b" "a" ];
    in
    hasAttributes && validRanges;

  ## DESERIALIZATION
  # Parse a hex color string to a RGBA color
  #
  # Es: hexToRgba "0000FF" => { a = 255; b = 255; g = 0; r = 0; }
  # Es: hexToRgba "00FF0055" => { a = 85; b = 0; g = 255; r = 0; }
  hexToRgba = hex:
    let
      rgbaVal = _match4hex hex;
      rgbVal = _match3hex hex;
      hex_list = if null == rgbVal then rgbaVal else rgbVal ++ [ "FF" ];
      values = map (hex: _hexToDec hex) hex_list;
    in
    rgba {
      r = head values;
      g = head (tail values);
      b = head (drop 2 values);
      a = last values;
    };

  # Parse a hex color string and a Opacity to a RGBA color
  #
  # Es: hexToRgba "0000FF" 0.60 => { a = 255; b = 255; g = 0; r = 0; }
  # Es: hexToRgba "00FF0055" 0.60 => { a = 85; b = 0; g = 255; r = 0; }
  hexAndOpacityToRgba = hex: opacity:
    let
      rgbVal = _match3hex hex;
      hex_list = rgbVal;
      values = map (s: _hexToDec s) hex_list;
    in
    rgba {
      r = head values;
      g = head (tail values);
      b = head (drop 2 values);
      a = opacity * 255;
    };

  ## SERIALIZATION
  # Print rgba(r, g, b, a)
  toRGBA = { r, g, b, a ? 255.0 }:
    let
      _r = floatToString r;
      _g = floatToString g;
      _b = floatToString b;
      _a = floatToString (a / 255.0);
    in
    "rgba(${_r},${_g},${_b},${_a})";

  # Print rgba(r, g, b, a)
  toRGB = { r, g, b, a ? 255.0 }:
    let
      _r = floatToString r;
      _g = floatToString g;
      _b = floatToString b;
    in
    "rgba(${_r},${_g},${_b})";

  # Print #aarrggbb
  to0xARGB = { r, g, b, a ? 255.0 }:
    let
      _r = _decToHex r;
      _g = _decToHex g;
      _b = _decToHex b;
      _a = _decToHex a;
    in
    "0x${_a}${_r}${_g}${_b}";

  toGradiant = hexList: angle:
    let
      argblist = map (hex: (to0xARGB (hexToRgba hex))) hexList;
      argbstring = concatStringsSep " " argblist;
      _angle = floatToString angle;
    in
    "${argbstring} ${_angle}deg";
}