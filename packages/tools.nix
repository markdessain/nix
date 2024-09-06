{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "tools";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.curl}/bin/curl $out/bin/curl
      ln -s ${pkgs.rbw}/bin/rbw $out/bin/rbw
      ln -s ${pkgs.rbw}/bin/rbw-agent $out/bin/rbw-agent
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s ${pkgs.zoxide}/bin/zoxide $out/bin/zoxide
      ln -s ${pkgs.jnv}/bin/jnv $out/bin/jnv
      ln -s ${pkgs.zenith}/bin/zenith $out/bin/zenith
      ln -s ${pkgs.act}/bin/act $out/bin/act
      ln -s ${pkgs.docker}/bin/docker $out/bin/docker
      ln -s ${pkgs.speedtest-cli}/bin/speedtest $out/bin/speedtest
      ln -s ${pkgs.pinentry-tty}/bin/pinentry $out/bin/pinentry
      ln -s ${pkgs.jq}/bin/jq $out/bin/jq
      ln -s ${pkgs.gnused}/bin/sed $out/bin/sed
      ln -s ${pkgs.gnugrep}/bin/grep $out/bin/grep
      ln -s ${pkgs.nano}/bin/nano $out/bin/nano
      ln -s ${pkgs.vim}/bin/vim $out/bin/vim
      ln -s ${pkgs.git}/bin/git $out/bin/git
      ln -s ${pkgs.openssh}/bin/scp $out/bin/scp
      ln -s ${pkgs.openssh}/bin/sftp $out/bin/sftp
      ln -s ${pkgs.openssh}/bin/ssh $out/bin/ssh
      ln -s ${pkgs.openssh}/bin/ssh-add $out/bin/ssh-add
      ln -s ${pkgs.openssh}/bin/ssh-copy-id $out/bin/ssh-copy-id
      ln -s ${pkgs.openssh}/bin/ssh-keygen $out/bin/ssh-keygen
      ln -s ${pkgs.openssh}/bin/ssh-keyscan $out/bin/ssh-keyscan
      ln -s ${pkgs.openssh}/bin/sshd $out/bin/sshd
    '';
}