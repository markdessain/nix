{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "tools";
    version = "0.1.0";
    phases = [ "installPhase" ];

    versitygw = if system == "aarch64-linux" then "" else pkgs.versitygw;  

    zed_app = if system == "aarch64-darwin" then pkgs.callPackage ./mac_apps/zed.nix {} else "missing"; 
    rtk = if system == "aarch64-darwin" then pkgs.rtk else "missing"; 

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/Applications

      ln -s /usr/bin/newgidmap $out/bin/newgidmap
      ln -s /usr/bin/newuidmap $out/bin/newuidmap

      if [[ "${versitygw}" != "" ]]; then
        ln -s ${versitygw}/bin/versitygw $out/bin/versitygw
      fi

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s /usr/bin/nettop $out/bin/nettop
      fi

      ln -s /bin/ps $out/bin/ps
      ln -s /usr/bin/pkill $out/bin/pkill

      ln -s ${pkgs.proxychains-ng}/bin/proxychains4 $out/bin/proxychains4
      ln -s ${pkgs.mitmproxy}/bin/mitmproxy $out/bin/mitmproxy
      ln -s ${pkgs.dua}/bin/dua $out/bin/dua
      ln -s ${pkgs.ripgrep}/bin/rg $out/bin/rg
      ln -s ${pkgs.curl}/bin/curl $out/bin/curl
      ln -s ${pkgs.rbw}/bin/rbw $out/bin/rbw
      ln -s ${pkgs.rbw}/bin/rbw-agent $out/bin/rbw-agent
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s ${pkgs.zoxide}/bin/zoxide $out/bin/zoxide
      ln -s ${pkgs.jnv}/bin/jnv $out/bin/jnv
      ln -s ${pkgs.lsof}/bin/lsof $out/bin/lsof
      ln -s ${pkgs.zenith}/bin/zenith $out/bin/zenith
      ln -s ${pkgs.tmux}/bin/tmux $out/bin/tmux
      ln -s ${pkgs.chisel}/bin/chisel $out/bin/chisel      
      ln -s ${pkgs.speedtest-cli}/bin/speedtest $out/bin/speedtest
      ln -s ${pkgs.pinentry-tty}/bin/pinentry $out/bin/pinentry
      ln -s ${pkgs.jq}/bin/jq $out/bin/jq
      ln -s ${pkgs.miller}/bin/mlr $out/bin/mlr
      ln -s ${pkgs.mermaid-cli}/bin/mmdc $out/bin/mmdc
      ln -s ${pkgs.gnused}/bin/sed $out/bin/sed
      ln -s ${pkgs.nano}/bin/nano $out/bin/nano
      ln -s ${pkgs.diffutils}/bin/cmp $out/bin/cmp
      ln -s ${pkgs.vim}/bin/vim $out/bin/vim
      ln -s ${pkgs.vim}/bin/vim $out/bin/vi
      ln -s ${pkgs.gh}/bin/gh $out/bin/gh
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
      ln -s ${pkgs.findutils}/bin/xargs $out/bin/xargs
      ln -s ${pkgs.binutils}/bin/ar $out/bin/ar
      ln -s ${pkgs.wasmer}/bin/wasmer $out/bin/wasmer
      ln -s ${pkgs.pv}/bin/pv $out/bin/pv
      ln -s ${pkgs.gnutar}/bin/tar $out/bin/tar
      ln -s ${pkgs.pre-commit}/bin/pre-commit $out/bin/pre-commit
      ln -s ${pkgs.gum}/bin/gum $out/bin/gum
      ln -s ${pkgs.mutt}/bin/mutt $out/bin/mutt
      ln -s ${pkgs.lynx}/bin/lynx $out/bin/lynx
      ln -s ${pkgs.gzip}/bin/gzip $out/bin/gzip
      ln -s ${pkgs.d2}/bin/d2 $out/bin/d2
      ln -s ${pkgs.tree}/bin/tree $out/bin/tree
      ln -s ${pkgs.repomix}/bin/repomix $out/bin/repomix
      ln -s ${unFreePkgs.terraform}/bin/terraform $out/bin/terraform
      ln -s ${pkgs.redis}/bin/redis-cli $out/bin/redis-cli
      ln -s ${pkgs.redis}/bin/redis-server $out/bin/redis-server
      ln -s ${pkgs.ripgrep}/bin/ripgrep $out/bin/ripgrep
      ln -s ${pkgs.socat}/bin/socat $out/bin/socat

      ln -s ${pkgs.azure-storage-azcopy}/bin/azcopy $out/bin/azcopy
      ln -s ${pkgs.azure-cli}/bin/az $out/bin/az

      if [[ "${system}" == "aarch64-darwin" ]]; then

      ln -s ${rtk}/bin/rtk $out/bin/rtk

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s ${zed_app}/Applications/Zed.app $out/Applications/Zed.app
      fi

      cat <<EOT >> $out/bin/git
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk git "\$@"
      else
          command ${pkgs.git}/bin/git "\$@";
      fi
      EOT
      chmod +x $out/bin/git

      cat <<EOT >> $out/bin/ls
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk ls "\$@"
      else
          command ${pkgs.coreutils}/bin/ls "\$@";
      fi
      EOT
      chmod +x $out/bin/ls
    
      cat <<EOT >> $out/bin/find
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk find "\$@"
      else
          command ${pkgs.findutils}/bin/find "\$@";
      fi
      EOT
      chmod +x $out/bin/find

      cat <<EOT >> $out/bin/grep
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk grep "\$@"
      else
          command ${pkgs.gnugrep}/bin/grep "\$@";
      fi
      EOT
      chmod +x $out/bin/grep

      cat <<EOT >> $out/bin/read
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk read "\$@"
      else
          command read "\$@";
      fi
      EOT
      chmod +x $out/bin/read

      cat <<EOT >> $out/bin/diff
      #!/bin/bash
      if [[ -n "\$ZED_ENVIRONMENT" ]] && [[ ! "\$DO_NOT_USE_RTK" = "true" ]]; then
          DO_NOT_USE_RTK=true rtk diff "\$@"
      else
          command ${pkgs.diffutils}/bin/diff --color "\$@";
      fi
      EOT
      chmod +x $out/bin/diff

      cat <<EOT >> $out/.env
        alias read=$out/bin/read
        alias ls=$out/bin/ls
        alias diff=$out/bin/diff
      EOT

      else
        ln -s ${pkgs.diffutils}/bin/diff $out/bin/diff
        ln -s ${pkgs.gnugrep}/bin/grep $out/bin/grep
        ln -s ${pkgs.git}/bin/git $out/bin/git
        ln -s ${pkgs.findutils}/bin/find $out/bin/find
      fi


      cat <<EOT >> $out/bin/precommit-changes
      #!/bin/bash
      pre-commit run --files \$(git ls-files -m -o --exclude-standard  ':(top)')
      EOT
      chmod +x $out/bin/precommit-changes

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo 'DOCKER_HOST=$(docker context inspect --format "{{.Endpoints.docker.Host}}") ${pkgs.act}/bin/act --container-architecture linux/amd64 --pull=false $@' >> $out/bin/act
      else
        echo 'DOCKER_HOST=$(docker context inspect --format "{{.Endpoints.docker.Host}}") ${pkgs.act}/bin/act --pull=false $@' >> $out/bin/act
      fi
      chmod +x $out/bin/act 

    '';
}
