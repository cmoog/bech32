{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    import-cargo.url = github:edolstra/import-cargo;
  };

  outputs = { self, nixpkgs, import-cargo }:
    let
      inherit (import-cargo.builders) importCargo;
    in
    {

      defaultPackage.x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation {
          name = "bech32";
          src = self;

          nativeBuildInputs = [
            (importCargo { lockFile = ./Cargo.lock; inherit pkgs; }).cargoHome
            rustc
            cargo
          ];

          buildPhase = ''
            cargo build --release --offline
          '';

          installPhase = ''
            install -Dm775 ./target/release/bech32 $out/bin/bech32
          '';
        };
    };
}
