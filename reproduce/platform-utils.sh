#!/bin/bash
# platform-utils.sh — Single source of truth for platform/architecture detection
# and venv path resolution.
#
# Sourced by: reproduce_environment.sh, reproduce/docker/setup.sh,
#             .devcontainer/post-create.sh
#
# Guard against double-sourcing
[[ -n "${_PLATFORM_UTILS_LOADED:-}" ]] && return 0
_PLATFORM_UTILS_LOADED=1

# ─────────────────────────────────────────────────────────────────────────────
# is_apple_silicon — returns 0 (true) when running on Apple Silicon hardware.
# Uses sysctl to query the kernel directly, which is immune to Rosetta:
# even when a shell process reports uname -m = x86_64 under Rosetta,
# sysctl hw.optional.arm64 still returns 1 on Apple Silicon.
# ─────────────────────────────────────────────────────────────────────────────
is_apple_silicon() {
    [[ "$(uname -s)" == "Darwin" ]] &&
        sysctl -n hw.optional.arm64 2>/dev/null | grep -q 1
}

# ─────────────────────────────────────────────────────────────────────────────
# get_platform_arch — echo the normalized (platform, arch) pair as
# two space-separated tokens, e.g. "darwin arm64" or "linux x86_64".
# Returns empty string for unknown platforms.
# ─────────────────────────────────────────────────────────────────────────────
get_platform_arch() {
    local platform=""
    local arch=""

    case "$(uname -s)" in
        Darwin) platform="darwin" ;;
        Linux)  platform="linux"  ;;
    esac

    if [[ "$(uname -s)" == "Darwin" ]]; then
        if is_apple_silicon; then
            arch="arm64"
        else
            arch="x86_64"
        fi
    else
        arch="$(uname -m)"
    fi

    # Normalize
    case "$arch" in
        arm64)   arch="arm64"   ;;
        aarch64) arch="aarch64" ;;
        x86_64)  arch="x86_64"  ;;
    esac

    echo "$platform $arch"
}

# ─────────────────────────────────────────────────────────────────────────────
# get_platform_venv_path — echo the absolute path to the architecture-specific
# venv directory for the current machine.
#
# Requires PROJECT_ROOT to be set by the caller.  Falls back to
# $PWD if PROJECT_ROOT is unset.
#
# Examples:  /path/to/repo/.venv-darwin-arm64
#            /path/to/repo/.venv-linux-x86_64
#            /path/to/repo/.venv           (unknown platform fallback)
# ─────────────────────────────────────────────────────────────────────────────
get_platform_venv_path() {
    local root="${PROJECT_ROOT:-$(pwd)}"
    local pa
    pa=$(get_platform_arch)
    local platform="${pa%% *}"
    local arch="${pa##* }"

    if [[ -n "$platform" ]] && [[ -n "$arch" ]]; then
        echo "$root/.venv-$platform-$arch"
    elif [[ -n "$platform" ]]; then
        echo "$root/.venv-$platform"
    else
        echo "$root/.venv"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# is_windows_filesystem — returns 0 (true) when the given path resides on a
# Windows filesystem mount (e.g. /mnt/c/ in WSL2), where symlinks are
# unreliable.
# ─────────────────────────────────────────────────────────────────────────────
is_windows_filesystem() {
    local path="$1"
    local mount_point
    mount_point=$(df -P "$path" 2>/dev/null | awk 'NR==2 {print $6}' || echo "")
    if [[ "$mount_point" =~ ^/mnt/[a-z]+ ]]; then
        return 0
    fi
    if [[ "$path" =~ ^/mnt/[a-z]+ ]]; then
        return 0
    fi
    return 1
}

# ─────────────────────────────────────────────────────────────────────────────
# ensure_venv_symlink — create/update the .venv convenience symlink pointing
# at the architecture-specific venv directory.  Skips on Windows filesystems
# where symlinks are unreliable.
#
# Usage: ensure_venv_symlink "/absolute/path/to/project" ".venv-darwin-arm64"
# ─────────────────────────────────────────────────────────────────────────────
ensure_venv_symlink() {
    local root="$1"
    local venv_name="$2"

    if is_windows_filesystem "$root"; then
        return 0
    fi

    if [[ -L "$root/.venv" ]]; then
        local current_target
        current_target=$(readlink "$root/.venv")
        if [[ "$current_target" != "$venv_name" ]]; then
            rm -f "$root/.venv"
            ln -s "$venv_name" "$root/.venv"
        fi
    elif [[ -d "$root/.venv" ]]; then
        rm -rf "$root/.venv"
        ln -s "$venv_name" "$root/.venv"
    elif [[ ! -e "$root/.venv" ]]; then
        ln -s "$venv_name" "$root/.venv"
    fi
}
