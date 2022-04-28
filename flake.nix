{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
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
          bech32 = with pkgs; stdenv.mkDerivation
            {
              name = "bech32";
              src = self;
              nativeBuildInputs = [ crates rustc cargo ];
              buildPhase = "cargo build --release --offline";
              installPhase = "install -Dm775 ./target/release/bech32 $out/bin/bech32";
            };
          bech32-docker = with pkgs; import ./docker.nix { inherit bech32; inherit (pkgs) dockerTools; };
          bech32-app = {
            type = "app";
            program = "${bech32}/bin/bech32";
          };
        in
        {
          packages = { inherit bech32 bech32-docker; };
          defaultPackage = bech32;
          apps = { bech32 = bech32-app; };
          defaultApp = bech32-app;
          devShell = with pkgs; mkShell {
            packages = [ cargo rustc rust-analyzer rustfmt ];
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          };
        }
      );
}
