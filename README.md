# nix

Setup the `shell` command

bash
```bash

cat <<EOT >> $HOME/.bashrc

if type nix-shell >/dev/null 2>&1
then
  alias shell="echo \$PWD > \$HOME/.shell_path && cd $PWD && nix-shell --command zsh"
fi

EOT

```

zsh
```bash

cat <<EOT >> $HOME/.zshrc

if type nix-shell >/dev/null 2>&1
then
  alias shell="echo \$PWD > \$HOME/.shell_path && cd $PWD && nix-shell --command zsh"
fi

EOT

```