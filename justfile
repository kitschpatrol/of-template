# https://just.systems

set windows-shell := ["C:/msys64/msys2_shell.cmd", "-defterm", "-mingw64", "-no-start", "-here", "-shell", "bash", "-c"]

# Fetch and install project dependencies from codemeta.json
@init:
    jq -r '.softwareRequirements[] | "\(.name) \(.codeRepository) \(.version)"' codemeta.json | tr -d '\r' | while read name url ref; do \
      target=$([[ "$name" == "openFrameworks" ]] && echo "openFrameworks" || echo "openFrameworks/addons/$name"); \
      [ -d "$target" ] || (git init "$target" && git -C "$target" remote add origin "$url" && git -C "$target" fetch --depth 1 origin "$ref" && git -C "$target" checkout FETCH_HEAD); \
    done
    [ -f openFrameworks/libs/.libs_installed ] || ( \
      case "$(uname -s)" in MING*|MSYS*) openFrameworks/scripts/of.sh update libs msys2 ;; esac; \
      openFrameworks/scripts/of.sh update libs && \
      touch openFrameworks/libs/.libs_installed)
    # Copy config
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
@ide: init
    [ -f openFrameworks/projectGenerator/projectGenerator ] || openFrameworks/scripts/of.sh update pg
    just _ide-{{ os() }}

@_ide-macos:
    openFrameworks/projectGenerator/projectGenerator .
    # Replace absolute paths with relative paths
    find . -type f \( -name "*.make" -o -name "Makefile" -o -name "*.xcconfig" -o -name "*.pbxproj" \) -exec sed -i '' "s|$(pwd)/|./|g" {} +

@_ide-windows:
    openFrameworks/projectGenerator/projectGeneratorCmd -p"vs" .

# Format source files using openFrameworks style
format:
    find src -name '*.cpp' -o -name '*.h' | xargs clang-format -i

# Bump and tag version (interactive)
release:
    npx bumpp codemeta.json --ignore-scripts true --push false
