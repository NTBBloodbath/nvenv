<div align="center">

# Nvenv

![License](https://img.shields.io/github/license/NTBBloodbath/nvenv?color=3DA639&logo=open-source-initiative&logoColor=3DA639&style=for-the-badge)
![Latest Release](https://img.shields.io/github/v/release/NTBBloodbath/nvenv?include_prereleases&color=9FEF00&logo=hack-the-box&style=for-the-badge)
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/NTBBloodbath/nvenv/build/main?logo=github&style=for-the-badge)

[Features](#features) • [Install](#install) • [Usage](#usage) • [Building](#building) • [Contribute](#contribute)

</div>

---

Nvenv is a lightweight and blazing fast Neovim
version manager, made using [Vlang](https://github.com/vlang/v).

# Features

- Extremely lightweight (~300kB)
- Blazing fast execution time (<1s execution time)
- No heavy dependencies

# Install

> **Supported OS:**
>
> 1. Linux
>
> 2. MacOS (Untested, if you found issues please report them!)

## Dependencies

- jq
- tar
- curl

# Usage
Just run <kbd>nvenv help</kbd> and see the available commands
or <kbd>nvenv help [command]</kbd> for help with a specific command.

```
❯ nvenv help
Usage: nvenv [commands]

A lightweight and blazing fast Neovim version manager

Commands:
  setup               Set up required files and directories, required at first usage.
  ls                  List your installed versions.
  list-remote         List the available versions.
  install             Install a version.
  uninstall           Uninstall a version.
  update-nightly      Update Neovim Nightly version.
  use                 Use a specific version.
  clean               Clean Nvenv cache files.
  help                Prints help information.
  version             Prints version information.
```

## Example

```sh
# First we need to setup nvenv to create its directories.
nvenv setup

# Then we install Neovim Nightly and latest stable (0.4.4).
# The first version downloaded will be used by default.
nvenv install nightly
nvenv install stable

# To switch to Neovim stable
nvenv use stable
```

> **NOTE:** You need to add `$HOME/.local/bin` to your `$PATH`!
>
> `export PATH=$HOME/.local/bin:$PATH`. In this way, the shell will prefer to use
> the version that is being used in Nvenv instead of the version installed on the system.

---

# Building

## Dependencies

- [v](https://github.com/vlang/v#installing-v-from-source)

First, you need to download the Nvenv repository
(I assume that you have already installed V).

```sh
git clone https://github.com/NTBBloodbath/nvenv
```

If you use `GNU Make` then you can just run it for build

```sh
# Available platforms: linux, macos
make your_platform
```

Otherwise, you can compile it manually

```sh
v -prod nvenv.v
```

---

# Contribute

1. Fork it (https://github.com/NTBBloodbath/nvenv/fork)
2. Create your feature branch (<kbd>git checkout -b my-new-feature</kbd>)
3. Commit your changes (<kbd>git commit -am 'Add some feature'</kbd>)
4. Push to the branch (<kbd>git push origin my-new-feature</kbd>)
5. Create a new Pull Request

> **NOTE:** Before commit your changes, format the code by running `make fmt`.

# License

nvenv is [MIT Licensed](./LICENSE).
