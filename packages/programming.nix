{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "programming";
    version = "0.1.0";
    phases = [ "buildPhase" "installPhase" ];

    buildInputs = [
      pkgs.go
      pkgs.python3
    ];

    buildPhase = ''
    '';

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.go}/bin/go $out/bin/go
      ln -s ${pkgs.go}/bin/gofmt $out/bin/gofmt
      ln -s ${pkgs.python3}/bin/python3 $out/bin/python3
      ln -s ${pkgs.python3}/bin/python3 $out/bin/python
    '';
}