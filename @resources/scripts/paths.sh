#!/bin/bash

# === DEBUG ERROR HANDLING (TEMPORARILY DISABLED FOR DEBUGGING) ===
set -e  # Exit on error only (removed -uo pipefail to prevent shell crashes)
# TERMINAL CRASH FIX: 20250905-1715h Capture starting directory for absolute path resolution
# SYMLINK FIX: 20250108 Use pwd -L to preserve symlinked paths
SCRIPT_START_PWD="${SCRIPT_START_PWD:-$(pwd -L)}"

# Trap function to show which command failed
debug_trap_error() {
    local exit_code=$?
    local line_number=$1
    # TERMINAL CRASH FIX: 20250905-1716h Use absolute path to prevent sed "No such file or directory" errors
    local script_path="$0"
    
    # Convert to absolute path if relative
    if [[ ! "$script_path" == /* ]]; then
        # If path starts with ./, remove it and prepend current dir
        if [[ "$script_path" == ./* ]]; then
            script_path="${SCRIPT_START_PWD:-$(pwd -L)}/${script_path#./}"
        elif [[ "$script_path" == */* ]]; then
            # Relative path with directory components
            script_path="${SCRIPT_START_PWD:-$(pwd -L)}/$script_path"
        else
            # Just filename - search in PATH or current dir
            script_path="${SCRIPT_START_PWD:-$(pwd -L)}/$script_path"
        fi
    fi
    
    echo "ERROR: Command failed with exit code $exit_code on line $line_number in $0" >&2
    # Try to show the failing command, but don't fail if we can't read the script
    failed_command=$(sed -n "${line_number}p" "$script_path" 2>/dev/null || sed -n "${line_number}p" "$0" 2>/dev/null || echo "<unable to read script>")
    echo "Failed command was: $failed_command" >&2
    exit $exit_code
}

# Enable error trapping (TEMPORARILY DISABLED FOR DEBUGGING)
# trap 'debug_trap_error $LINENO' ERR
# === END DEBUG ERROR HANDLING ===


# Universal paths.sh - Context-adaptive for project and standalone modes
# Usage: source paths.sh [<version>] [<script_type>]
# Versions: Latest, Public
# Script types: orchestrator, utility, tool, auto
# Example: source paths.sh Latest orchestrator
#
# CONTEXTS:
# - Project mode: [ProjectName]-make with sibling Latest/Public repos  
# - Standalone mode: Individual repos ([ProjectName]-Latest, [ProjectName]-Public)

# =============================================================================
# PROJECT PARENT DETECTION VIA @local/ CONFIG FILES
# Container and project names come from @local/_containername.ltx and @local/_projectname.ltx
# =============================================================================

find_project_container() {
    local search_dir="${1:-$(pwd -L)}"
    local current_dir="$(cd "$search_dir" 2>/dev/null && pwd -L)" || current_dir="$search_dir"
    
    # Search upward for @local/ directory (indicates we're in a repo)
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/.project_container" ]]; then
            # Found @local/ - we're in a repo directory
            local dir_name="$(basename "$current_dir")"
            if [[ "$dir_name" =~ -(make|Latest|Public)$ ]]; then
            # The parent directory is the project container
                local spurious_file="$current_dir/.project_container"
                local delete_command="rm \"$spurious_file\""
                echo "ERROR: .project_container file found in wrong location!" >&2
                echo "" >&2
                echo "PROBLEM: Found .project_container file at:" >&2
                echo "         $spurious_file" >&2
                echo "" >&2
                echo "EXPLANATION: The .project_container file should be in the parent directory" >&2
                echo "             that CONTAINS the *-make, *-Latest, and *-Public directories," >&2
                echo "             not inside one of those directories." >&2
                echo "" >&2
                echo "SOLUTION: Delete the spurious file with this command:" >&2
                echo "          $delete_command" >&2
                echo "" >&2
                echo "The command has been copied to your clipboard." >&2
                if command -v pbcopy >/dev/null 2>&1; then
                    echo "$delete_command" | pbcopy
                elif command -v xclip >/dev/null 2>&1; then
                    echo "$delete_command" | xclip -selection clipboard
                elif command -v xsel >/dev/null 2>&1; then
                    echo "$delete_command" | xsel --clipboard --input
                else
                    echo "NOTE: Could not copy to clipboard (no pbcopy, xclip, or xsel found)" >&2
                fi
                echo "" >&2
                echo "After running that command, try your original command again." >&2
                return 1
            fi
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    echo "ERROR: No .project_container file found in any parent directory" >&2
    return 1
}

