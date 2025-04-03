{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "mac";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${unFreePkgs.vault}/bin/vault $out/bin/vault

      cat >$out/bin/vault_secrets  <<EOL
      ACCOUNT=\$1 # orbit
      METHOD=\$2 # get
      SECRET=\$3 # secret/development/superset/state_api_password

      for row in \$(cat ~/.vault-config | jq -r ".[] | @base64"); do

        _jq() {
          echo \$row | base64 --decode | jq -r \$1
        }

        NAME=\$(_jq ".name")
        KV=\$(_jq ".kv")
        ROLE_ID=\$(_jq ".role_id")
        SECRET_ID=\$(_jq ".secret_id")
        ADDRESS=\$(_jq ".address")

        if [[ "\$NAME" == "\$ACCOUNT" ]]; then

            CHOSEN_ACCOUNT=\$(cat ~/.vault-account)
            if [[ "\$NAME" == "\$CHOSEN_ACCOUNT" ]]; then
              vault token lookup -address=\$ADDRESS > /dev/null 2>&1

              if [[ "\$?" == "0" ]]; then
                  echo "Logged In"
              else
                  TOKEN=\$(vault write -address=\$ADDRESS auth/approle/login role_id=\$ROLE_ID secret_id=\$SECRET_ID -format=json | jq -r .auth.client_token)
                  echo \$TOKEN | vault login -address=\$ADDRESS -no-print -
                  echo \$NAME > ~/.vault-account 
              fi
            else
            TOKEN=\$(vault write -address=\$ADDRESS auth/approle/login role_id=\$ROLE_ID secret_id=\$SECRET_ID -format=json | jq -r .auth.client_token)
            echo \$TOKEN | vault login -address=\$ADDRESS -no-print -
            echo \$NAME > ~/.vault-account 
            fi

          vault kv \$METHOD -address=\$ADDRESS -mount=\$KV \$SECRET
        fi

      done
      EOL

      chmod +x $out/bin/vault_secrets

    '';
}