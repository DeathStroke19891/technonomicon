{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell
{
  nativeBuildInputs = [
    pkgs.nodejs_24
    pkgs.pnpm
  ];

  shellHook = ''
  '';
}
