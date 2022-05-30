{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    import-cargo.url = github:edolstra/import-cargo;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, import-cargo, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (import-cargo.builders) importCargo;
        crates = (importCargo { lockFile = ./Cargo.lock; inherit pkgs; }).cargoHome;
        bech32 = with pkgs; stdenv.mkDerivation {
          name = "bech32";
          src = ./.;
          nativeBuildInputs = [ crates rustc cargo ];
          buildPhase = "cargo build --release --offline";
          installPhase = "install -Dm775 ./target/release/bech32 $out/bin/bech32";
        };
        bech32-docker = pkgs.dockerTools.buildImage {
          name = "bech32";
          tag = self.shortRev or "dirty";
          contents = [ bech32 ];
          config.Entrypoint = [ "bech32" ];
        };
        bech32-app = {
          type = "app";
          program = "${bech32}/bin/bech32";
        };
      in
      {
        packages = { default = bech32; inherit bech32-docker; };
        apps.default = bech32-app;
        devShells.default = with pkgs; mkShell {
          packages = [ cargo rustc rust-analyzer rustfmt ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
