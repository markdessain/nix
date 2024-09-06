{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "backup";
    version = "0.1.0";
    phases = [ "installPhase" ];

    buildInputs = [
    ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.rsync}/bin/rsync $out/bin/rsync
      ln -s ${pkgs.rclone}/bin/rclone $out/bin/rclone
      ln -s ${pkgs.restic}/bin/restic $out/bin/restic
    '';
}