# MIGRATION: 20251108 Get CONTAINER NAME from @local/_containername.ltx
# Plain text file containing just the container name (e.g., "HAFiscal-dev")
# This is used ONLY for context/identification, NOT for path construction
get_container_name_from_latex() {
    local repo_dir="$1"
    local containername_file="$repo_dir/@local/_containername.ltx"
    
    if [[ -f "$containername_file" ]]; then
        # Read plain text file, trim whitespace
        local container_name="$(cat "$containername_file" | tr -d '\n\r' | xargs)"
        if [[ -n "$container_name" ]]; then
            echo "$container_name"
            return 0
        fi
    fi
    
    # Fallback: try to find _containername.ltx in sibling repos
    local parent_dir="$(dirname "$repo_dir")"
    for sibling in "$parent_dir"/*-Latest "$parent_dir"/*-Public "$parent_dir"/*-make; do
        if [[ -d "$sibling" && -f "$sibling/@local/_containername.ltx" ]]; then
            local container_name="$(cat "$sibling/@local/_containername.ltx" | tr -d '\n\r' | xargs)"
            if [[ -n "$container_name" ]]; then
                echo "$container_name"
                return 0
            fi
        fi
    done
    
    # Final fallback: derive from directory structure
    for dir in "$parent_dir"/*-make "$parent_dir"/*-Latest "$parent_dir"/*-Public; do
            if [[ -d "$dir" ]]; then
                local dir_name="$(basename "$dir")"
                local derived_name="${dir_name%-make}"
                derived_name="${derived_name%-Latest}"
                derived_name="${derived_name%-Public}"
                derived_name="${derived_name%-QE}"
                if [[ -n "$derived_name" ]]; then
                echo "WARNING: Could not read @local/_containername.ltx, using derived name: $derived_name" >&2
                    echo "$derived_name"
                    return 0
                fi
            fi
        done
    
    echo "ERROR: Could not determine container name" >&2
    return 1
}

# MIGRATION: 20251108 Get PROJECT NAME from @local/_projectname.ltx
# Plain text file containing just the project name (e.g., "HAFiscal")
# This is used for BOTH display/identity AND path construction (directory names)
get_project_name_from_latex() {
    local repo_dir="$1"
    local projectname_file="$repo_dir/@local/_projectname.ltx"
    
    if [[ -f "$projectname_file" ]]; then
        # Read plain text file, trim whitespace
        local project_name="$(cat "$projectname_file" | tr -d '\n\r' | xargs)"
        if [[ -n "$project_name" ]]; then
            echo "$project_name"
            return 0
        fi
    fi
    
    # Fallback: try to find _projectname.ltx in sibling repos
    local parent_dir="$(dirname "$repo_dir")"
    for sibling in "$parent_dir"/*-Latest "$parent_dir"/*-Public; do
        if [[ -d "$sibling" && -f "$sibling/@local/_projectname.ltx" ]]; then
            local project_name="$(cat "$sibling/@local/_projectname.ltx" | tr -d '\n\r' | xargs)"
            if [[ -n "$project_name" ]]; then
                echo "$project_name"
                return 0
            fi
        fi
    done
    
    # Final fallback: use container directory name
    echo "WARNING: Could not read @local/_projectname.ltx, using container name as project name" >&2
    return 1
}

# =============================================================================
# CONTEXT-ADAPTIVE PROJECT DETECTION
# =============================================================================

detect_execution_context() {
    local search_dir="${1:-$(pwd -L)}"
    local current_dir="$(cd "$search_dir" 2>/dev/null && pwd -L)" || current_dir="$search_dir"
    
    # SYMLINK FIX: 20250108 Disabled git root detection because it resolves symlinks to physical paths
    # This breaks dev directory structures that use symlinks to organize sibling repos
    # Instead, rely on pwd -L + .project_container detection to preserve symlinked structure
    # local git_root="$(cd "$current_dir" && git rev-parse --show-toplevel 2>/dev/null)"
    # if [[ -n "$git_root" ]]; then
    #     current_dir="$git_root"
    # fi
    
    # Find project parent directory by searching upward for @local/ directory
    local project_container_dir
    project_container_dir="$(find_project_container "$current_dir")" || return 1
    
    # MIGRATION: 20251108 Get PROJECT NAME from @local/_projectname.ltx
    # This is used for path construction (e.g., "HAFiscal" in "HAFiscal-make")
    local project_name
    project_name="$(get_project_name_from_latex "$current_dir")" || return 1
    
    # MIGRATION: 20251108 Get CONTAINER NAME from @local/_containername.ltx
    # This is used for context/identification only (e.g., "HAFiscal-dev")
    local container_name
    container_name="$(get_container_name_from_latex "$current_dir")"
    if [[ $? -ne 0 || -z "$container_name" ]]; then
        # Fallback: use project name as container name
        container_name="$project_name"
    fi
    
    local dir_name="$(basename "$current_dir")"
    
    # MIGRATION: 20251108 Determine repo type based on PROJECT NAME pattern
    # Expected format: [ProjectName]-{make,Latest,Public,QE}
    local repo_type=""
    if [[ "$dir_name" =~ ^${project_name}-(make|Latest|Public|QE)$ ]]; then
        repo_type="${BASH_REMATCH[1]}"
    else
        echo "ERROR: Directory '$dir_name' doesn't match expected pattern ${project_name}-{make|Latest|Public|QE}" >&2
        echo "       Project name: $project_name (from @local/_projectname.ltx)" >&2
        echo "       Container name: $container_name (from @local/_containername.ltx)" >&2
        echo "       Current directory: $current_dir" >&2
        return 1
    fi
    
    # MIGRATION: 20251108 Check if sibling directories exist using PROJECT_NAME (for directory names)
    if [[ -d "$project_container_dir/${project_name}-make" ]] && \
       [[ -d "$project_container_dir/${project_name}-Latest" ]] && \
       [[ -d "$project_container_dir/${project_name}-Public" ]]; then
        # PROJECT MODE: All three siblings exist
        # Format: mode:container_dir:repo_type:project_name:container_name:current_dir
        echo "project:$project_container_dir:$repo_type:$project_name:$container_name:$current_dir"
        return 0
    else
        # STANDALONE MODE: Only this repo exists
        echo "standalone:$project_container_dir:$repo_type:$project_name:$container_name:$current_dir"
        return 0
    fi
}

# Enhanced script directory detection with fallbacks
get_script_dir() {
    local script_dir=""
    
    if [[ $# -gt 0 && -n "${1:-}" ]]; then
        script_dir="$1"
    elif [[ -n "$BASH_SOURCE" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -L 2>/dev/null)"
    elif [[ -n "$0" && "$0" != *bash* ]]; then
        script_dir="$(cd "$(dirname "$0")" && pwd -L 2>/dev/null)"
    else
        echo "Warning: Cannot determine script directory. Using current directory." >&2
        script_dir="$(pwd -L)"
    fi
    
    if [[ ! -d "$script_dir" ]]; then
        echo "ERROR: Script directory does not exist: $script_dir" >&2
        return 1
    fi
    
    echo "$script_dir"
}

# =============================================================================
# SCRIPT TYPE AUTO-DETECTION
# =============================================================================

detect_script_type_from_comments() {
    local calling_script="${BASH_SOURCE[2]:-}"  # The script that called paths.sh
    
    if [[ -f "$calling_script" ]]; then
        local script_type="$(grep -m1 '^# SCRIPT_TYPE:' "$calling_script" 2>/dev/null | sed 's/# SCRIPT_TYPE: *//' | tr -d '[:space:]')"
        if [[ -n "$script_type" ]]; then
            echo "$script_type"
            return 0
        fi
    fi
    
    # No tag found
    return 1
}

