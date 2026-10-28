# Contributing to JDAK

Thanks for helping make JDAK easier to use in a fresh vault. Bug reports, documentation corrections,
and focused improvements are welcome.

## Know which repository you are editing

`jdak-template` is generated from a working JDAK vault; it is not the source of truth for most files.
The regeneration script clears the template checkout and rebuilds its curated base content. A change made
only to generated output can therefore disappear on the next rebuild.

- Vault documents, kits, schemas, and skills come from their matching paths in the source vault.
- Runtime and extraction tools under `bin/` come from the workspace tools directory.
- `bin/regenerate-template.sh` defines the curated files and `base: true` skills that ship.

If you do not have access to the source vault, open an issue describing the source-level change needed.
A pull request against generated output can still be useful as a concrete proposed diff, but a maintainer
will need to port it to the source before merging.

## Make a focused change

Keep a pull request to one concern. Explain the observed problem, list the exact files changed, and avoid
including vault content that is specific to an owner, client, project, or private system. Never include
personal paths, private URLs, channel IDs, credentials, tokens, or secrets.

For behavior changes, update the nearest documentation and include a command or small reproduction that
shows the new behavior. For extraction changes, confirm both that the intended file ships and that no
instance-only file comes with it.

## Validate the generated result

From the workspace that contains the source `Vault/` and the template clone, rebuild without pushing:

```bash
PUSH=0 bash bin/regenerate-template.sh
```

Then inspect and validate the generated repository:

```bash
git -C tmp/jdak-template diff --name-only origin/main...HEAD
git -C tmp/jdak-template diff --check
bash -n bin/regenerate-template.sh tmp/jdak-template/bin/regenerate-template.sh
grep -RInE 'owner-specific-name|/absolute/personal/path|[0-9]{17,20}' \
  tmp/jdak-template --exclude-dir=.git
```

Replace the placeholder leak-check terms with any names, paths, private hosts, or identifiers present in
your source environment. Also run the narrow test for the files or behavior you changed. Review the final
generated diff—not only the source edit—before opening the pull request.

## Open the pull request

Use a descriptive title and a short body covering the problem, the specific change, and the verification
performed. Generated output should match the source-level change and contain no unrelated vault drift.
