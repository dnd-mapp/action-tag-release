# Agent instructions

## Project

This repository is the composite GitHub Action `dnd-mapp/action-tag-release`. The action in `action.yaml` runs on a push to the base branch. When the push is the merge of a release pull request that the GitHub App opened, it creates the annotated `vX.Y.Z` tag on the merge commit with the app token. Read the [shared contributing guide](https://github.com/dnd-mapp/.github/blob/main/CONTRIBUTING.md) for the conventions that every D&D Mapp repository follows, and [docs/contributing/README.md](docs/contributing/README.md) for the layout, the checks, and the release steps of this repository.

- Keep the action to creating the release tag. Preparing the release, staging the package, and creating the GitHub Release belong elsewhere.
- Tag only the merge commit of a release pull request that the app opened. Treat every other push as a push to skip, never as a push to tag.
- Create the tag through the REST API with the app token, never with `GITHUB_TOKEN`, because a tag pushed with `GITHUB_TOKEN` does not start the release workflow.
- Run `format-check`, `lint-md`, and `actionlint` before you commit.
