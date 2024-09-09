{ pkgs, system }:
pkgs.writeShellScriptBin "sync-config" ''

    if [[ "${system}" == "aarch64-linux" ]]; then
        # The linux system was able to connect to the vault server, other OSs have problems
        rbw sync
    fi

    rbw search / --folder workspace | while read line ; do
        FILE=''${line:10}
        FIELDS=$(rbw get "$FILE" --raw --folder workspace | jq .fields)
        NOTES=$(rbw get "$FILE" --raw --folder workspace | jq -r .notes)

        mkdir -p $(dirname "$FILE")

        REMOTE_FILE=$(mktemp)
        if [[ "$NOTES" == "null" ]]; then
            echo $FIELDS | jq -r '.[] | "export " + .name + "=" + .value' > "$REMOTE_FILE"
        else
            echo "$NOTES" > "$REMOTE_FILE"
            sed -i 's/\\n/\n/g' "$REMOTE_FILE"
        fi

        if cmp --silent -- "$FILE" "$REMOTE_FILE"; then
            echo "."
        else
            if [[ "$1" == "run" ]]; then
                mv $REMOTE_FILE $FILE
            else 
                echo "$FILE is different"
                diff --new-file --color='auto' "$FILE" "$REMOTE_FILE"
            fi
        fi
    done

    if [[ "$1" == "" ]]; then
        echo "To confirm please execute: sync-config run"
    fi
''