detect_script_type_heuristic() {
    local calling_script="${BASH_SOURCE[2]:-}"
    if [[ -z "$calling_script" ]]; then
        echo "auto"
        return 0
    fi
    
    local script_dir="$(dirname "$calling_script")"
    local script_name="$(basename "$calling_script" .sh)"
    
    # Resolve relative paths for comparison (preserve symlinks)
    script_dir="$(cd "$script_dir" 2>/dev/null && pwd -L)" || script_dir="$script_dir"
    
    # Location-based detection
    if [[ "$script_dir" == *"-make" ]] && [[ ! "$script_dir" == *"/scripts/"* ]]; then
        # Root directory of a *-make project
        case "$script_name" in
            make*|build*|orchestrat*)
                echo "orchestrator"
                return 0
                ;;
        esac
    elif [[ "$script_dir" == *"/scripts/utils" ]] || [[ "$script_dir" == *"/scripts/utils/"* ]]; then
        echo "utility"
        return 0
    elif [[ "$script_dir" == *"/scripts/tools" ]] || [[ "$script_dir" == *"/scripts/tools/"* ]]; then
        echo "tool"
        return 0
    fi
    
    # Content-based heuristics (light check)
    if [[ -f "$calling_script" ]]; then
        if grep -q "makeEverything\|makePDF.*makeWeb" "$calling_script" 2>/dev/null; then
            echo "orchestrator"
            return 0
        fi
    fi
    
    echo "utility"  # Default fallback
}

