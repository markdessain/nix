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
      in
        { 
          devShell = pkgs.mkShell {
            packages = [
              pkgs.glibcLocales
              pkgs.cacert
            ];

            buildInputs = [
              pkgs.coreutils
              (import ./packages/terminal.nix { inherit pkgs; })
              (import ./packages/tools.nix { inherit pkgs; })
              (import ./packages/programming.nix { inherit pkgs; })
            ];

            shellHook = ''
              export PATH=${pkgs.nix}/bin:${pkgs.bash}/bin:$(for input in $buildInputs; do echo -n "$input/bin:"; done | sed 's/:$//')
              startup
              cd $(cat $HOME/.shell_path)
            '';
          };
        }
      );
}