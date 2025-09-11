{ pkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "database";
    version = "0.1.0";
    phases = [ "installPhase" ];

    dataDuckVersion = "v0.128.0";

    buildInputs = [
      pkgs.wget
      pkgs.cacert
    ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.sqlite}/bin/sqlite3 $out/bin/sqlite3
      ln -s ${pkgs.rqlite}/bin/rqlite $out/bin/rqlite
      ln -s ${pkgs.rqlite}/bin/rqlited $out/bin/rqlited
      ln -s ${pkgs.postgresql_16}/bin/psql $out/bin/psql

      if [[ "${system}" == "aarch64-darwin" ]]; then
        wget https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck/${dataDuckVersion}/data-duck-macos-arm64.gz
        gzip -d ./data-duck-macos-arm64.gz
        mv ./data-duck-macos-arm64 $out/bin/data-duck
        chmod +x $out/bin/data-duck
      elif [[ "${system}" == "aarch64-linux" ]]; then
        exit 0
        # Not working at the moment
        wget https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck/${dataDuckVersion}/data-duck-linux-arm64.gz
        gzip -d ./data-duck-linux-arm64.gz
        mv ./data-duck-linux-arm64 $out/bin/data-duck
        chmod +x $out/bin/data-duck
      else
        echo "Unsupported system"
        exit 1
      fi

      if [[ "${system}" == "aarch64-darwin" ]]; then
      cat <<EOT >> $out/bin/duckdb
      #!/bin/bash
      file=./.duckdb/init.sql

      if [[ ! -n "\$IGNOREDUCKDBINIT" ]]; then 
        if [ -e "\$file" ]; then
            $out/bin/duckdb-binary -init \$file \$@
        else 
            $out/bin/duckdb-binary \$@
        fi 
      else 
        $out/bin/duckdb-binary \$@
      fi
     
      EOT
      chmod +x $out/bin/duckdb
      fi

      if [[ "${system}" == "aarch64-darwin" ]]; then

        wget https://github.com/duckdb/duckdb/releases/download/v1.3.2/duckdb_cli-osx-universal.gz
        gzip -d ./duckdb_cli-osx-universal.gz
        mv ./duckdb_cli-osx-universal $out/bin/duckdb-binary
        chmod +x $out/bin/duckdb-binary
      elif [[ "${system}" == "aarch64-linux" ]]; then
        ln -s ${pkgs.duckdb}/bin/duckdb $out/bin/duckdb
      else
        echo "Unsupported system"
        exit 1
      fi



    '';
}
