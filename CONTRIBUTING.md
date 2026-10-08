# Contributing

Thank you for your interest in contributing to `dnd-mapp/action-tag-release`.

This action creates the release tags of the D&D Mapp packages with write access to their repositories. A tag starts a release, so a mistake here can release the wrong commit. Please keep changes small and deliberate.

## Before you start

Open an [issue](https://github.com/dnd-mapp/action-tag-release/issues) to discuss any change beyond a typo fix before you send a pull request. This avoids work on changes that do not fit the goals of the action.

## Development setup

The required Node and pnpm versions are set in `devEngines` in `package.json`. They are enforced through `engineStrict`, so installing with other versions fails.

Install the dependencies with:

```bash
pnpm install
```

Dependency versions live in the catalogs in `pnpm-workspace.yaml`, which uses `catalogMode: strict`. Add or bump versions there and reference them in `package.json`. Use `catalog:` for the default catalog and a named catalog such as `catalog:prettier` for a group of tools.

Newly published releases are held back for three days through `minimumReleaseAge`. You may need to wait before you can bump to a very recent version.

Install [actionlint](https://github.com/rhysd/actionlint) to lint the workflows locally, for example with `brew install actionlint`. CI runs the version that `.github/actions/ci/action.yaml` pins.

## Git hooks

[Lefthook](https://lefthook.dev/) installs the Git hooks when you run `pnpm install`. The hooks are defined in `lefthook.yaml`. `pnpm-workspace.yaml` turns off the side-effects cache of pnpm, because a cached build of lefthook skips the script that installs the hooks. If the hooks are still missing, install them with `pnpm exec lefthook install`.

| Hook         | Runs                                  | On                        |
|:-------------|:--------------------------------------|:--------------------------|
| `pre-commit` | Prettier and markdownlint-cli2 checks | The staged files          |
| `commit-msg` | commitlint                            | The message of the commit |

The pre-commit hooks only check files. Run `pnpm run format` to fix formatting issues and stage the result.

## Project layout

The action lives in `action.yaml` at the repository root, so consumers reference it as `dnd-mapp/action-tag-release`.

| Path                                     | Purpose                                                                                                  |
|:-----------------------------------------|:---------------------------------------------------------------------------------------------------------|
| `action.yaml`                            | Tags the merge commit of a release pull request                                                          |
| `scripts/annotate.sh`                    | Turns failures into error annotations, for the steps of the action to source                             |
| `renovate.json`                          | The Renovate config of this repository, which extends the shared preset `dnd-mapp/config-renovate`       |
| `.github/actions/ci/action.yaml`         | The checks that the pull request, push, and release workflows run                                        |
| `.github/workflows/push-main.yaml`       | Runs the CI checks on `main`, and tags the releases of this repository with the action from the checkout |
| `.github/workflows/prepare-release.yaml` | Opens the release pull requests of this repository, using `dnd-mapp/action-prepare-release`              |
| `.github/workflows/release.yaml`         | Releases this repository from its tags, using `dnd-mapp/action-verify-release`                           |
| `.github/actionlint.yaml`                | Declares the `ubuntu-26.04` runner label, which actionlint does not know yet                             |

## Changing the action

Keep the action to its one purpose: creating the release tag. Preparing the release, staging the package, and creating the GitHub Release stay out of this action.

Tag only the merge commit of a release pull request that the app opened. Every other push ends with a notice, and a release pull request from anyone else fails the run. Run every check before the action writes anything to the repository.

Create the tag through the REST API with the app token. A tag pushed with `GITHUB_TOKEN` does not start the release workflow.

Report every failure as an error annotation, so the run summary shows why the action failed. Each step sources `scripts/annotate.sh`. Run commands that can fail with `run_annotated`, which turns their error output into one annotation, and report your own checks with `annotate_error`. Report a push that the action skips with `annotate_notice`.

Pass inputs and outputs into `run` steps through `env`, and read them as shell variables. Never interpolate `${{ }}` expressions into a script, because a value with quotes or spaces would break or change the command.

actionlint does not read `action.yaml` itself. It checks the file through the `tag` job of the push workflow of this repository, which runs the action from the checkout. Keep that usage in place when you change an input, so a rename is caught before a release.

When you add or change an input, output, or check, update these files in the same pull request.

- The `action.yaml` file, including the `description` of the input or output.
- The tables, the "What it does" list, and the workflow example in the README.

## Checking the repository

Check and format the repository with these commands. CI runs `format-check`, `lint-md`, and actionlint. Run them yourself before you open a pull request.

```bash
pnpm run format-check
pnpm run format
pnpm run lint-md
actionlint
```

## Changelog and versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Record every notable change for consumers under `[Unreleased]` in `CHANGELOG.md`, using the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

Prepare release workflows depend on the names of the inputs and outputs and on the defaults. Renaming or removing one, changing a default, and adding a required input are breaking changes for consumers. Say so in the changelog entry.

## Releasing

1. Run the [prepare release workflow](.github/workflows/prepare-release.yaml) on `main` with the part of the version to bump, for example `gh workflow run prepare-release.yaml -f bump=minor`. It opens the `chore: release X.Y.Z` pull request with auto-merge on.
2. Review and approve the pull request. Once it merges, the `tag` job of the [push workflow](.github/workflows/push-main.yaml) creates the annotated tag `vX.Y.Z` on the merge commit.
3. The [release workflow](.github/workflows/release.yaml) runs the CI checks, verifies the tag and the changelog, and creates the GitHub Release, which opens a discussion in the Announcements category.
4. Update the SHA pins in the package repositories to the tagged commit.

The first release, 1.0.0, has no release to bump from. Prepare its `chore: release 1.0.0` commit by hand instead of step 1: set `version` in `package.json`, rename `[Unreleased]` to `[1.0.0] - YYYY-MM-DD`, add a fresh `[Unreleased]`, and update the link references. Open it from the `chore/first-release` branch, because only the app may create `chore/release-*` branches. The `tag` job skips that merge, so create the annotated tag `v1.0.0` on the merge commit and push it by hand.

## Code style

Follow the rules in `.editorconfig`.

- Use UTF-8 and LF line endings.
- Indent with 4 spaces, or 2 spaces in `package.json` and `pnpm-*.yaml`.
- End every file with a newline and trim trailing whitespace.

Follow these rules for prose, including Markdown files.

- Never hard wrap prose. Write each paragraph or list item on a single line.
- Use US spelling, for example "color" and "behavior".
- Keep every sentence at or under 40 words.
- Pretty print Markdown tables so the columns line up, with alignment markers on every separator line.

## Branches

Create a branch from `main` for each change. Name it `<type>/<short-description>` in lowercase with hyphens between words, for example `feat/message-input` or `fix/version-check`.

Use the same types as for commits.

## Commits

Write commit messages that follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

```text
<type>(<optional scope>): <description>
```

Use one of these types.

| Type       | Use for                                              |
|:-----------|:-----------------------------------------------------|
| `feat`     | A new input, output, or check                        |
| `fix`      | A correction to existing behavior                    |
| `docs`     | Changes to documentation only                        |
| `refactor` | Changes that do not alter the behavior of the action |
| `ci`       | Changes to the workflows of this repository          |
| `build`    | Changes to dependencies or tooling                   |
| `chore`    | Other maintenance that does not fit above            |

Write the description in the imperative mood, such as "add the message input". Mark a breaking change with `!` after the type or scope, and add a `BREAKING CHANGE:` footer that explains what consumers must do.

## Pull requests

- Keep each pull request to one change.
- Link the issue it addresses.
- Update the changelog and README in the same pull request.
- Use a title that follows the commit convention.
- If you have write access, turn on auto-merge once the pull request is open, with `gh pr merge <number> --auto --merge` or the "Enable auto-merge" button. It then merges as soon as it is approved and the checks pass.
- If auto-merge is off, the author merges the pull request once it is approved and the checks pass. A maintainer merges pull requests opened by a contributor without write access.
- Renovate merges its own minor and patch pull requests once the checks pass. A maintainer approves a major update from Renovate and turns on auto-merge for it.
- Update the branch when it falls behind `main`, because auto-merge waits until the branch is up to date. The update dismisses the approval, so the pull request needs a new review.

## License

By contributing, you agree that your contributions are licensed under the [MIT license](LICENSE).
