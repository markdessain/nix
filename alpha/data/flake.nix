{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat  }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let 
          pkgs = import nixpkgs {inherit system;}; 
          unFreePkgs = import nixpkgs {inherit system; config.allowUnfree = true;}; 
      in
        { 
          devShell = pkgs.mkShell {
            packages = [
              pkgs.glibcLocales
              pkgs.cacert
              pkgs.coreutils
            ];

            buildInputs = [
              (import ./packages/terminal.nix { inherit pkgs; })
              (import ./packages/tools.nix { inherit pkgs; })
              (import ./packages/programming.nix { inherit pkgs; })
              (import ./packages/data.nix { inherit pkgs system; })
              (import ./packages/secrets.nix { inherit pkgs; })
              (import ./packages/codeserver.nix { inherit unFreePkgs; })
              (import ./packages/backup.nix { inherit pkgs; })
            ];

            shellHook = ''
              source startup ${pkgs.coreutils} ${pkgs.nix} $(for input in $buildInputs; do echo -n "$input "; done)
              source $TEMP_NIX_START
              cd $(cat $HOME/.shell_path)
            '';
          };
        }
      );
}
