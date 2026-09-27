# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-09-27

### Added

- The action. On a push to the base branch, it looks up the pull request that the push merged. When that is a `chore/release-X.Y.Z` pull request opened by the GitHub App, it checks the version in the manifest and creates the annotated `vX.Y.Z` tag on the merge commit with the app token. It outputs `version`, `tag`, and `created`.

[Unreleased]: https://github.com/dnd-mapp/action-tag-release/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/dnd-mapp/action-tag-release/releases/tag/v1.0.0
