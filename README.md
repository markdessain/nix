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

