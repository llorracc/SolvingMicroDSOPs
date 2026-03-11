# Econ-ARK Mathematical Notation System

This directory contains the **single source of truth** for all mathematical notation used across Econ-ARK projects. It ensures consistency between LaTeX and MyST markdown files throughout the repository.

## Architecture

```
.econ-ark/
├── macros.yaml              # Single source definition file
├── generate-macros.py       # Generator script  
├── generated/               # Auto-generated files (DO NOT EDIT)
│   ├── econark-shortcuts.sty    # For LaTeX files
│   ├── myst-frontmatter.yaml    # For MyST file frontmatter
│   ├── jupyter-book-config.yaml # For Jupyter Book _config.yml
│   ├── sphinx-config.py         # For Sphinx conf.py
│   └── MACROS.md                # Human-readable documentation
└── README.md               # This file
```

## Quick Start

### Generate macro files:
```bash
python .econ-ark/generate-macros.py
```

### Check if files are up-to-date:
```bash
python .econ-ark/generate-macros.py --check
```

## Usage in Files

### LaTeX Files
Add to your preamble:
```latex
\usepackage{econark-shortcuts}

% Now use macros anywhere:
The permanent growth factor $\PermGroFac$ affects consumption $\cLvl$.
```

### MyST Files

**RECOMMENDED: Use Import-Based Configuration** 🎯

MyST supports importing external configuration files, avoiding the need to copy 200+ macro definitions into every file.

#### Option 1: Global MyST Project (Recommended)
Add to your `myst.yml`:
```yaml
version: 1
site: ...
project: ...
extends:
  - .econ-ark/generated/econark-macros.yml  # Import all macros globally
```

#### Option 2: Individual File Import
Add to specific `.md` files when you need file-specific overrides:
```yaml
---
extends:
  - path/to/.econ-ark/generated/econark-macros.yml
math:
  '\CustomMacro': 'file_specific_definition'  # Optional overrides
---
```

#### Option 3: Jupyter Book Global Config
Copy the `math:` section from `generated/jupyter-book-config.yaml` into your `_config.yml`:
```yaml
# In _config.yml
math:
  '\PermGroFac': '\mathcal{G}'
  '\cLvl': '\boldsymbol{\mathit{c}}'
  # ... 193 total macros
```

#### Option 4: Individual File Frontmatter (Not Recommended)
See `generated/myst-frontmatter.yaml` for import instructions instead of copying.

#### Option 5: Sphinx
Add configuration from `generated/sphinx-config.py` to your `conf.py`:
```python
myst_substitutions = {
    '\PermGroFac': '\mathcal{G}',
    '\cLvl': '\boldsymbol{\mathit{c}}',
    # ... etc
}
```

Then use in your `.md` files:
```markdown
The growth factor $\PermGroFac$ determines consumption $\cLvl$.
```

## Path Resolution for Deep Directory Structures

When MyST files are buried deep in subdirectories, there are several strategies for handling the `extends` path:

### 🏆 **Global Project Configuration (RECOMMENDED)**
Put the `extends` in your **root `myst.yml`** instead of individual files:

```yaml
# In repo-root/myst.yml  
version: 1
site: ...
project: ...
extends:
  - .econ-ark/generated/econark-macros.yml  # Defined once at root
```

Now **all MyST files** automatically inherit macros regardless of directory depth:
```
repo-root/
├── myst.yml                    # ← extends here
├── .econ-ark/generated/econark-macros.yml
└── papers/economics/models/
    └── deep-paper.md          # ← gets macros automatically!
```

### **Alternative: Remote URL**
Reference directly from your repository:
```yaml
---
extends:
  - https://raw.githubusercontent.com/your-org/your-repo/main/.econ-ark/generated/econark-macros.yml
---
```

### **Alternative: Relative Path Calculation**
For individual file extends, calculate the relative path:

