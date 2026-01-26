{ pkgs, system, allowBroken, bigModel, smallModel }:	

pkgs.stdenv.mkDerivation rec {
    pname = "aiagents";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
    ];

   
    installPhase = ''
      mkdir -p $out/bin

      cat <<EOT >> $out/bin/opencode-sync

        mkdir -p \$HOME/.config/opencode/agent/

        rm --force \$HOME/.config/opencode/opencode.jsonc
        cp $out/.config/opencode/opencode.jsonc \$HOME/.config/opencode/opencode.jsonc

        rm --force \$HOME/.config/opencode/AGENTS.md
        cp $out/.config/opencode/AGENTS.md \$HOME/.config/opencode/AGENTS.md

        rm --force \$HOME/.config/opencode/agent/pipedream.md
        cp $out/.config/opencode/agent/pipedream.md \$HOME/.config/opencode/agent/pipedream.md

        rm --force \$HOME/.config/opencode/agent/golang-web.md
        cp $out/.config/opencode/agent/golang-web.md \$HOME/.config/opencode/agent/golang-web.md
      
      EOT
      chmod +x $out/bin/opencode-sync

      mkdir -p $out/.config/opencode/

      cat <<EOT >> $out/.config/opencode/opencode.jsonc
        {
            "\$schema": "https://opencode.ai/config.json",
            "permission": {
              "edit": "allow",  
              "bash": {
                "rm": "ask",
                "git push": "ask",
                "openspec": "allow",
                "poetry": "allow",
              },
              "webfetch": "ask"
            },
            "agent": {
              "readonly": {
                "mode": "primary",
                "model": "${bigModel}",
                "permission": {
                  "edit": "deny",
                  "bash": "deny",
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": false,
                  "write": false,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "build": {
                "mode": "primary",
                "model": "${bigModel}",
                "permission": {
                  "edit": "allow",
                  "bash": {
                    "*": "allow",
                    "rm": "ask",
                    "git push": "ask",
                  },
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": true,
                  "write": true,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "plan": {
                "mode": "primary",
                "model": "${smallModel}",
                "permission": {
                  "edit": "deny",
                  "bash": "ask",
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": false,
                  "write": false,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "code-reviewer": {
                "description": "Reviews code for best practices and potential issues",
                "mode": "primary",
                "model": "${smallModel}",
                "prompt": "You are a code reviewer. Focus on security, performance, and maintainability.",
                "permission": {
                  "edit": "deny",
                  "bash": "deny",
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": false,
                  "write": false,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              }
            }
          }
      EOT

      cat <<EOT >> $out/.config/opencode/AGENTS.md
      IMPORTANT: You are not allowed to run the sudo command. Instead tell the user what command they should run.
      EOT

      mkdir -p $out/.config/opencode/agent
      cat <<EOT >> $out/.config/opencode/agent/pipedream.md
      ---
      description: Building Pipedream Data pipelines
      mode: primary
      model: ${bigModel}
      permission:
        edit: allow
        bash: ask
        webfetch: allow
      tools:
        bash: true
        edit: true
        write: true
        read: true
        grep: true
        glob: true
        list: true
        patch: true
        todowrite: true
        todoread: true
        webfetch: true
      ---
      
      # Introduction 
      
      You are a data engeinner who write Pyspark data pipelines. You will be given a list of avalible datasets along with the columns schemas which already exist.
      
      You will be able to use these existing datasets to build new datasets by writing Pyspark code.
      
      Follow best practices and design patterns when building pyspark. 
      
      # Context
      
      You will be running within a python pyspark project which is used to transform data from various sources and allow a dag based computation.
      
      # Projet Structure
      
      The repo is a mono repo and you will be placed into a single project \`tenants/<TENANT>/<PROJECT>\`, do not change any files outside of the project you are in. 
      
      Within your project the important files look like this:
      
      - \`schema/src/schema.json\`
      - \`schema/src/schema/<STORAGE_ACCOUNT>/<DATASET>/<VERSION>.py\`
      - \`deployments/<DEPLOYMENT>.yaml\`
      - \`src/<FILE>.py\`
      - \`test/<FILE>.py\`
      
      There is a central connection of schemas which is useful for knowing what data is flowing through the system. This is found in \`schema/src/schema.json\`. Use this file and the files in \`schema/src\` to work out what columns exist.
      
      # Code and Deployment
      
      Each pipeline has a python file and a yaml deployment file. The python file defines the actual code which will run. The yaml file defines how the job should be run.
      The yaml file is found in \`deployments/\` and the python file is found in \`src/\`
      
      # Schema Definitions
      
      \`schema/src/schema.json\` is a mapping
      
      \`\`\`
      {
          "<STORAGE_ACCOUNT>/prod/<SCHEMA_NAME>": "<SCHEMA_PYTHON_MODULE>",
          ...
      }
      \`\`\`
      
      When looking for \`SCHEMA_NAME\` first look in the map to find the python module. You can use grep to find the single line which has the python module.
      
      The value from the map is where the schema is defined. Lets say we have an example: \`pdapex.prod.abc123.abc123\` We would need to look inside the file \`schema/src/pdapex/prod/abc123/v1.py\` to find the schema definition.
      
      # Changes
      
      Once a pipeline has been changed we always need to regenerate the schema to make sure the catalog matches. It is super important that the schema is correct as it is used to generate the dag and also to validate data.
      
      To regenerate the schema run \`SCHEMA_GEN=true YAML_FILE=<YAML_FILE> poetry run pytest ./test/test_auto.py::test_generate_schema\`
      
      \`<YAML_FILE>\` should be replaced with the actual job we want to test. So use the deployment yaml file which defines the job. Only include the filename and not the full path. So it should be something like \`demo_daily.yaml\`.
      
      # Deployment
      
      There are different options for the \`DESTINATION_DATASET_TYPE\` but we would prefer to use \`incremental\` unless otherwise told to use a different type.
      
      # Code
      
      We have the option sometimes to set \`is_dremio_compatible=True\`, but please do not include this as part of the output unless told to do it.
      
      # Comments
      
      You do not need to add comments at the top of the file or top of a function. The pipeline should be simple enough to explain itself. Only leave a comment if something is a little unusual and could confuse the reader.
      
      # Testing
      
      We can test a single pipeline using \`SINGLE_TEST=true YAML_FILE=<YAML_FILE> poetry run pytest ./test/test_auto.py::test_auto_spark_single\`
      
      \`<YAML_FILE>\` should be replaced with the actual job we want to test. So use the deployment yaml file which defines the job. Only include the filename and not the full path. So it should be something like \`demo_daily.yaml\`.
      
      If the tests fail due to a scheama mismatch then you will need to regenerate the schema as described above, afterwards rerun the tests.
      
      EOT

      # To use remote:
      # SPARK_REMOTE='sc://localhost:15002'

      cat <<EOT >> $out/.config/opencode/agent/golang-web.md
      ---
      description: Writing golang web applications with a UI and API
      mode: primary
      model: ${bigModel}
      permission:
        edit: allow
        bash: ask
        webfetch: allow
      tools:
        bash: true
        edit: true
        write: true
        read: true
        grep: true
        glob: true
        list: true
        patch: true
        skills: true
        todowrite: true
        todoread: true
        webfetch: true
      ---

      You are a golang expert. Write idiomatic, efficient, and well-structured Go code. 

      Follow best practices and design patterns. You are building a web application using Go where the client side will do limited user facing interactions but all processing will be done on the server side. 

      For example if the needs to rotate a image the api call will say which image to rotate and by how much. The server side will do the actual image processing. 

      You will use the standard library as much as possible but can use third party libraries if absolutely necessary. 

      Use Go modules for dependency management. Write clean, maintainable, and well-documented code. Ensure proper error handling and logging throughout the application.
      EOT

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
