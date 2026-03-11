# de-macro tools (general-purpose)

General-purpose tools for cleaning LaTeX files that use private macros.
These tools work on **any** LaTeX project — no project-specific logic.

## Contents

| File | Purpose |
|------|---------|
| `de-macro` | Gacs/Citi de-macro 1.4.1 (Python 3, portable shebang). Expands `\newcommand`/`\newenvironment` from `*-private.sty` into `*-clean.tex`. |
| `strip-comment-blocks.pl` | Removes `\begin{comment}...\end{comment}` blocks (handles nesting). Reads from file arg or stdin, writes to stdout. |
| `de-macro-postprocess.sh` | Runs two generic cleanups on a `-clean.tex` file (in place): (1) escape `#` inside `\href{URL}` for hyperref compatibility, (2) strip `\begin{comment}` blocks. |

## Typical usage from a project driver script

```bash
DEMACRO_DIR="$REPO/@resources/texlive/texmf-local/scripts/de-macro"
chmod +x "$DEMACRO_DIR"/de-macro "$DEMACRO_DIR"/*.sh "$DEMACRO_DIR"/*.pl 2>/dev/null || true

# 1. Project-specific preparation (create *-private.sty, etc.)
#    ... your project's prepare steps ...

# 2. Run de-macro (expands private macros)
"$DEMACRO_DIR/de-macro" MyDocument

# 3. Project-specific restoration (e.g. undo side-effects of macro expansion)
#    ... your project's restore steps ...

# 4. Generic postprocessing (escape \href #, strip comment blocks)
"$DEMACRO_DIR/de-macro-postprocess.sh" MyDocument-clean.tex
```

Steps 1 and 3 are project-specific and belong in your project's build scripts,
not here. Steps 2 and 4 use these general tools.