detect_script_type() {
    # 1. Try comment-based tags first
    if detect_script_type_from_comments >/dev/null 2>&1; then
        detect_script_type_from_comments
        return 0
    fi
    
    # 2. Fall back to heuristic detection
    detect_script_type_heuristic
}

# =============================================================================
# MAIN PATHS LOGIC (Context-adaptive)
# =============================================================================

# Helper function to exit/return appropriately based on execution context
safe_exit() {
    local exit_code="${1:-1}"
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        # Script is being executed directly
        exit "$exit_code"
    else
        # Script is being sourced
        return "$exit_code"
    fi
}

# Parse parameters - NEW ORDER: [<version>] [<script_type>]
vers="${1:-Latest}"
script_type="${2:-auto}"

# Handle --help option
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat << 'EOF'
USAGE: source paths.sh [<version>] [<script_type>]

DESCRIPTION:
    Universal path detection system for HAFiscal project scripts.
    Automatically detects project structure and sets up all necessary
    path variables for cross-platform and cross-context compatibility.

ARGUMENTS:
    version        Target version to work with (optional)
                   Values: Latest, Public, QE
                   Default: Latest
    
    script_type    Script type for optimized path setup (optional)
                   Values: orchestrator, utility, tool, auto
                   Default: auto (auto-detects based on script location/content)

SCRIPT TYPES:
    orchestrator   Main build/workflow scripts (makeEverything.sh, makePDF-*.sh, etc.)
    utility        Helper scripts in scripts/utils/ directory
    tool           Specialized tools in scripts/tools/ directory  
    auto           Auto-detect script type based on location and content

EXPORTED VARIABLES:
    PROJECT_NAME        Project name for directory construction (from @local/_projectname.ltx, e.g., "HAFiscal")
    CONTAINER_NAME      Container context name (from @local/_containername.ltx, e.g., "HAFiscal-dev")
    PROJECT_CONTAINER   Parent directory containing all project repos
    PROJECT_TARGET      Target directory (Latest, Public, or QE version)
    MAKE_ROOT           Build system root (uses PROJECT_NAME, e.g., .../HAFiscal-make)
    LATEST_ROOT         Latest repository (uses PROJECT_NAME, e.g., .../HAFiscal-Latest)
    PUBLIC_ROOT         Public repository (uses PROJECT_NAME, e.g., .../HAFiscal-Public)
    QE_ROOT             QE repository (uses PROJECT_NAME, e.g., .../HAFiscal-QE)
    SCRIPTS_UTILS       Path to scripts/utils directory
    SCRIPTS_TOOLS       Path to scripts/tools directory
    REPO_ROOT           Current repository root

EXAMPLES:
    source paths.sh                           # Latest version, auto-detect script type
    source paths.sh Latest                    # Latest version, auto-detect script type
    source paths.sh Public                    # Public version, auto-detect script type
    source paths.sh Latest orchestrator       # Latest version, explicit orchestrator
    source paths.sh Public utility            # Public version, explicit utility

CONTEXTS:
    Project Mode    All repos present: HAFiscal-{make,Latest,Public,QE}
    Standalone Mode Individual repo only (limited functionality)

REQUIREMENTS:
    - @local/ directory in each repo (for upward search to find repo root)
    - @local/_containername.ltx file (contains container directory name, e.g., "HAFiscal-dev")
    - @local/_projectname.ltx file (contains logical project name, e.g., "HAFiscal")
    - Directory naming: [ContainerName]-{make,Latest,Public,QE}

EOF
    return 0
fi

