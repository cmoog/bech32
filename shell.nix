let
  pkgs = import (fetchTarball ("https://github.com/NixOS/nixpkgs/archive/edaae6a28c25cc9dafcbb1156f29ee834b38aeb9.tar.gz")) { };
in
with pkgs; mkShell {
  packages = [ cargo rustc ];
}
