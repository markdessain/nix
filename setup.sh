
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

if [[ "$SHELL" == "/bin/zsh" ]]
then
    SHELL_RC=$HOME/.zshrc
elif [[ "$SHELL" == "/bin/bash" ]]
then
    SHELL_RC=$HOME/.bashrc
else
    echo "Please use shell: [/bin/zsh|/bin/bash]"
    exit 1
fi

SHELL_NAME=$1
NIX_REPO_ROOT=$(dirname $(readlink -f $0))

cat <<EOT >> $SHELL_RC

if type nix-shell >/dev/null 2>&1
then
  if [[ -z "\${IN_NIX_SHELL}" ]]
  then

    function shell() {
        echo \$PWD > $NIX_REPO_ROOT/.shell_path 
        rm -f $NIX_REPO_ROOT/$SHELL_NAME/packages 
        cp -r $NIX_REPO_ROOT/packages $NIX_REPO_ROOT/$SHELL_NAME/data 
        cd $NIX_REPO_ROOT/$SHELL_NAME 
        nix-shell --pure --command zsh
    }

    function shell_secrets() {
        echo \$PWD > $NIX_REPO_ROOT/.shell_path 
        rm -f $NIX_REPO_ROOT/$SHELL_NAME/packages 
        cp -r $NIX_REPO_ROOT/packages $NIX_REPO_ROOT/$SHELL_NAME/data 
        cd $NIX_REPO_ROOT/$SHELL_NAME 
        PATH=\$(echo \$(dirname \$(realpath \$(nix-shell --pure --command "zsh -c 'which rbw'" | tail -1)))):\$PATH 
        rbw config set pinentry \$(nix-shell --pure --command "zsh -c 'which pinentry'" | tail -1)
        rbw sync
    }

    function shell_vscode() {
        echo \$PWD > $NIX_REPO_ROOT/.shell_path 
        rm -f $NIX_REPO_ROOT/$SHELL_NAME/packages 
        cp -r $NIX_REPO_ROOT/packages $NIX_REPO_ROOT/$SHELL_NAME/data 
        cd $NIX_REPO_ROOT/$SHELL_NAME 
        exec \$(nix-shell --pure --command "zsh -c 'which code'" | tail -1)
    }
  fi
fi

EOT