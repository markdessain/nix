{ unFreePkgs }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "codeserver";
    version = "0.1.0";
    phases = [ "installPhase" ];

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = with unFreePkgs.vscode-extensions; []
      ++ unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
        { publisher = "golang"; name = "go"; version = "0.41.4"; sha256 = "sha256-ntrEI/l+UjzqGJmtyfVf/+sZJstZy3fm/PSWKTd7/Q0="; }
        { publisher = "ms-python"; name = "python"; version = "2024.6.0"; sha256 = "sha256-1clWeGT+fnj8HFROcw1jyGgRKYHNlt4VP6lPbFetCxE="; }
      ];
    };

    installPhase = ''
      mkdir -p $out/bin

      cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.code-server},g' | sed 's,/bin/code,/bin/code-server,g' > $out/bin/code2
      chmod +x $out/bin/code2

      echo "#!${unFreePkgs.bash}/bin/bash -e" > $out/bin/code
      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code
      chmod +x $out/bin/code

      mkdir -p $out/config
      echo "bind-addr: 0.0.0.0:8080" > $out/config/config.yaml
      echo "auth: none" >> $out/config/config.yaml

    '';
}
