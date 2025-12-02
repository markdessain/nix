{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
          allowBroken = import nixpkgs {inherit system; config.allowBroken = true;};
          bigModel = "google/gemini-2.5-pro";
          smallModel = "google/gemini-2.5-flash";
      in
        { 
          devShell = pkgs.mkShell {
            packages = [
              pkgs.glibcLocales
              pkgs.cacert
              pkgs.coreutils
            ];

            buildInputs = [
              (import ./packages/terminal.nix { inherit pkgs system; })
              (import ./packages/tools.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/programming.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/data.nix { inherit pkgs system; })
              (import ./packages/config.nix { inherit pkgs system; })
              (import ./packages/codeserver.nix { inherit unFreePkgs system; })
              (import ./packages/vscode.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/backup.nix { inherit pkgs system; })
              (import ./packages/ai.nix { inherit pkgs system allowBroken smallModel bigModel; })
              (import ./packages/aiagents.nix { inherit pkgs system allowBroken smallModel bigModel; })
              (import ./packages/linux.nix { inherit pkgs unFreePkgs system; })
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
