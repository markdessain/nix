{ unFreePkgs }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "tools";
    version = "0.1.0";
    phases = [ "installPhase" ];

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = with unFreePkgs.vscode-extensions; []
      ++ unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
        { publisher = "golang"; name = "go"; version = "0.41.4"; sha256 = "sha256-ntrEI/l+UjzqGJmtyfVf/+sZJstZy3fm/PSWKTd7/Q0="; }
        { publisher = "ms-azuretools"; name = "vscode-docker"; version = "1.29.1"; sha256 = "sha256-uleZLIkfOxKan+U56fKEwUjaleig07zdEwQKzsAzan0="; }
        { publisher = "ms-toolsai"; name = "jupyter"; version = "2024.6.0"; sha256 = "sha256-T+8K/NbuWYnJk+cXekiDpmpnZAJ7jl/nqPQgWQ49mco="; }
        { publisher = "ms-python"; name = "python"; version = "2024.6.0"; sha256 = "sha256-1clWeGT+fnj8HFROcw1jyGgRKYHNlt4VP6lPbFetCxE="; }
        { publisher = "evilz"; name = "vscode-reveal"; version = "4.3.3"; sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo="; }
        { publisher = "ms-python"; name = "debugpy"; version = "2024.8.0"; sha256 = "sha256-gvuYfyVIehy3ItJVfQbL/d8gO2KOl2rg9pBrmJuZeME="; }
        { publisher = "ms-toolsai"; name = "jupyter-renderers"; version = "1.0.18"; sha256 = "sha256-4EKXaWsafonBK7TftjVUBK3ujqD+OguXV0y/bWoWTyk="; }
        { publisher = "ms-toolsai"; name = "jupyter-keymap"; version = "1.1.2"; sha256 = "sha256-9BLyBZzZ0Z6QQ05QSxFJYNZmZDc5O3eYkCxe/UsmKws="; }
        { publisher = "ms-toolsai"; name = "vscode-jupyter-cell-tags"; version = "0.1.9"; sha256 = "sha256-XODbFbOr2kBTzFc0JtjiDUcCDBX1Hd4uajlil7mhqPY="; }
      ];
    };

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${vcsodeWithExtension}/bin/code $out/bin/code
    '';
}