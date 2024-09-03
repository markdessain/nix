{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat  }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let 
          pkgs = import nixpkgs {inherit system;}; 
          terminal = import ./packages/terminal.nix { inherit pkgs; };
          tools = import ./packages/tools.nix { inherit pkgs; };
          programming = import ./packages/programming.nix { inherit pkgs; };

          thepackage = pkgs.writeShellScriptBin "testScript" ''
          '';
      in
        { 
          packages.default = thepackage;
          devShell = pkgs.mkShell {
            packages = [
             pkgs.glibcLocales
            ];

            buildInputs = [
              pkgs.coreutils
              terminal
              tools
              programming
            ];

            shellHook = ''
              export PATH=${pkgs.nix}/bin:${pkgs.bash}/bin:$(for input in $buildInputs; do echo -n "$input/bin:"; done | sed 's/:$//')
              startup
              echo 123456

              cd $(cat $HOME/.shell_path)
            '';
          };
        }
      );
}