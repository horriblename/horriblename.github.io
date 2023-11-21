{
  description = "A very basic flake";
  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs ["x86_64-linux"];
    pkgsFor = eachSystem (
      system:
        import nixpkgs {
          localSystem = system;
          overlays = [self.overlays.default];
        }
    );
  in {
    overlays = {
      default = final: prev: {
        staticSite = final.callPackage ./default.nix {};
      };
    };

    packages = eachSystem (system: {
      default = self.packages.${system}.staticSite;
      inherit (pkgsFor.${system}) staticSite;
    });

    devShells = eachSystem (system: let
      pkgs = pkgsFor.${system};
    in {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [zola];
      };
    });
  };
}
