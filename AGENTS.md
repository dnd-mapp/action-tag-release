# Agent instructions

## Project

This repository is the composite GitHub Action `dnd-mapp/action-tag-release`. The action in `action.yaml` runs on a push to the base branch. When the push is the merge of a release pull request that the GitHub App opened, it creates the annotated `vX.Y.Z` tag on the merge commit with the app token. Read `CONTRIBUTING.md` for the layout, the checks, the release steps, and the commit and branch conventions.

- Keep the action to creating the release tag. Preparing the release, staging the package, and creating the GitHub Release belong elsewhere.
- Tag only the merge commit of a release pull request that the app opened. Treat every other push as a push to skip, never as a push to tag.
- Create the tag through the REST API with the app token, never with `GITHUB_TOKEN`, because a tag pushed with `GITHUB_TOKEN` does not start the release workflow.
- Report every failure as an error annotation, with `run_annotated` or `annotate_error` from `scripts/annotate.sh`, so the run summary shows why the action failed.
- Pass inputs and step outputs into `run` scripts through `env`, and read them as shell variables. A `${{ }}` expression belongs in an `env` value, never inside the script.
- Treat the input and output names and their defaults as a contract. When you change one, update `action.yaml`, the README tables, and the changelog in the same commit, and mark the change as breaking.
- Pin every third-party action to a commit SHA and note the version in a comment.
- Run `format-check`, `lint-md`, and `actionlint` before you commit.

## Writing style

- Never hard wrap prose. Write each paragraph or list item on a single line and let the editor wrap it.
- Use US spelling only, for example "color", "behavior", and "initialize".
- Keep every sentence at or under 40 words.
- Pretty print Markdown tables so the columns line up in the source.
- Give every separator line alignment markers (`:---`, `:---:`, or `---:`).
- Carry the separator line from edge to edge of each column, with no spaces between the pipes and the dashes.

Example:

| Option   | Default  | Description               |
|:---------|:---------|:--------------------------|
| `strict` | `true`   | Enables all strict checks |
| `target` | `es2025` | Emitted language version  |

After creating or updating a file that contains prose, including Markdown files, do reading passes over it until every rule above is satisfied. Fix any violation you find, then read the file again.

## Pull requests

Turn on auto-merge for every pull request you open, so it merges as soon as it is approved and the checks pass.

1. Open the pull request with `gh pr create`.
2. Run `gh pr merge <number> --auto --merge` on it. A merge commit is the only merge method the repository allows.

- A draft cannot have auto-merge. Mark it ready with `gh pr ready <number>` first, then run the command above.
- When the user asks to keep a pull request open, leave auto-merge off. If it is already on, turn it off with `gh pr merge <number> --disable-auto`.
- Release pull requests (`chore: release X.Y.Z`) come from the Prepare release workflow, which turns on auto-merge itself. The `tag` job of the Push main workflow tags their merge commit, which starts the release. Only the first release, 1.0.0, is prepared and tagged by hand, as `CONTRIBUTING.md` describes.
