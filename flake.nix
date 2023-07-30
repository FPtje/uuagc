{
  # Usage:
  # nix develop .#devShellxx.x86_64-linux -c env --chdir=uuagc/trunk/ cabal build
  # Where the xx is a ghc version
  description = "A simple flake to be able to build uuagc with different GHC versions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # The argument with-hls decides whether the haskell-language-server is included. This is
      # disabled by default, because it is not always on cachix and can take quite a while to build.
      makeDevShell = {with-hls ? false, haskellPackages}: pkgs.mkShell {
        buildInputs = with haskellPackages; [
          cabal-install
          (ghcWithPackages (self: with self; [
            uulib
            minisat
            containers
            directory
            array
            mtl
            haskell-src-exts
            filepath
            aeson
            bytestring
          ]))
          (if with-hls then haskell-language-server else null)
        ];
      };
    in {
    devShell90 = makeDevShell {with-hls = false; haskellPackages = pkgs.haskell.packages.ghc90; };
    devShell92 = makeDevShell {with-hls = false; haskellPackages = pkgs.haskell.packages.ghc92; };
    devShell94 = makeDevShell {with-hls = false; haskellPackages = pkgs.haskell.packages.ghc94; };
    devShell96 = makeDevShell {with-hls = false; haskellPackages = pkgs.haskell.packages.ghc96; };
    devShell = self.outputs.devShell96.${system};
  });
}
