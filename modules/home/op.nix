{ pkgs, lib, config, ... }:

{
  # 1Password CLI wrapper for WSL2
  home.file.".local/bin/op" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    executable = true;
    text = ''
      #!/bin/bash
      OP_EXE="/mnt/c/Users/TsubasaOtsuki/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI_Microsoft.Winget.Source_8wekyb3d8bbwe/op.exe"
      OP_LINUX="${pkgs._1password-cli}/bin/op"

      # op run は Linux のバイナリを実行するため、Windows の op.exe では動作しない
      if [ "$1" = "run" ] && [ -x "$OP_LINUX" ]; then
        exec "$OP_LINUX" "$@"
      fi

      if [ ! -f "$OP_EXE" ]; then
        echo "[ERROR] op.exe not found at $OP_EXE" >&2
        exit 1
      fi

      OP_VARS=$(env | grep ^OP_ | cut -d= -f1 | tr '\n' ':')
      export WSLENV="''${WSLENV:-}:''${OP_VARS%:}"
      exec "$OP_EXE" "$@"
    '';
  };
}
