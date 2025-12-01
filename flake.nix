{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in with pkgs; {
        devShells.${system} = rec {
          default = mkShell {
            buildInputs = [ zig ];
          };
        };
      };
}
