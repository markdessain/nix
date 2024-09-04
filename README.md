# nix

## Shell

Setup the `shell` command

bash
```bash

SHELL_NAME=alpha
#SHELL_NAME=beta

cat <<EOT >> $HOME/.bashrc

if type nix-shell >/dev/null 2>&1
then
  alias shell="echo \$PWD > \$HOME/.shell_path && rm -f $PWD/$SHELL_NAME/packages && cp -r $PWD/packages $PWD/$SHELL_NAME/data && cd $PWD/$SHELL_NAME && nix-shell --pure --command zsh"
fi

EOT

```

zsh
```bash

cat <<EOT >> $HOME/.zshrc

if type nix-shell >/dev/null 2>&1
then
  alias shell="echo \$PWD > \$HOME/.shell_path && rm -f $PWD/$SHELL_NAME/packages && cp -r $PWD/packages $PWD/$SHELL_NAME/data && cd $PWD/$SHELL_NAME && nix-shell --pure --command zsh"
fi

EOT

```

## Other Commands

```bash

if [[ -z "${IN_NIX_SHELL}" ]]; then

  ...

fi

if type atuin >/dev/null 2>&1
then
  eval "$(atuin init zsh)"
fi

if type nix-shell >/dev/null 2>&1
then
  alias shell="echo \$PWD > \$HOME/.shell_path && cd \$HOME/projects/nix && nix-shell --command zsh"
fi



