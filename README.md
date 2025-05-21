# nix

## Mac

The Tabby nix does not seem to work well so please install with brew

```
brew install tabbyml/tabby/tabby
tabby serve --device metal --model StarCoder-1B --chat-model Qwen2-1.5B-Instruct
```

And follow the instructions: https://github.com/projectdiscovery/katana#installation

## Update Nix

```bash
nix --extra-experimental-features "nix-command flakes" flake update
```

## Install Nix

```bash
curl -L https://nixos.org/nix/install | sh
curl https://releases.nixos.org/nix/nix-2.28.2/install | sh
```

## Uninstall Nix

Guide here: https://nix.dev/manual/nix/2.28/installation/uninstall

```bash
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

sudo dscl . -delete /Groups/nixbld
for u in $(sudo dscl . -list /Users | grep _nixbld); do sudo dscl . -delete /Users/$u; done

sudo vifs
sudo nano /etc/synthetic.conf

sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
sudo diskutil apfs deleteVolume /nix
diskutil list
sudo rm /etc/bashrc.backup-before-nix
```

## Shell

Run `./setup.sh [alpha|beta]`

## Other Commands which should not be included

```bash

if [[ -z "${IN_NIX_SHELL}" ]]; then

  ...

fi

if type atuin >/dev/null 2>&1
then
  eval "$(atuin init zsh)"
fi

...

```

## Secrets

Due to a cert issue with rbw it is sometimes not possible to connect to bitwardern from inside the shell. The `shell_secrets` will run the commands on the host os to get all the secrets synced locally.

