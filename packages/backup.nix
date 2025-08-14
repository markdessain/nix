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
      set -e
      set -o pipefail

      WHOAMI=\$(whoami)
      if [[ ! "\$WHOAMI" == "root" ]]; then
        if [[ "\$DONTUSESUDO" == "" ]]; then
          export USER_HOME=\$HOME
          sudo --preserve-env=USER_HOME $out/bin/backup \$@
          exit 0
        else
          export USER_HOME=\$HOME
        fi
      fi

      if [[ "\$1" == "local" ]]; then
        A=1
      elif [[ "\$1" == "onsite" ]]; then
        A=1
      elif [[ "\$1" == "offsite" ]]; then
        A=1
      elif [[ "\$1" == "recovery" ]]; then
        A=1
      else
        echo "Please run: backup [local|recovery|onsite|offsite] [dry|run|home|services|adhoc|prune|<emtpy>]"
        exit
      fi
      source \$USER_HOME/.config/backup/\$1.env

      if [[ "\$1" == "onsite" ]]; then
      #   bash -c "umount \$BACKUP_MNT_DIR; rm -rf \$BACKUP_MNT_DIR; mkdir \$BACKUP_MNT_DIR; mount \$BACKUP_MNT_DEVICE \$BACKUP_MNT_DIR; exit 0"
      # 
        echo \$RESTIC_REPOSITORY
        if [ ! -d "\$RESTIC_REPOSITORY" ]; then
          echo "Unable to find drive"
          exit 1; 
        fi;
      fi


      if [[ "\$1" == "offsite" ]]; then
        # Need to init with adhoc command
        A=1
      else
        if [ ! -d "\$RESTIC_REPOSITORY" ]; then
          echo "\$RESTIC_REPOSITORY is empty or does not exist."
          restic init
        fi
      fi

      if [[ "\$2" == "dry" ]]; then
        DRY_RUN="--dry-run"
      elif [[ "\$2" == "run" ]]; then
        DRY_RUN=""
      elif [[ "\$2" == "home" ]]; then
        if [[ "\$1" == "onsite" ]]; then
          restic backup "/home" --tag home
        else
          echo "Home action can only be run with onsite"
        fi
        exit
      elif [[ "\$2" == "adhoc" ]]; then
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
        echo "To backup the whole home directory execute: backup home"
        echo "To clean up please execute: backup prune"
        echo "To run adhoc command please execute: backup adhoc"
        echo "To restore execute: backup local adhoc restore <SNAPSHOT_ID> --target /"
        echo "To view a single folder execute:  backup local adhoc ls --long --human-readable --recursive <SNAPSHOT_ID> <FOLDER_PATH>"
        echo "To view a single file execute: backup local adhoc dump <SNAPSHOT_ID> <FILE_PATH>"
        echo "To diff a single file execute: backup local adhoc dump <SNAPSHOT_ID> <FILE_PATH> | diff <FILE_PATH> -"
       
        exit 1
      fi

      if [[ "\$SERVICES_ONLY" == "true" ]]; then
        A=1
      else 
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

      # Ends the SERVICES_ONLY clause 
      echo "fi" >> $out/bin/backup  

      cat <<EOT >> $out/bin/backup
      echo \$DOCKER_VOLUMES | ${pkgs.jq}/bin/jq -c '.[]' | while read i; do
          VOLUME_NAME=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".volume")
          VOLUME_TAG=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".name")
          EXCLUDE=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".exclude")

          echo "Backup \$VOLUME_NAME"

          if [[ "\$2" == "run" ]]; then
            echo \$i | ${pkgs.jq}/bin/jq -r '.containers[]' | while read container; do
              echo "Stopping \$container"
              RUNNING=\$(docker ps --all --filter "status=exited" --filter "status=created" --filter "status=restarting" --filter "status=running" --filter "status=paused" --filter "status=dead" --filter "name=^"\$container --quiet)
              
              if [ "\$RUNNING" = "" ]; then
                  echo "Not running"
              else
                  docker stop \$RUNNING
              fi
            done
          fi

          restic backup "\$VOLUME_NAME" --tag "\$VOLUME_TAG" --exclude "\$EXCLUDE" \$DRY_RUN

          if [[ "\$2" == "run" ]]; then
            echo \$i | ${pkgs.jq}/bin/jq -r '.containers[]' | while read container; do
              echo "Starting \$container"
              RUNNING=\$(docker ps --all --filter "status=exited" --filter "status=created" --filter "status=restarting" --filter "status=running" --filter "status=paused" --filter "status=dead" --filter "name=^"\$container --quiet)
              
              if [ "\$RUNNING" = "" ]; then
                  echo "Not running"
              else
                  docker start \$RUNNING
              fi
            done
          fi
      done

      echo \$OTHER_VOLUMES | ${pkgs.jq}/bin/jq -c '.[]' | while read i; do

          VOLUME_PATH=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".volume")
          VOLUME_TAG=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".name")
          EXCLUDE=\$(echo \$i | ${pkgs.jq}/bin/jq -r ".exclude")
          restic backup "\$VOLUME_PATH" --tag "\$VOLUME_TAG" --exclude "\$EXCLUDE" \$DRY_RUN

      done


      # if [[ "\$1" == "onsite" ]]; then
        # umount \$BACKUP_MNT_DIR
        # rm -rf \$BACKUP_MNT_DIR
      # fi

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