# Error checking: If two arguments provided, first must be valid version
if [[ $# -eq 2 ]]; then
    case "$vers" in
        Latest|Public|QE)
            # Valid version, check second argument is valid script type
            case "$script_type" in
                orchestrator|utility|tool|auto)
                    # Valid script type, continue
                    ;;
                *)
                    echo "ERROR: Invalid script type: '$script_type'" >&2
                    echo "       Valid script types: orchestrator, utility, tool, auto" >&2
                    echo "USAGE: source paths.sh [<version>] [<script_type>]" >&2
                    echo "       source paths.sh --help  # show detailed help" >&2
                    safe_exit 1
                    ;;
            esac
            ;;
        *)
            echo "ERROR: When providing two arguments, first argument must be a version (Latest, Public, or QE)" >&2
            echo "ERROR: You provided: '$vers' '$script_type'" >&2
            echo "CORRECT: source paths.sh Latest $script_type" >&2
            echo "CORRECT: source paths.sh $vers  # (single argument for version)" >&2
            echo "         source paths.sh --help  # show detailed help" >&2
            safe_exit 1
            ;;
    esac
fi

# Validate version and script type
case "$vers" in
    Latest|Public|QE)
        # Valid version
        ;;
    orchestrator|utility|tool|auto)
        # User provided script type as first argument - this is wrong with new order
        echo "ERROR: With new argument order, version comes first, then script type" >&2
        echo "ERROR: You provided script type '$vers' as first argument" >&2
        echo "CORRECT: source paths.sh Latest $vers" >&2
        echo "CORRECT: source paths.sh Public $vers" >&2
        echo "         source paths.sh --help  # show detailed help" >&2
        safe_exit 1
        ;;
    *)
        echo "ERROR: Invalid version: $vers" >&2
        echo "       Valid versions: Latest, Public, QE" >&2
        echo "USAGE: source paths.sh [<version>] [<script_type>]" >&2
        echo "       source paths.sh --help  # show detailed help" >&2
        safe_exit 1
        ;;
esac

# Validate and resolve script type
case "$script_type" in
    orchestrator|utility|tool)
        # Explicit script type provided
        ;;
    auto)
        # Auto-detect script type
        script_type="$(detect_script_type)"
        ;;
    *)
        echo "ERROR: Invalid script type: $script_type" >&2
        echo "       Valid script types: orchestrator, utility, tool, auto" >&2
        echo "USAGE: source paths.sh [<version>] [<script_type>]" >&2
        echo "       source paths.sh --help  # show detailed help" >&2
        safe_exit 1
        ;;
esac

# SCRIPT_DIR removed - now using MAKE_ROOT throughout codebase

# Detect execution context
context_info="$(detect_execution_context)" || return 1

# MIGRATION: 20251108 Parse context information - now includes both project name and container name
# Format: mode:container_dir:repo_type:project_name:container_name:current_dir
IFS=':' read -r context_type PROJECT_CONTAINER repo_type PROJECT_NAME CONTAINER_NAME REPO_ROOT <<< "$context_info"

# Set up path variables based on context
case "$context_type" in
    project)
        # PROJECT MODE: We're in a [ProjectName]-{make,Latest,Public} directory
        # with sibling directories present
        
        # MIGRATION: 20251108 Use PROJECT_NAME for path construction
        # Core paths (e.g., HAFiscal-make, HAFiscal-Latest)
        MAKE_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-make"
        LATEST_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-Latest"
        PUBLIC_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-Public"
        QE_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-QE"
        
        # Script utilities path
        SCRIPTS_UTILS="$MAKE_ROOT/scripts/utils"
