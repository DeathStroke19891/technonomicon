{
  description = "technonomicon";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        shell = import ./shell.nix {inherit pkgs;};
      in {
        devShells.${system}.default = shell;

        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "technonomicon";
          version = "0.0.1";
          src = ./.;

          nativeBuildInputs =
            shell.nativeBuildInputs
            ++ [
              pkgs.pnpmConfigHook
            ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit pname version src;
            hash = "sha256-vTagDXjIieRtHDjzOvi0V4VNVGJf1xfnyidNYaJQAkc=";
            fetcherVersion = 1;
          };

          buildPhase = ''
            pnpm run build
          '';

          installPhase = ''
            cp -r dist $out
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
