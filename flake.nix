{
  description = "A simple command-line utilty for encoding and decoding bech32 strings.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, naersk, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          naersk' = pkgs.callPackage naersk { };
          bech32 = naersk'.buildPackage {
            src = ./.;
          };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          packages.default = bech32;
          devShells.default = with pkgs; mkShell {
            packages = [ cargo rustc rust-analyzer rustfmt ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        }
      ) // {
      hydraJobs = {
        inherit (self) packages devShells;
      };
    };
}
