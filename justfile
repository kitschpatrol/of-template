# https://just.systems

# Fetch and install project dependencies from codemeta.json
init:
    #!/bin/bash
    jq -r '.softwareRequirements[] | "\(.name) \(.codeRepository) \(.version)"' codemeta.json | while read name url ref; do
      if [ "$name" = "openFrameworks" ]; then
        target="openFrameworks"
      else
        target="openFrameworks/addons/$name"
      fi

      if [ ! -d "$target" ]; then
        git init "$target"
        git -C "$target" remote add origin "$url"
        git -C "$target" fetch --depth 1 origin "$ref"
        git -C "$target" checkout FETCH_HEAD
      fi
    done

    if [ ! -f "openFrameworks/libs/.libs_installed" ]; then
      openFrameworks/scripts/of.sh update libs
      touch openFrameworks/libs/.libs_installed
    fi

    # Copy formatting configs to project root
    { echo "# Copied from ./openFrameworks"; cat openFrameworks/.clang-format; } > .clang-format
    { echo "# Copied from ./openFrameworks"; cat openFrameworks/.editorconfig; } > .editorconfig

# Build the project (release)
build: init
    make

# Build the project (debug)
build-debug: init
    make Debug

# Run the project (release)
run: build
    make RunRelease

# Run the project (debug)
run-debug: build-debug
    make RunDebug

# Clean build artifacts (release)
clean:
    make clean

# Clean build artifacts (debug)
clean-debug:
    make CleanDebug

# Clean everything including dependencies
clean-all:
    git clean -ffdX

# Generate optional IDE project files for the current platform
ide: init
    #!/bin/bash
    [ -f openFrameworks/projectGenerator/projectGenerator ] || openFrameworks/scripts/of.sh update pg
    openFrameworks/projectGenerator/projectGenerator .

    # Replace absolute paths with relative paths
    REPO_ROOT="$(pwd)"
    find . -type f \( -name "*.make" -o -name "Makefile" -o -name "*.xcconfig" -o -name "*.pbxproj" \) -exec sed -i '' "s|$REPO_ROOT/|./|g" {} +

# Format source files using openFrameworks style
format:
    find src -name '*.cpp' -o -name '*.h' | xargs clang-format -i

# Bump and tag version (interactive)
release:
    npx bumpp codemeta.json --ignore-scripts true --push false
