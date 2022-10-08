{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    naersk.url = github:nix-community/naersk;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, naersk, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        naersk' = pkgs.callPackage naersk { };
        bech32 = naersk'.buildPackage {
          src = ./.;
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
        formatter = pkgs.nixpkgs-fmt;
        packages = { default = bech32; inherit bech32-docker; };
        apps.default = bech32-app;
        devShells.default = with pkgs; mkShell {
          packages = [ cargo rustc rust-analyzer rustfmt ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
