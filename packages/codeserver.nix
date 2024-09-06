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

      cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.code-server},g' | sed 's,/bin/code,/bin/code-server,g' > $out/bin/code
      chmod +x $out/bin/code

      mkdir -p $out/lib/systemd/system/
      echo "[Unit]" > $out/lib/systemd/system/code-server@.service
      echo "Description=code-server" >> $out/lib/systemd/system/code-server@.service
      echo "After=network.target" >> $out/lib/systemd/system/code-server@.service
      echo "" >> $out/lib/systemd/system/code-server@.service
      echo "[Service]" >> $out/lib/systemd/system/code-server@.service
      echo "Type=exec" >> $out/lib/systemd/system/code-server@.service
      echo "ExecStart=$out/bin/code --config $out/config/config.yaml" >> $out/lib/systemd/system/code-server@.service
      echo "Restart=always" >> $out/lib/systemd/system/code-server@.service
      echo "User=%i" >> $out/lib/systemd/system/code-server@.service
      echo "" >> $out/lib/systemd/system/code-server@.service
      echo "[Install]" >> $out/lib/systemd/system/code-server@.service
      echo "WantedBy=default.target" >> $out/lib/systemd/system/code-server@.service

      mkdir -p $out/config
      echo "bind-addr: 0.0.0.0:8080" > $out/config/config.yaml
      echo "auth: none" >> $out/config/config.yaml

    '';
}