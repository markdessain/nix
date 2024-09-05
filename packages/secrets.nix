{ pkgs }:
pkgs.writeShellScriptBin "sync-secrets" ''
    rbw search / --folder workspace | while read line ; do
        FILE=''${line:10}
        FIELDS=$(rbw get "$FILE" --raw --folder workspace | jq .fields)
        NOTES=$(rbw get "$FILE" --raw --folder workspace | jq -r .notes)

        mkdir -p $(dirname "$FILE")

        if [[ "$NOTES" == "null" ]]; then
            echo $FIELDS | jq -r '.[] | "export " + .name + "=" + .value' > "$FILE"
        else
            echo "$NOTES" > "$FILE"
            sed -i 's/\\n/\n/g' "$FILE"
        fi
    done
''