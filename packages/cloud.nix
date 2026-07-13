{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "cloud";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin

      ln -s ${pkgs.qemu}/bin/qemu-system-aarch64 $out/bin/qemu-system-aarch64    
      ln -s ${pkgs.cloud-utils}/bin/cloud-localds $out/bin/cloud-localds

      ln -s ${pkgs.azure-cli}/bin/az $out/bin/az
      ln -s ${pkgs.flyctl}/bin/flyctl $out/bin/flyctl
      ln -s ${pkgs.flyctl}/bin/flyctl $out/bin/fly
      ln -s ${pkgs.awscli2}/bin/aws $out/bin/aws
      ln -s ${pkgs.doctl}/bin/doctl $out/bin/doctl
    '';
}
