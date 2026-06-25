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
      sha256 = "sha256-vXmNXdxGNgJwYeyiYihw1kxoGohPDK4NbO3dqIYCd8g=";
    }  else "missing";
 
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.sqlite}/bin/sqlite3 $out/bin/sqlite3
      ln -s ${pkgs.rqlite}/bin/rqlite $out/bin/rqlite
      ln -s ${pkgs.rqlite}/bin/rqlited $out/bin/rqlited
      ln -s ${pkgs.postgresql_16}/bin/psql $out/bin/psql
      ln -s ${duckdb}/duckdb $out/bin/duckdb
    '';
}
