# of-template

A template repository for self-contained openFrameworks application projects.

Configured with a VS Code / Make toolchain in mind, but includes some affordances for escalating to a heavier IDE when necessary.

## Getting started

### Dependencies

Beyond the openFrameworks basics like `git` and a compiler, you will need:

- [`just`](https://just.systems) - task runner
- [`jq`](https://jqlang.org) - JSON processor
- [`node`](https://nodejs.org) - Version bumping _(optional)_

#### macOS

To install these with [Homebrew](https://brew.sh/) on macOS:

```sh
brew install just jq
```

#### Windows

Building openFrameworks with Make requires [MSYS2](https://www.msys2.org/). (Use the installer.)

From inside an MSYS2 MINGW64 prompt:

```sh
pacman -Syu --noconfirm --needed
pacman -S git clang mingw-w64-x86_64-nodejs mingw-w64-x86_64-toolchain just mingw-w64-x86_64-jq --noconfirm --needed
```

For ease of calling `just` outside a MSYS2 prompt, you can install the following at the system level with [Scoop](https://scoop.sh/):

```sh
scoop install just clang-format
```

(Note that `jid` is a dependency of `jq` and `fzf` is a dependency of `just`.)

#### Git Actions

This repo includes GitHub actions to keep project metadata in sync and to publish source releases. These require a GitHub personal access token credential to be set on the repository.

This can be done through the GitHub admin panels, or with the [GitHub CLI](https://cli.github.com/):

```sh
 gh secret set PERSONAL_ACCESS_TOKEN --app actions --body $GITHUB_PERSONAL_ACCESS_TOKEN
```

(Or just delete the `.github` folder if you don't want to bother.)

### Bootstrapping

To download openFrameworks, the openFramework library dependencies, and any third-party addons as defined in the `codemeta.json` file into the project, run:

```sh
just init
```

### Building and Running

To launch a debug build of the application:

```sh
just run-debug
```

## Tasks

All commands may be invoked via the `just` task runner. These effectively overlay the existing Make file commands, and add a few additional commands to manage the project repository:

<!-- just -l --unsorted -->

```sh
just init        # Fetch and install project dependencies from codemeta.json
just build       # Build the project (release)
just build-debug # Build the project (debug)
just run         # Run the project (release)
just run-debug   # Run the project (debug)
just clean       # Clean build artifacts (release)
just clean-debug # Clean build artifacts (debug)
just clean-all   # Clean everything including dependencies
just ide         # Generate optional IDE project files for the current platform
just format      # Format source files using openFrameworks style
just release     # Bump and tag version (interactive)
```

## Repository structure

```
.
├── src/              # Application source code
├── bin/              # Build output
├── bin/data/         # Runtime assets
├── openFrameworks/   # openFrameworks SDK (fetched by `just init`)
│   └── addons/       # Third-party addons
├── codemeta.json     # Project metadata and dependencies
├── addons.make       # Addons to include in the build
├── config.make       # Build configuration
├── Makefile          # Main build file
└── justfile          # Task runner commands
```

## Defining project metadata

The project's name, version number, description, keywords, and dependencies are all defined in `codemeta.json`, which is based on the [CodeMeta](https://codemeta.github.io/) metadata vocabulary.

## Managing addons

### First-party

If the addon is bundled with openFrameworks, then add the addon name to `addons.make`, then run:

```sh
just clean-all init
```

### Third-party

Add the addon's name, repository URL, and tag or commit hash to the `softwareRequirements` array in `codemeta.json`.

For example:

```json
{
	"@type": "SoftwareSourceCode",
	"codeRepository": "https://github.com/danomatika/ofxMidi.git",
	"name": "ofxMidi",
	"version": "735f00ead8d043d3c9a399196c3abf8795bed827"
}
```

Then add the addon name to `addons.make` and run:

```sh
just clean-all init
```

## Managing openFrameworks

The openFrameworks version is also specified in `codemeta.json` under `softwareRequirements`. The openFrameworks entry must be listed first. Update the `version` field to the desired tag or commit hash, then run:

```sh
just clean-all init
```

## Context

It looks like openFraemworks might eventually migrate to [CMake](https://cmake.org/) or a proper package manager like [vcpkg](https://vcpkg.io/en/). That will be great, but for now, this repository uses Make since this is supported by built-in project generator, which represents the path of least resistance pending progress on some of the prospects below:

### Modularization and modernization

- [OF-RFC-001: Global Architecture: a layered approach](https://forum.openframeworks.cc/t/of-rfc-001-global-architecture-a-layered-approach/45087)
- [OF-RFC-002: Standalone Core Discussion](https://forum.openframeworks.cc/t/of-rfc-002-layer-1-of-standalone-core/45089)
- [libopenframeworks Repository](https://github.com/echa/libopenframeworks)
- [ofLibs](https://github.com/ofWorks/ofLibs)
- [Thread: ofLibs as an Apothecary Alternative](https://forum.openframeworks.cc/t/oflibs-apothecary-alternative/45122)
- [ofWorks](https://ofworks.cc/)
- [TrussC](https://trussc.org/)

### CMake

- [Nick Hardeman's CMake fork](https://github.com/NickHardeman/openFrameworks/tree/of-cmake)
- [Thread: CMake forks](https://forum.openframeworks.cc/t/experimental-of-cmake-fork/45083)
- [Thread: All about CMake](https://forum.openframeworks.cc/t/all-about-cmake/41777)
- [ofx-projects repository with CMake](https://github.com/dopuskh3/ofx-projects)
- [Thread: An attempt to make OF a CMake dependency](https://forum.openframeworks.cc/t/an-attempt-to-make-of-a-cmake-dependency/43413): Explores technical methods to allow openFrameworks to be imported as a standard package in external CMake projects.

### vcpkg

- [Cris Mendoza's vcpkg fork](https://github.com/StudioDanielCanogar/openFrameworks/tree/vcpkg)
- [Thread: vcpkg fork](https://forum.openframeworks.cc/t/of-vcpkg-cmake-fork/45272)
- [Studio Daniel Canogar vcpkg Branch](https://github.com/StudioDanielCanogar/openFrameworks/tree/vcpkg)