SCRIPTS_TOOLS="$MAKE_ROOT/scripts/tools"
        
        # Determine target directory based on version
        case "$vers" in
            Latest)
                PROJECT_TARGET="$LATEST_ROOT"
                ;;
            Public)
                PROJECT_TARGET="$PUBLIC_ROOT"
                ;;
            QE)
                PROJECT_TARGET="$QE_ROOT"
                ;;
            *)
                echo "ERROR: Invalid version: $vers (must be Latest, Public, or QE)" >&2
                return 1
                ;;
        esac
        
        # Set script-specific variables
        case "$script_type" in
            orchestrator)
                # Orchestrator scripts run from make directory
                SCRIPT_DIR="$MAKE_ROOT"
                ;;
            utility)
                # Utility scripts run from make directory
                SCRIPT_DIR="$MAKE_ROOT"
                ;;
            tool)
                # Tool scripts can run from anywhere
                ;;
            auto)
                # Auto-detect based on current directory
                if [[ "$REPO_ROOT" == "$MAKE_ROOT" ]]; then
                    SCRIPT_DIR="$MAKE_ROOT"
                fi
                ;;
        esac
        
        # Only show path detection details in verbose mode
        if [[ "${VERBOSITY_LEVEL:-normal}" == "verbose" ]] || [[ "${DEBUG:-false}" == "true" ]] || [[ "${VERBOSITY:-}" == "VERBOSE" ]]; then
            echo "=== Universal $PROJECT_NAME Path Detection ==="
            echo "Execution context: $context_type"
            echo "Current repo type: $repo_type"
            echo "Project name: $PROJECT_NAME"
            echo "SCRIPT_DIR=$SCRIPT_DIR"
            echo "REPO_ROOT=$REPO_ROOT"
            echo "PROJECT_CONTAINER=$PROJECT_CONTAINER"
            echo "MAKE_ROOT=$MAKE_ROOT"
            echo "LATEST_ROOT=$LATEST_ROOT"
            echo "PUBLIC_ROOT=$PUBLIC_ROOT"
            echo "PROJECT_TARGET=$PROJECT_TARGET"
            echo "SCRIPTS_UTILS=$SCRIPTS_UTILS"
            echo "SCRIPTS_TOOLS=$SCRIPTS_TOOLS"
        fi
        ;;
        
    standalone)
        # STANDALONE MODE: We're in a single [ProjectName]-{Latest,Public} directory
        # without sibling directories
        
        # MIGRATION: 20251108 Use PROJECT_NAME for path construction
        # Core paths (e.g., HAFiscal-Latest, HAFiscal-Public)
        MAKE_ROOT=""  # No make directory in standalone mode
        LATEST_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-Latest"
        PUBLIC_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-Public"
        QE_ROOT="$PROJECT_CONTAINER/$PROJECT_NAME-QE"
        
        # Script utilities path (if available)
        if [[ -d "$PROJECT_CONTAINER/$PROJECT_NAME-make/scripts/utils" ]]; then
            SCRIPTS_UTILS="$PROJECT_CONTAINER/$PROJECT_NAME-make/scripts/utils"
        else
            SCRIPTS_UTILS=""
        fi
        
        # Determine target directory based on version and current repo
        case "$vers" in
            Latest)
                PROJECT_TARGET="$LATEST_ROOT"
                ;;
            Public)
                PROJECT_TARGET="$PUBLIC_ROOT"
                ;;
            QE)
                PROJECT_TARGET="$QE_ROOT"
                ;;
            *)
                echo "ERROR: Invalid version: $vers (must be Latest, Public, or QE)" >&2
                return 1
                ;;
        esac
        
        # Export for child processes
        export MAKE_ROOT LATEST_ROOT PUBLIC_ROOT PROJECT_TARGET SCRIPTS_UTILS SCRIPTS_TOOLS
        
        # Only show path detection details in verbose mode  
        if [[ "${VERBOSITY_LEVEL:-normal}" == "verbose" ]] || [[ "${DEBUG:-false}" == "true" ]] || [[ "${VERBOSITY:-}" == "VERBOSE" ]]; then
            echo "=== Universal $PROJECT_NAME Path Detection ==="
            echo "Execution context: $context_type"
            echo "Current repo type: $repo_type"
            echo "Project name: $PROJECT_NAME"
            echo "SCRIPT_DIR=$MAKE_ROOT"
            echo "REPO_ROOT=$REPO_ROOT"
            echo "PROJECT_CONTAINER=$PROJECT_CONTAINER"
            echo "LATEST_ROOT=$LATEST_ROOT"
            echo "PUBLIC_ROOT=$PUBLIC_ROOT"
            echo "PROJECT_TARGET=$PROJECT_TARGET"
            echo "SCRIPTS_UTILS=$SCRIPTS_UTILS"
            echo "SCRIPTS_TOOLS=$SCRIPTS_TOOLS"
        fi
        ;;
        
    *)
        echo "ERROR: Unknown context type: $context_type" >&2
        return 1
        ;;
esac

# MIGRATION: 20251108 Export all variables for use by calling scripts
# Added CONTAINER_NAME to support symlinked dev directories
export PROJECT_NAME           # Project name for directory construction (from @local/_projectname.ltx)
export CONTAINER_NAME         # Container name for context/identification (from @local/_containername.ltx)
export PROJECT_CONTAINER
export PROJECT_TARGET
export MAKE_ROOT
export LATEST_ROOT
export PUBLIC_ROOT
export QE_ROOT
export SCRIPTS_UTILS
export SCRIPTS_TOOLS
export REPO_ROOT

# Add scripts/tools and scripts/utils to PATH for command-line access
export PATH="$MAKE_ROOT/scripts/tools:$MAKE_ROOT/scripts/utils:$PATH"

