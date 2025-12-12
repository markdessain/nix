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

    duckdb = if system == "aarch64-linux" then pkgs.fetchzip {
      url = "https://github.com/duckdb/duckdb/releases/download/v1.4.1/duckdb_cli-linux-arm64.zip";
      sha256 = "sha256-aLeNzm4mKp/f+diGQWYbZDef9uBAfNpe/huYRAvBLNE=";
    } else if system == "aarch64-darwin" then pkgs.fetchzip {
      url = "https://github.com/duckdb/duckdb/releases/download/v1.4.1/duckdb_cli-osx-universal.zip";
      sha256 = "sha256-aLeNzm4mKp/f+diGQWYbZDef9uBAfNpe/huYRAvBLND=";
    }  else "missing";
 
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
        echo "skip duckdb"
        #exit 0
        # Not working at the moment
        #wget https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck/${dataDuckVersion}/data-duck-linux-arm64.gz
        #gzip -d ./data-duck-linux-arm64.gz
        #mv ./data-duck-linux-arm64 $out/bin/data-duck
        #chmod +x $out/bin/data-duck
      else
        echo "Unsupported system"
        exit 1
      fi

      ln -s ${duckdb}/duckdb $out/bin/duckdb

      cat <<EOT >> $out/bin/duckdb-init
      #!/bin/bash
      file=./.duckdb/init.sql

      if [[ ! -n "\$IGNOREDUCKDBINIT" ]]; then 
        if [ -e "\$file" ]; then
            $out/bin/duckdb -init \$file "\$@"
        else 
            $out/bin/duckdb "\$@"
        fi 
      else 
        $out/bin/duckdb "\$@"
      fi
     
      EOT
      chmod +x $out/bin/duckdb-init

    '';
}
