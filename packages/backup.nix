{ pkgs, system }:	

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

      echo "#!${pkgs.bash}/bin/bash -e" > $out/bin/backup
      chmod +x $out/bin/backup

      cat <<EOT >> $out/bin/backup
      WHOAMI=\$(whoami)
      if [[ ! "\$WHOAMI" == "root" ]]; then
        export USER_HOME=\$HOME
        sudo --preserve-env=USER_HOME $out/bin/backup \$@
        exit 0
      fi

      if [[ "\$1" == "local" ]]; then
        echo "Run Local"
      elif [[ "\$1" == "remote" ]]; then
        echo "Run Remote"
      else
        echo "Please run: backup [local|remote] [dry|run|adhoc|prune|<emtpy>]"
        exit
      fi
      source \$USER_HOME/.config/backup/\$1.env

      if [ ! -d "\$RESTIC_REPOSITORY" ]; then
        echo "\$RESTIC_REPOSITORY does exist."
        restic init
      fi

      if [[ "\$2" == "dry" ]]; then
        echo "Dry Run"
        DRY_RUN="--dry-run"
      elif [[ "\$2" == "run" ]]; then
        echo "Real Run"
        DRY_RUN=""
      elif [[ "\$2" == "adhoc" ]]; then
        echo "Interactive Run"
        shift
        shift
        restic "\$@"
        exit
      elif [[ "\$2" == "prune" ]]; then
        echo "Prune Run"
        if [[ "\$PRUNE_KEEP" == "" ]]; then
          PRUNE_KEEP="1m"
        fi
        restic forget --keep-within \$PRUNE_KEEP --prune
        exit
      else 
        restic snapshots

        echo "To do a dry run please execute: backup dry"
        echo "To confirm please execute: backup run"
        echo "To clean up please execute: backup prune"
        echo "To run adhoc command please execute: backup adhoc"
        echo "To restore execute: backup local adhoc restore <SNAPSHOT_ID> --target /"
        exit
      fi

      EOT

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "restic backup \"\$USER_HOME/Library/Application Support\"  --exclude-file $out/config/exclude --tag application_support \$DRY_RUN" >> $out/bin/backup
        echo "restic backup \"\$USER_HOME/projects\" --exclude-file $out/config/exclude --tag \"projects\" \$DRY_RUN" >> $out/bin/backup
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "restic backup \"\$USER_HOME/projects\" --exclude-file $out/config/exclude --tag \"projects\" \$DRY_RUN" >> $out/bin/backup
        echo "restic backup \"\$USER_HOME/.config\" --exclude-file $out/config/exclude --tag \"config\" \$DRY_RUN" >> $out/bin/backup
        echo "restic backup \"\$USER_HOME/.local/share\" --exclude-file $out/config/exclude --tag \"share\" \$DRY_RUN" >> $out/bin/backup
      else
        echo "" >> $out/bin/backup
      fi  

      cat <<EOT >> $out/bin/backup
      echo \$DOCKER_VOLUMES | jq -c '.[]' | while read i; do
          if [[ "\$2" == "run" ]]; then
            docker stop \$(echo \$i | jq -r ".container")
          fi

          VOLUME_NAME=\$(echo \$i | jq -r ".volume")
          VOLUME_TAG=\$(echo \$i | jq -r ".container")
          restic backup "\$VOLUME_NAME" --tag "\$VOLUME_TAG" \$DRY_RUN

          if [[ "\$2" == "runs" ]]; then
            docker start \$(echo \$i | jq -r ".container")
          fi
      done
      EOT

      cat <<EOT >> $out/bin/backup
      if [[ "\$2" == "" ]]; then
        echo "To confirm please execute: backup run"
      fi
      EOT

      mkdir -p $out/config
      cat <<EOT >> $out/config/exclude
      node_modules
      .venv
      dist/
      .cargo
      .rustup
      .cache
      go/pkgs
      go/bin
      .npm
      Library/Application Support/rancher-desktop/
      Library/Application Support/CallHistoryDB/
      Library/Application Support/CallHistoryTransactions/
      Library/Application Support/FaceTime/
      Library/Application Support/FileProvider/
      Library/Application Support/Knowledge/
      Library/Application Support/com.apple.TCC/
      Library/Application Support/com.apple.avfoundation/Frecents/
      Library/Application Support/com.apple.sharedfilelist/
      Library/Application Support/AddressBook/
      EOT
    '';
}