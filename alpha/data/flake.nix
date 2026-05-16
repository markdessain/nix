{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    openspec.url = "github:Fission-AI/OpenSpec";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, flake-compat, openspec  }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let 
          pkgs = import nixpkgs {inherit system;}; 
          unstablePkgs = import nixpkgs-unstable {inherit system; config.allowInsecure = true; config.allowInsecurePredicate = _: true;};
          unFreePkgs = import nixpkgs {inherit system; config.allowUnfree = true;}; 
          allowBroken = import nixpkgs {inherit system; config.allowBroken = true;};
          bigModel = "azure/kimi-k2.6";
          smallModel = "google/gemini-2.5-flash";
      in
        { 
          devShell = pkgs.mkShell {
            packages = [
              pkgs.glibcLocales
              pkgs.cacert
              pkgs.coreutils
            ];

            env = {
              LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
                stdenv.cc.cc.lib glib nspr nss atk dbus xorg.libX11 xorg.libXcomposite 
                xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXrandr xorg.libxcb 
                mesa expat libxkbcommon udev alsa-lib at-spi2-core
              ];
            };

            buildInputs = [
              (import ./packages/terminal.nix { inherit pkgs system; })
              (import ./packages/tools.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/programming.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/data.nix { inherit pkgs system; })
              (import ./packages/config.nix { inherit pkgs system; })
              (import ./packages/codeserver.nix { inherit unFreePkgs system; })
              (import ./packages/vscode.nix { inherit pkgs unFreePkgs system; })
              (import ./packages/backup.nix { inherit pkgs system; })
              (import ./packages/ai.nix { inherit pkgs unstablePkgs system allowBroken smallModel bigModel openspec; })
              (import ./packages/linux.nix { inherit pkgs unFreePkgs system; })
              pkgs.playwright-driver.browsers
            ];

            shellHook = ''
              source startup ${pkgs.coreutils} ${pkgs.nix} $(for input in $buildInputs; do echo -n "$input "; done)
              source $TEMP_NIX_START
              export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
              export PLAYWRIGHT_CHROME_EXECUTABLE="/nix/store/vxp7ns5w4h5iih335s6jmdia6x7m6ww5-playwright-browsers/chromium-1181/chrome-linux/chrome"
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
              cd $(cat $HOME/.shell_path)
            '';
          };
        }
      );
}
