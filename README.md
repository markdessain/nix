# nix

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

