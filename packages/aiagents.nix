{ pkgs, system, allowBroken, bigModel, smallModel }:	

pkgs.stdenv.mkDerivation rec {
    pname = "aiagents";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
    ];

   
    installPhase = ''
      mkdir -p $out/bin

      echo "rm --force \$HOME/.config/opencode && ln -s $out/.config/opencode/ \$HOME/.config/opencode && opencode-binary --continue" > $out/bin/opencode
      chmod +x $out/bin/opencode

      mkdir -p $out/.config/opencode/

      cat <<EOT >> $out/.config/opencode/opencode.jsonc
        {
            "\$schema": "https://opencode.ai/config.json",
            "permission": {
              "edit": "ask",  
              "bash": "ask",
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

      <!-- OPENSPEC:START -->
      # OpenSpec Instructions

      These instructions are for AI assistants working in this project.

      Always open \`@/openspec/AGENTS.md\` when the request:
      - Mentions planning or proposals (words like proposal, spec, change, plan)
      - Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
      - Sounds ambiguous and you need the authoritative spec before coding

      Use \`@/openspec/AGENTS.md\` to learn:
      - How to create and apply change proposals
      - Spec format and conventions
      - Project structure and guidelines

      Keep this managed block so 'openspec update' can refresh the instructions.

      <!-- OPENSPEC:END -->
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


      # TODO can we do this with $out/bin/openspec init --tools open code
      # Otherwise the spec maybe out of date

      mkdir -p $out/.config/opencode/command
      cat <<EOT >> $out/.config/opencode/command/openspec-apply.md
      ---
      agent: build
      description: Implement an approved OpenSpec change and keep tasks in sync.
      ---
      <!-- OPENSPEC:START -->
      **Guardrails**
      - Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
      - Keep changes tightly scoped to the requested outcome.
      - Refer to \`openspec/AGENTS.md\` (located inside the \`openspec/\` directory—run \`ls openspec\` or \`openspec update\` if you don't see it) if you need additional OpenSpec conventions or clarifications.

      **Steps**
      Track these steps as TODOs and complete them one by one.
      1. Read \`changes/<id>/proposal.md\`, \`design.md\` (if present), and \`tasks.md\` to confirm scope and acceptance criteria.
      2. Work through tasks sequentially, keeping edits minimal and focused on the requested change.
      3. Confirm completion before updating statuses—make sure every item in \`tasks.md\` is finished.
      4. Update the checklist after all work is done so each task is marked \`- [x]\` and reflects reality.
      5. Reference \`openspec list\` or \`openspec show <item>\` when additional context is required.

      **Reference**
      - Use \`openspec show <id> --json --deltas-only\` if you need additional context from the proposal while implementing.
      <!-- OPENSPEC:END -->
      EOT


      mkdir -p $out/.config/opencode/command
      cat <<EOT >> $out/.config/opencode/command/openspec-archive.md
      ---
      agent: build
      description: Archive a deployed OpenSpec change and update specs.
      ---
      <ChangeId>
        \$ARGUMENTS
      </ChangeId>
      <!-- OPENSPEC:START -->
      **Guardrails**
      - Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
      - Keep changes tightly scoped to the requested outcome.
      - Refer to \`openspec/AGENTS.md\` (located inside the \`openspec/\` directory—run \`ls openspec\` or \`openspec update\` if you don't see it) if you need additional OpenSpec conventions or clarifications.

      **Steps**
      1. Determine the change ID to archive:
        - If this prompt already includes a specific change ID (for example inside a \`<ChangeId>\` block populated by slash-command arguments), use that value after trimming whitespace.
        - If the conversation references a change loosely (for example by title or summary), run \`openspec list\` to surface likely IDs, share the relevant candidates, and confirm which one the user intends.
        - Otherwise, review the conversation, run \`openspec list\`, and ask the user which change to archive; wait for a confirmed change ID before proceeding.
        - If you still cannot identify a single change ID, stop and tell the user you cannot archive anything yet.
      2. Validate the change ID by running \`openspec list\` (or \`openspec show <id>\`) and stop if the change is missing, already archived, or otherwise not ready to archive.
      3. Run \`openspec archive <id> --yes\` so the CLI moves the change and applies spec updates without prompts (use \`--skip-specs\` only for tooling-only work).
      4. Review the command output to confirm the target specs were updated and the change landed in \`changes/archive/\`.
      5. Validate with \`openspec validate --strict\` and inspect with \`openspec show <id>\` if anything looks off.

      **Reference**
      - Use \`openspec list\` to confirm change IDs before archiving.
      - Inspect refreshed specs with \`openspec list --specs\` and address any validation issues before handing off.
      <!-- OPENSPEC:END -->

      EOT

      mkdir -p $out/.config/opencode/command
      cat <<EOT >> $out/.config/opencode/command/openspec-proposal.md
      ---
      agent: build
      description: Scaffold a new OpenSpec change and validate strictly.
      ---
      The user has requested the following change proposal. Use the openspec instructions to create their change proposal.
      <UserRequest>
        \$ARGUMENTS
      </UserRequest>
      <!-- OPENSPEC:START -->
      **Guardrails**
      - Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
      - Keep changes tightly scoped to the requested outcome.
      - Refer to \`openspec/AGENTS.md\` (located inside the \`openspec/\` directory—run \`ls openspec\` or \`openspec update\` if you don't see it) if you need additional OpenSpec conventions or clarifications.
      - Identify any vague or ambiguous details and ask the necessary follow-up questions before editing files.

      **Steps**
      1. Review \`openspec/project.md\`, run \`openspec list\` and \`openspec list --specs\`, and inspect related code or docs (e.g., via \`rg\`/\`ls\`) to ground the proposal in current behaviour; note any gaps that require clarification.
      2. Choose a unique verb-led \`change-id\` and scaffold \`proposal.md\`, \`tasks.md\`, and \`design.md\` (when needed) under \`openspec/changes/<id>/\`.
      3. Map the change into concrete capabilities or requirements, breaking multi-scope efforts into distinct spec deltas with clear relationships and sequencing.
      4. Capture architectural reasoning in \`design.md\` when the solution spans multiple systems, introduces new patterns, or demands trade-off discussion before committing to specs.
      5. Draft spec deltas in \`changes/<id>/specs/<capability>/spec.md\` (one folder per capability) using \`## ADDED|MODIFIED|REMOVED Requirements\` with at least one \`#### Scenario:\` per requirement and cross-reference related capabilities when relevant.
      6. Draft \`tasks.md\` as an ordered list of small, verifiable work items that deliver user-visible progress, include validation (tests, tooling), and highlight dependencies or parallelizable work.
      7. Validate with \`openspec validate <id> --strict\` and resolve every issue before sharing the proposal.

      **Reference**
      - Use \`openspec show <id> --json --deltas-only\` or \`openspec show <spec> --type spec\` to inspect details when validation fails.
      - Search existing requirements with \`rg -n "Requirement:|Scenario:" openspec/specs\` before writing new ones.
      - Explore the codebase with \`rg <keyword>\`, \`ls\`, or direct file reads so proposals align with current implementation realities.
      <!-- OPENSPEC:END -->
      EOT

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
