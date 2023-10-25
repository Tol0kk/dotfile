{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.asm;
  nasm-exec = pkgs.writeShellScriptBin "nasm-exec" ''
    INPUT_FILE="$1"

    if [ ! -e "$INPUT_FILE" ]; then
        echo "You need to give an .asm file"
        exit 1
    fi

    if [[ "$INPUT_FILE" != *.asm ]]; then
        echo "$INPUT_FILE is not an .asm file"
        exit 1
    fi

    OBJECT_FILE=$(basename "$INPUT_FILE" | sed "s/.asm$/.o/g")
    EXECUTABLE_FILE=$(basename "$INPUT_FILE" | sed "s/.asm$//g")

    ### Compiling
    nasm -g -f elf64 "$INPUT_FILE" -o "$OBJECT_FILE"

    if [ ! -f $OBJECT_FILE ]; then
        exit 1
    fi

    ### Linking
    ld "$OBJECT_FILE" -o "$EXECUTABLE_FILE"

    ### Executing
    ./$EXECUTABLE_FILE

    rm -fr "$OBJECT_FILE" "$EXECUTABLE_FILE"
  '';
in
{
  options.modules.dev.languages.asm = {
    enable = mkOption {
      description = "Enable asm language component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gf
      gdb
      nasm
      unixtools.xxd # Binary format file 
      nasm-exec
    ];

  };
}
