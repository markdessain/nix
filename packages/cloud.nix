{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "cloud";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin

      ln -s ${pkgs.qemu}/bin/qemu-system-aarch64 $out/bin/qemu-system-aarch64    
      ln -s ${pkgs.cloud-utils}/bin/cloud-localds $out/bin/cloud-localds
    '';
}
