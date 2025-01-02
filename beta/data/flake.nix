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

          # Sometimes needed for mac
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/darwin/apple-sdk/default.nix
          # pkgs.darwin.apple_sdk.frameworks.Security
          # pkgs.darwin.apple_sdk.frameworks.SystemConfiguration

          devShell = pkgs.mkShell {
            packages = [
              pkgs.glibcLocales
              pkgs.cacert
              pkgs.coreutils

              pkgs.darwin.apple_sdk.frameworks.CoreAudio
              pkgs.darwin.apple_sdk.frameworks.AudioToolbox
              pkgs.darwin.apple_sdk.frameworks.AudioUnit
              pkgs.darwin.apple_sdk.frameworks.CoreFoundation
              pkgs.darwin.apple_sdk.frameworks.CoreServices
              pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.darwin.apple_sdk.frameworks.Accelerate
              pkgs.darwin.apple_sdk.frameworks.Foundation
              pkgs.darwin.apple_sdk.frameworks.MetalKit
            ];

            buildInputs = [
              (import ./packages/terminal.nix { inherit pkgs; })
              (import ./packages/tools.nix { inherit pkgs system; })
              (import ./packages/programming.nix { inherit pkgs; })
              (import ./packages/kubernetes.nix { inherit pkgs; })
              (import ./packages/data.nix { inherit pkgs system; })
              (import ./packages/config.nix { inherit pkgs system; })
              (import ./packages/vscode.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/backup.nix { inherit pkgs system; })
              (import ./packages/ai.nix { inherit pkgs; })
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
