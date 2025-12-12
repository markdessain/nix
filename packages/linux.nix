{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "mac";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.ddcutil}/bin/ddcutil $out/bin/ddcutil
      ln -s ${pkgs.solaar}/bin/solaar $out/bin/solaar
      ln -s ${pkgs.bluez}/bin/bluetoothctl $out/bin/bluetoothctl
    '';
}