{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    import-cargo.url = github:edolstra/import-cargo;
    utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, import-cargo, utils }:
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (import-cargo.builders) importCargo;
          crates = (importCargo { lockFile = ./Cargo.lock; inherit pkgs; }).cargoHome;
        in
        with pkgs;
        {
          defaultPackage = stdenv.mkDerivation {
            name = "bech32";
            src = self;

            nativeBuildInputs = [ crates rustc cargo ];

            buildPhase = ''
              cargo build --release --offline
            '';

            installPhase = ''
              install -Dm775 ./target/release/bech32 $out/bin/bech32
            '';
          };
          devShell = mkShell {
            packages = [ cargo rustc rust-analyzer rustfmt ];
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          };
        }
      );
}
