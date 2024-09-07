#!/bin/bash

if [[ "$1" == "alpha" ]]
then
    echo "Setup alpha shell"
elif [[ "$1" == "beta" ]]
then
    echo "Setup beta shell"
else
    echo "Please select: [alpha|beta]"
    exit 1
fi


SHELL_NAME=$1
NIX_REPO_ROOT=$(dirname $(readlink -f $0))

cat <<EOT > /lib/systemd/system/nix-code-server@.service
[Unit]
Description=code-server
After=network.target

[Service]
Type=exec
ExecStart=/nix/var/nix/profiles/default/bin/nix-shell --pure --command "zsh -c 'code'"
WorkingDirectory=$NIX_REPO_ROOT/$SHELL_NAME
Restart=always
User=%i

[Install]
WantedBy=default.target
EOT
