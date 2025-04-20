{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "tools";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.k3s}/bin/k3s $out/bin/k3s
      ln -s ${pkgs.k3s}/bin/k3s-killall.sh $out/bin/k3s-killall.sh
      ln -s ${pkgs.k3s}/bin/kubectl $out/bin/kubectl
      ln -s ${pkgs.slirp4netns}/bin/slirp4netns $out/bin/slirp4netns
      ln -s /usr/bin/newgidmap $out/bin/newgidmap
      ln -s /usr/bin/newuidmap $out/bin/newuidmap
      ln -s ${pkgs.curl}/bin/curl $out/bin/curl
      ln -s ${pkgs.rbw}/bin/rbw $out/bin/rbw
      ln -s ${pkgs.rbw}/bin/rbw-agent $out/bin/rbw-agent
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s ${pkgs.zoxide}/bin/zoxide $out/bin/zoxide
      ln -s ${pkgs.jnv}/bin/jnv $out/bin/jnv
      ln -s ${pkgs.lsof}/bin/lsof $out/bin/lsof
      ln -s ${pkgs.zenith}/bin/zenith $out/bin/zenith
      ln -s ${pkgs.docker}/bin/docker $out/bin/docker

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s ${pkgs.docker-credential-helpers}/bin/docker-credential-osxkeychain $out/bin/docker-credential-osxkeychain
        ln -s ${pkgs.docker-credential-helpers}/bin/docker-credential-pass $out/bin/docker-credential-pass
      fi
      
      ln -s ${pkgs.speedtest-cli}/bin/speedtest $out/bin/speedtest
      ln -s ${pkgs.pinentry-tty}/bin/pinentry $out/bin/pinentry
      ln -s ${pkgs.jq}/bin/jq $out/bin/jq
      ln -s ${pkgs.miller}/bin/mlr $out/bin/mlr
      ln -s ${pkgs.mermaid-cli}/bin/mmdc $out/bin/mmdc
      ln -s ${pkgs.gnused}/bin/sed $out/bin/sed
      ln -s ${pkgs.gnugrep}/bin/grep $out/bin/grep
      ln -s ${pkgs.nano}/bin/nano $out/bin/nano
      ln -s ${pkgs.diffutils}/bin/cmp $out/bin/cmp
      ln -s ${pkgs.diffutils}/bin/diff $out/bin/diff
      ln -s ${pkgs.vim}/bin/vim $out/bin/vim
      ln -s ${pkgs.git}/bin/git $out/bin/git
      ln -s ${pkgs.gh}/bin/gh $out/bin/gh
      ln -s ${pkgs.gcc13}/bin/gcc $out/bin/gcc
      ln -s ${pkgs.flyctl}/bin/flyctl $out/bin/flyctl
      ln -s ${pkgs.flyctl}/bin/flyctl $out/bin/fly
      ln -s ${pkgs.doctl}/bin/doctl $out/bin/doctl
      ln -s /usr/bin/sudo $out/bin/sudo
      ln -s ${pkgs.openssh}/bin/scp $out/bin/scp
      ln -s ${pkgs.openssh}/bin/sftp $out/bin/sftp
      ln -s ${pkgs.openssh}/bin/ssh $out/bin/ssh
      ln -s ${pkgs.openssh}/bin/ssh-add $out/bin/ssh-add
      ln -s ${pkgs.openssh}/bin/ssh-copy-id $out/bin/ssh-copy-id
      ln -s ${pkgs.openssh}/bin/ssh-keygen $out/bin/ssh-keygen
      ln -s ${pkgs.openssh}/bin/ssh-keyscan $out/bin/ssh-keyscan
      ln -s ${pkgs.openssh}/bin/sshd $out/bin/sshd
      ln -s ${pkgs.hugo}/bin/hugo $out/bin/hugo
      ln -s ${pkgs.jira-cli-go}/bin/jira $out/bin/jira
      ln -s ${pkgs.less}/bin/less $out/bin/less
      ln -s ${pkgs.gawk}/bin/awk $out/bin/awk
      ln -s ${pkgs.gawk}/bin/which $out/bin/which
      ln -s ${pkgs.unzip}/bin/unzip $out/bin/unzip
      ln -s ${pkgs.zip}/bin/zip $out/bin/zip
      ln -s ${pkgs.ffmpeg}/bin/ffmpeg $out/bin/ffmpeg
      ln -s ${pkgs.coreutils}/bin/sha256sum $out/bin/sha256sum
      ln -s ${pkgs.findutils}/bin/find $out/bin/find
      ln -s ${pkgs.findutils}/bin/xargs $out/bin/xargs
      ln -s ${pkgs.binutils}/bin/ar $out/bin/ar
      ln -s ${pkgs.wasmer}/bin/wasmer $out/bin/wasmer

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo 'DOCKER_HOST=$(docker context inspect --format "{{.Endpoints.docker.Host}}") ${pkgs.act}/bin/act --container-architecture linux/amd64 --pull=false $@' >> $out/bin/act
      else
        echo 'DOCKER_HOST=$(docker context inspect --format "{{.Endpoints.docker.Host}}") ${pkgs.act}/bin/act --pull=false $@' >> $out/bin/act
      fi
      chmod +x $out/bin/act 

      echo 'sudo ${pkgs.k3s}/bin/k3s server --write-kubeconfig-mode 644 --disable=traefik' > $out/bin/k3s-server 
      chmod +x $out/bin/k3s-server

      echo 'docker save $1 | sudo ${pkgs.k3s}/bin/k3s ctr images import -' > $out/bin/k3s-image 
      chmod +x $out/bin/k3s-image
    '';
}