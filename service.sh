[Unit]
Description=code-server
After=network.target

[Service]
Type=exec
ExecStart=/nix/var/nix/profiles/default/bin/nix-shell --pure --command "zsh -c 'code'"
WorkingDirectory=/home/pi/projects/nix/alpha
Restart=always
User=%i

[Install]
WantedBy=default.target
