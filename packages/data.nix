{ pkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "database";
    version = "0.1.0";
    phases = [ "installPhase" ];

    dataDuckVersion = "v0.47.0";

    buildInputs = [
      pkgs.wget
      pkgs.cacert
    ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.duckdb}/bin/duckdb $out/bin/duckdb
      ln -s ${pkgs.sqlite}/bin/sqlite3 $out/bin/sqlite3

      if [[ "${system}" == "aarch64-darwin" ]]; then
        wget https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck/${dataDuckVersion}/data-duck-mac-arm64.gz
        gzip -d ./data-duck-mac-arm64.gz
        mv ./data-duck-mac-arm64 $out/bin/data-duck
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


    '';
}