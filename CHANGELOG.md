# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2021-07-03
### Changed
- Now `0.5.0` is the stable target and nvenv matches with actual neovim releases.

## [1.3.0] - 2021-04-14
### Removed
- `update` command, use `update-nightly` instead

## [1.2.0] - 2021-04-13
### Added
- `update-nightly` command

### Changed
- Now internal CLI metadata (name, version, description) are extracted from
  the `v.mod` file
- Tweaks to commands descriptions to avoid redundancy
- Changed some error messages to warn messages
- Stop using whitespaces on log messages with more than one line, got replaced by tabs
- Stop using bright colors for logs messages (logs, warns and errors)
- Makefile now format files on build
- CI tweaks

### Deprecated
- `update` command in favor of `update-nightly` command because
  only nightly version receives updates

### Fixed
- Typo in `v.mod` file
- Internal CLI version now matches the current version

## [1.1.0] - 2021-04-09
### Added
- `warn_msg` function ([utils.v](./utils/utils.v))
- `check_command` function ([utils.v](./utils/utils.v))

### Changed
- `setup` command now check missing dependencies

### Fixed
- Fix release date of first release (1.0.0)
- Update outdated unreleased diff link

## [1.0.0] - 2021-04-09
### Added
- `setup` command
- `ls` command
- `list-remote` command
- `install` command
- `uninstall` command
- `update` command
- `use` command
- `clean` command

[Unreleased]: https://github.com/NTBBloodbath/nvenv/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/NTBBloodbath/nvenv/releases/tag/v1.3.0
[1.2.0]: https://github.com/NTBBloodbath/nvenv/releases/tag/v1.2.0
[1.1.0]: https://github.com/NTBBloodbath/nvenv/releases/tag/v1.1.0
[1.0.0]: https://github.com/NTBBloodbath/nvenv/releases/tag/v1.0.0