| File Location | Relative Path |
|---------------|---------------|
| `paper.md` | `.econ-ark/generated/econark-macros.yml` |
| `papers/paper.md` | `../.econ-ark/generated/econark-macros.yml` |
| `papers/econ/paper.md` | `../../.econ-ark/generated/econark-macros.yml` |
| `papers/econ/models/paper.md` | `../../../.econ-ark/generated/econark-macros.yml` |

### **Alternative: Symlinks**
Create symlinks in common directories:
```bash
# Create symlinks for easier access
ln -s ../../.econ-ark/generated/econark-macros.yml papers/econark-macros.yml
ln -s ../../../.econ-ark/generated/econark-macros.yml papers/econ/econark-macros.yml
```

Then use: `extends: [econark-macros.yml]`

## Adding New Macros

1. **Edit `macros.yaml`** - Add new definitions to the appropriate section
2. **Run generator** - `python .econ-ark/generate-macros.py`  
3. **Commit both** - The source YAML and generated files

### Individual Variables
```yaml
variables:
  MyNewVar:
    latex: '\mathcal{V}'
    description: 'My new variable'
    category: 'custom'
```

### Pattern-Based Variables  
```yaml
patterns:
  - name: "Special functions"
    pattern: '{letter}Special'
    latex: '\mathfrak{{{letter}}}'
    description: 'Special function for letter {letter}'
    letters: 'abc'
    category: 'functions'
```

This generates: `\aSpecial`, `\bSpecial`, `\cSpecial`

## Build Integration

### Make Integration
```make
# In your Makefile
.econ-ark/generated/econark-shortcuts.sty: .econ-ark/macros.yaml
	python .econ-ark/generate-macros.py

# Add as dependency to your targets
paper.pdf: paper.tex .econ-ark/generated/econark-shortcuts.sty
	pdflatex paper.tex
```

### CI/CD Integration
```yaml
# In your GitHub Actions workflow
- name: Generate macros
  run: python .econ-ark/generate-macros.py

- name: Check macros are current
  run: python .econ-ark/generate-macros.py --check
```

## File Descriptions

| File | Purpose | Edit? |
|------|---------|-------|
| `macros.yaml` | Master definitions | ✅ YES |
| `generate-macros.py` | Generator script | ✅ YES |
| `generated/*.sty` | LaTeX package | ❌ NO - auto-generated |
| `generated/econark-macros.yml` | **MyST importable config** 🎯 | ❌ NO - auto-generated |
| `generated/myst-frontmatter.yaml` | MyST template (with import guide) | ❌ NO - auto-generated |
| `generated/jupyter-book-config.yaml` | Jupyter Book config | ❌ NO - auto-generated |
| `generated/sphinx-config.py` | Sphinx configuration | ❌ NO - auto-generated |
| `generated/MACROS.md` | Documentation | ❌ NO - auto-generated |

## Benefits

- **Consistency**: Identical notation across LaTeX and MyST
- **Maintainability**: Update once, deploy everywhere
- **Documentation**: Auto-generated macro documentation
- **Validation**: Catch notation errors early
- **Searchability**: Easy to find all uses of a macro

## Troubleshooting

### LaTeX can't find package
Ensure your LaTeX files can find the generated `.sty` file:
```latex
% Option 1: Relative path
\usepackage{.econ-ark/generated/econark-shortcuts}

% Option 2: Add to TEXINPUTS (recommended)
% export TEXINPUTS=".:.econ-ark/generated:"
\usepackage{econark-shortcuts}
```

### MyST macros not working
1. Check your `_config.yml` includes the math section
2. Verify MyST extensions are enabled
3. Ensure single quotes around macro definitions

### Generator errors
```bash
# Check YAML syntax
python -c "import yaml; yaml.safe_load(open('.econ-ark/macros.yaml'))"

# Run with verbose output  
python .econ-ark/generate-macros.py -v
```

---

**Maintainer:** econ-ark.org  
**Last Updated:** Auto-generated from macros.yaml 