# Contributing to dnd-mapp/action-tag-release

This page adds the details of `dnd-mapp/action-tag-release` to the [shared contributing guide](https://github.com/dnd-mapp/.github/blob/main/CONTRIBUTING.md). Read that guide first.

This action creates the release tags of the D&D Mapp packages with write access to their repositories. A tag starts a release, so a mistake here can release the wrong commit. Keep changes small and deliberate.

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

## Checks

This repository runs only the [shared checks](https://github.com/dnd-mapp/.github/blob/main/CONTRIBUTING.md#checks): `format-check`, `lint-md`, and actionlint.

## Changelog and versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Record every notable change for consumers under `[Unreleased]` in `CHANGELOG.md`, using the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

Prepare release workflows depend on the names of the inputs and outputs and on the defaults. Renaming or removing one, changing a default, and adding a required input are breaking changes for consumers. Say so in the changelog entry.

## Releasing

1. Run the [prepare release workflow](../../.github/workflows/prepare-release.yaml) on `main` with the part of the version to bump, for example `gh workflow run prepare-release.yaml -f bump=minor`. It opens the `chore: release X.Y.Z` pull request with auto-merge on.
2. Review and approve the pull request. Once it merges, the `tag` job of the [push workflow](../../.github/workflows/push-main.yaml) creates the annotated tag `vX.Y.Z` on the merge commit.
3. The [release workflow](../../.github/workflows/release.yaml) runs the CI checks, verifies the tag and the changelog, and creates the GitHub Release, which opens a discussion in the Announcements category.
4. Update the SHA pins in the package repositories to the tagged commit.
