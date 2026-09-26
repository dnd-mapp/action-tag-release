# dnd-mapp/action-tag-release

[![push main](https://github.com/dnd-mapp/action-tag-release/actions/workflows/push-main.yaml/badge.svg?branch=main)](https://github.com/dnd-mapp/action-tag-release/actions/workflows/push-main.yaml)
[![license](https://img.shields.io/github/license/dnd-mapp/action-tag-release)](LICENSE)

Composite GitHub Action that creates the annotated `vX.Y.Z` tag on the merge commit of a release pull request, so the tag push starts the release workflow.

The D&D Mapp packages are released from a tag push, after their release pull request merges. [`dnd-mapp/action-prepare-release`](https://github.com/dnd-mapp/action-prepare-release) opens that pull request with the GitHub App of the organization. This action runs on every push to the base branch. When the push is the merge of such a pull request, it tags the merge commit with the same app. See [The tag release workflow](#the-tag-release-workflow).

## Requirements

- A workflow that runs on `push` to the base branch.
- A GitHub App that is installed on the repository with read access to pull requests and write access to contents. It must be the app that opens the release pull requests. Its client ID and private key are inputs of the action.
- The app in the bypass list of every ruleset that restricts the creation of `vX.Y.Z` tags.
- Merge commits for release pull requests, because the action tags the commit that the merge pushes to the base branch.
- A Linux runner, because the action uses `jq` and the `gh` CLI of the runner image.

The action reads the repository through the API, so it needs no checkout.

## Usage

Pin the action to a commit SHA and note the version in a comment, like the third-party actions in the D&D Mapp workflows. Take the SHA from the commit that the release tag points to.

```yaml
- name: Tag the release
  uses: dnd-mapp/action-tag-release@<commit-sha> # v1.0.0
  with:
      client-id: ${{ vars.GH_APP_CLIENT_ID }}
      private-key: ${{ secrets.GH_APP_PRIVATE_KEY }}
```

## What it does

1. Checks that the workflow runs on a push to `<base-branch>`.
2. Creates a token for the GitHub App, narrowed to writing contents and reading pull requests.
3. Looks up the pull request that the pushed commit merged. The push is not a release when there is no such pull request, or when its head branch is not a `chore/release-X.Y.Z` branch of the repository. The action then ends with a notice and creates nothing.
4. Fails when the release pull request was not opened by the app.
5. Reads the version from the manifest at the pushed commit. Fails when it is not a stable version such as `1.2.3`, or when it does not match the version in the name of the release branch.
6. Checks whether the `vX.Y.Z` tag exists. When it already points at the pushed commit, for example on a rerun, the action ends with a notice. When it points at another commit, the action fails.
7. Creates the annotated `vX.Y.Z` tag on the pushed commit, with the version as its message and the app as its tagger. The tag push starts the release workflow of the repository.

When a step fails, the action reports why as an error annotation, so the reason shows in the summary of the run without opening the log.

## Inputs

| Input         | Default        | Description                                                                                |
|:--------------|:---------------|:-------------------------------------------------------------------------------------------|
| `client-id`   | (required)     | Client ID of the GitHub App that opened the release pull request, and that creates the tag |
| `private-key` | (required)     | Private key of the GitHub App                                                              |
| `manifest`    | `package.json` | Path to the package manifest, relative to the repository root                              |
| `base-branch` | `main`         | Branch that release pull requests merge into, and whose pushes the action checks           |

## Outputs

| Output    | Description                                                                                  |
|:----------|:---------------------------------------------------------------------------------------------|
| `version` | The version of the release, without the leading `v`, or empty when the push is not a release |
| `tag`     | The release tag, or empty when the push is not a release                                     |
| `created` | Whether the action created the tag, `true` or `false`                                        |

## The tag release workflow

Every package repository has this `tag-release.yaml`.

```yaml
name: Tag release

on:
    push:
        branches:
            - main

permissions: {}

jobs:
    tag:
        name: Tag release
        runs-on: ubuntu-26.04
        timeout-minutes: 5
        permissions: {}
        concurrency:
            group: ${{ github.workflow }}
            cancel-in-progress: false
        steps:
            - name: Tag the release
              uses: dnd-mapp/action-tag-release@<commit-sha> # v1.0.0
              with:
                  client-id: ${{ vars.GH_APP_CLIENT_ID }}
                  private-key: ${{ secrets.GH_APP_PRIVATE_KEY }}
```

### Why it looks like this

- A GitHub App token and not `GITHUB_TOKEN`, because a tag pushed with `GITHUB_TOKEN` does not start the release workflow.
- The same app that opens the release pull requests, so the action can tell a release pull request from any other by its author. Rulesets allow only the app to create and update `chore/release-*` branches.
- The tag goes on the merge commit that the push brings to the base branch. The release workflow checks that the tagged commit is on that branch.
- No permissions for `GITHUB_TOKEN`, because the app token does all the reading and writing, and it exists only inside the action.
- A composite action cannot read secrets, so the workflow passes the app credentials as inputs.
- One run at a time through `concurrency`, so two pushes cannot race for the same tag.

### One-time setup

The D&D Mapp organization shares the credentials of its GitHub App with the repositories that use this action.

1. Install the app on the repository.
2. Share the `GH_APP_CLIENT_ID` organization variable with the repository.
3. Share the `GH_APP_PRIVATE_KEY` organization secret with the repository.
4. Add the app to the bypass list of the ruleset that restricts the creation of `vX.Y.Z` tags.

## Versioning

This repository is released with `vX.Y.Z` tags and GitHub Releases, like the packages. It tags its own releases with its [tag release workflow](.github/workflows/tag-release.yaml), which runs the action from the checkout. Consumers pin a commit SHA, so a new release never changes a workflow until the pin is updated. Renaming or removing an input or output, or changing a default, is a breaking change.

## Changelog

Notable changes for consumers of this action are listed in the [changelog](CHANGELOG.md).

## Contributing

Contributions are welcome. See the [contributing guide](CONTRIBUTING.md) for details.

## License

[MIT](LICENSE) © D&D Mapp
