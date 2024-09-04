{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "database";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.duckdb}/bin/duckdb $out/bin/duckdb
      ln -s ${pkgs.sqlite}/bin/sqlite3 $out/bin/sqlite3

      ls ${pkgs.sqlite}/bin
    '';
}