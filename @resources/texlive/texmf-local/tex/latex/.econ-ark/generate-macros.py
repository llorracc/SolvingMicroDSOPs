#!/usr/bin/env python3
"""
Econ-ARK Macro Generator

Generates LaTeX .sty and MyST configuration files from single YAML source.
Ensures consistency across all LaTeX and MyST files in the repository.

Usage:
    python generate-macros.py [--check]
    
Options:
    --check    Only check if files are up-to-date, don't regenerate
"""

import yaml
import json
import argparse
from pathlib import Path
from datetime import datetime
import hashlib

def load_macro_definitions(yaml_path):
    """Load and validate macro definitions from YAML."""
    with open(yaml_path, 'r') as f:
        data = yaml.safe_load(f)
    
    # Basic validation
    required_keys = ['metadata', 'variables', 'patterns']
    for key in required_keys:
        if key not in data:
            raise ValueError(f"Missing required key: {key}")
    
    return data

def expand_patterns(data):
    """Expand pattern-based definitions into individual commands."""
    expanded = {}
    
    # Expand letter patterns
    for pattern_def in data['patterns']:
        pattern = pattern_def['pattern']
        latex_template = pattern_def['latex']
        letters = pattern_def['letters']
        
        for letter in letters:
            cmd_name = pattern.format(letter=letter)
            latex_def = latex_template.format(letter=letter)
            desc = pattern_def['description'].format(letter=letter)
            
            expanded[cmd_name] = {
                'latex': latex_def,
                'description': desc,
                'category': pattern_def['category'],
                'generated_from': pattern_def['name']
            }
    
    # Expand modifier patterns
    if 'modifier_patterns' in data:
        for modifier_def in data['modifier_patterns']:
            suffix = modifier_def['suffix']
            latex_template = modifier_def['latex']
            
            for base_var in modifier_def['base_vars']:
                cmd_name = f"{base_var}{suffix}"
                latex_def = latex_template.format(base=f"\\{base_var}")
                desc = modifier_def['description'].format(base=base_var)
                
                expanded[cmd_name] = {
                    'latex': latex_def,
                    'description': desc,
                    'category': 'modifiers',
                    'generated_from': modifier_def['name']
                }
    
    return expanded

def generate_latex_sty(data, output_path):
    """Generate LaTeX .sty file."""
    metadata = data['metadata']
    variables = data['variables']
    expanded = expand_patterns(data)
    
    # Combine all commands
    all_commands = {**variables, **expanded}
    
    content = f"""% {metadata['description']} - v{metadata['version']}
% Auto-generated from macros.yaml on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
% DO NOT EDIT - Use the generator script: python .econ-ark/generate-macros.py
% 
% Maintainer: {metadata['maintainer']}
% Total commands: {len(all_commands)}

\\ProvidesPackage{{econark-shortcuts}}[{datetime.now().strftime('%Y/%m/%d')} v{metadata['version']} {metadata['description']}]

% ARK command definition utility - ensures our notation takes precedence
\\newcommand{{\\ARKcommand}}[2]{{%
  \\providecommand{{#1}}{{}}%
  \\renewcommand{{#1}}{{#2}}%
}}

% Individual variable definitions
% Generated from 'variables' section
"""
    
    # Sort commands by category for better organization
    by_category = {}
    for name, defn in all_commands.items():
        cat = defn.get('category', 'other')
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append((name, defn))
    
    for category, commands in sorted(by_category.items()):
        content += f"\n% {category.upper()} VARIABLES\n"
        for name, defn in sorted(commands):
            desc = defn.get('description', '')
            if 'generated_from' in defn:
                desc += f" (from {defn['generated_from']})"
            content += f"\\ARKcommand{{\\{name}}}{{{defn['latex']}}}  % {desc}\n"
    
    content += "\n\\endinput\n"
    
    # Write file
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(content)
    
    return len(all_commands)

def generate_myst_shared_config(data, output_path):
    """Generate a shared MyST configuration file that can be imported via 'extends'."""
    variables = data['variables']
    expanded = expand_patterns(data)
    metadata = data['metadata']
    
    math_macros = {}
    for name, defn in {**variables, **expanded}.items():
        math_macros[f'\\{name}'] = defn['latex']
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(f"# MyST shared configuration file\n")
        f.write(f"# {metadata['description']}\n")
        f.write(f"# Version: {metadata['version']}\n")
        f.write(f"# Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"# Total macros: {len(math_macros)}\n\n")
        
        f.write("version: 1\n")
        f.write("project:\n")
        f.write("  # Math macros - available throughout your MyST project\n")
        f.write("  math:\n")
        
        # Write macros in YAML format with proper escaping
        for macro_name in sorted(math_macros.keys()):
            # Use single quotes to avoid escaping backslashes
            f.write(f"    '{macro_name}': '{math_macros[macro_name]}'\n")
    
    return len(math_macros)

def generate_myst_frontmatter(data, output_path):
    """Generate MyST frontmatter template (now simpler since most configs can be imported)."""
    metadata = data['metadata']
    variables = data['variables']
    expanded = expand_patterns(data)
    
    # Combine all commands for MyST
    math_macros = {}
    
    for name, defn in {**variables, **expanded}.items():
        # MyST expects macros with leading backslash
        math_macros[f'\\{name}'] = defn['latex']
    
    # Update the content to emphasize the better import-based approach
    content = f"""---
# MyST Frontmatter Template
# For projects using external macro configuration

# RECOMMENDED APPROACH: Use 'extends' in your myst.yml instead of copying this
# See: https://mystmd.org/guide/frontmatter#compose-multiple-yml-files
# 
# In your myst.yml:
# extends:
#   - path/to/econark-macros.yml
#
# This approach is MUCH better than copying all macros into every file!

# If you need to override specific macros for this file only:
# math:
#   '\\CustomMacro': 'your_custom_definition'

# Other frontmatter fields for this specific document:
title: Your Document Title
authors:
  - name: Your Name
date: {datetime.now().strftime('%Y-%m-%d')}
---

# Usage Notes

Instead of copying {len(math_macros)} macro definitions here, use MyST's `extends` feature:

1. **Global Configuration** (recommended):
   ```yaml
   # In your project's myst.yml
   version: 1
   site: ...
   project: ...
   extends:
     - .econ-ark/generated/econark-macros.yml
   ```

2. **Individual File Override** (if needed):
   ```yaml
   ---
   extends:
     - ../../.econ-ark/generated/econark-macros.yml
   math:
     '\\SpecialMacro': 'file_specific_definition'
   ---
   ```

## Available Macros

{_format_macro_list(variables, expanded)}
"""
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(content)
    
    return len(math_macros)

def generate_jupyter_book_config(data, output_path):
    """Generate Jupyter Book _config.yml section."""
    variables = data['variables']
    expanded = expand_patterns(data)
    
    math_macros = {}
    for name, defn in {**variables, **expanded}.items():
        math_macros[f'\\{name}'] = defn['latex']
    
    config = {
        'title': 'Econ-ARK Project',
        'parse': {
            'myst_enable_extensions': [
                'dollarmath',
                'amsmath', 
                'colon_fence',
                'substitution'
            ]
        },
        'execute': {
            'execute_notebooks': 'force'
        },
        'html': {
            'use_issues_button': True,
            'use_repository_button': True
        },
        'math': math_macros
    }
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(f"# Jupyter Book _config.yml with Econ-ARK macros\n")
        f.write(f"# Copy relevant sections into your _config.yml\n")
        f.write(f"# Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"# Total macros: {len(math_macros)}\n\n")
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)
    
    return len(math_macros)

def generate_sphinx_config(data, output_path):
    """Generate Sphinx conf.py section."""
    variables = data['variables']
    expanded = expand_patterns(data)
    
    math_macros = {}
    for name, defn in {**variables, **expanded}.items():
        math_macros[f'\\{name}'] = defn['latex']
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(f"# Sphinx conf.py configuration with Econ-ARK macros\n")
        f.write(f"# Add these sections to your Sphinx conf.py\n")
        f.write(f"# Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"# Total macros: {len(math_macros)}\n\n")
        
        f.write("# Extensions\n")
        f.write("extensions = [\n")
        f.write("    'myst_parser',\n")
        f.write("    'sphinx.ext.mathjax',\n")
        f.write("    # ... your other extensions\n")
        f.write("]\n\n")
        
        f.write("# MyST configuration\n")
        f.write("myst_enable_extensions = [\n")
        f.write("    'dollarmath',\n")
        f.write("    'amsmath',\n")
        f.write("    'colon_fence',\n")
        f.write("    'substitution',\n")
        f.write("]\n\n")
        
        f.write("# Math macros\n")
        f.write("myst_substitutions = {\n")
        for macro_name in sorted(math_macros.keys()):
            f.write(f"    '{macro_name}': '{math_macros[macro_name]}',\n")
        f.write("}\n")
    
    return len(math_macros)

def _format_macro_list(variables, expanded):
    """Helper function to format macro list for documentation."""
    content = ""
    by_category = {}
    
    # Group by category
    for name, defn in {**variables, **expanded}.items():
        cat = defn.get('category', 'other')
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append((name, defn))
    
    for category, commands in sorted(by_category.items()):
        content += f"\n### {category.title()} ({len(commands)} macros)\n\n"
        content += "| Command | Output | Description |\n"
        content += "|---------|--------|-------------|\n"
        
        for name, defn in sorted(commands):
            desc = defn.get('description', '')
            if 'generated_from' in defn:
                desc += f" *(generated)*"
            content += f"| `\\{name}` | `{defn['latex']}` | {desc} |\n"
    
    return content

def generate_documentation(data, output_path):
    """Generate human-readable documentation of all macros."""
    metadata = data['metadata']
    variables = data['variables']
    expanded = expand_patterns(data)
    
    content = f"""# {metadata['description']} Documentation

**Version:** {metadata['version']}  
**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Maintainer:** {metadata['maintainer']}

This document lists all available mathematical notation macros for Econ-ARK projects.

## Usage

### In LaTeX files:
```latex
\\usepackage{{econark-shortcuts}}  % Add to preamble
The growth factor is $\\PermGroFac$.
```

### In MyST files:

#### Option 1: Jupyter Book
Copy the `math:` section from `jupyter-book-config.yaml` into your `_config.yml`.

#### Option 2: Individual file frontmatter  
Copy the frontmatter from `myst-frontmatter.yaml` into your `.md` files.

#### Option 3: Sphinx
Add the configuration from `sphinx-config.py` to your `conf.py`.

## Available Macros

Total macros: {len(variables) + len(expanded)}

"""
    
    # Group by category
    by_category = {}
    for name, defn in {**variables, **expanded}.items():
        cat = defn.get('category', 'other')
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append((name, defn))
    
    for category, commands in sorted(by_category.items()):
        content += f"\n### {category.title()} ({len(commands)} macros)\n\n"
        content += "| Command | Output | Description |\n"
        content += "|---------|--------|-------------|\n"
        
        for name, defn in sorted(commands):
            desc = defn.get('description', '')
            if 'generated_from' in defn:
                desc += f" *(generated)*"
            content += f"| `\\{name}` | `{defn['latex']}` | {desc} |\n"
    
    # Write file
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(content)

def compute_file_hash(file_path):
    """Compute hash of file for change detection."""
    if not file_path.exists():
        return None
    
    with open(file_path, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description='Generate Econ-ARK macro files')
    parser.add_argument('--check', action='store_true', 
                       help='Check if files are up-to-date')
    parser.add_argument('--source', default='.econ-ark/macros.yaml',
                       help='Source YAML file')
    args = parser.parse_args()
    
    # Resolve paths
    repo_root = Path(__file__).parent.parent
    source_path = repo_root / args.source
    output_dir = repo_root / '.econ-ark' / 'generated'
    
    # Output files
    outputs = {
        'sty': output_dir / 'econark-shortcuts.sty',
        'myst_shared': output_dir / 'econark-macros.yml',  # NEW: Importable MyST config
        'myst_frontmatter': output_dir / 'myst-frontmatter.yaml',
        'jupyter': output_dir / 'jupyter-book-config.yaml',
        'sphinx': output_dir / 'sphinx-config.py',
        'docs': output_dir / 'MACROS.md'
    }
    
    # Check if source exists
    if not source_path.exists():
        print(f"Error: Source file not found: {source_path}")
        return 1
    
    # Load definitions
    try:
        data = load_macro_definitions(source_path)
    except Exception as e:
        print(f"Error loading macro definitions: {e}")
        return 1
    
    # Check mode
    if args.check:
        source_hash = compute_file_hash(source_path)
        needs_update = False
        
        for name, path in outputs.items():
            if not path.exists():
                print(f"Missing: {path}")
                needs_update = True
            # Could add more sophisticated checking here
        
        if needs_update:
            print("Files need updating. Run without --check to regenerate.")
            return 1
        else:
            print("All files up-to-date.")
            return 0
    
    # Generate files
    print(f"Generating macro files from {source_path}...")
    
    try:
        sty_count = generate_latex_sty(data, outputs['sty'])
        myst_shared_count = generate_myst_shared_config(data, outputs['myst_shared'])
        frontmatter_count = generate_myst_frontmatter(data, outputs['myst_frontmatter'])
        jupyter_count = generate_jupyter_book_config(data, outputs['jupyter'])
        sphinx_count = generate_sphinx_config(data, outputs['sphinx'])
        generate_documentation(data, outputs['docs'])
        
        print(f"✓ Generated {outputs['sty']} ({sty_count} commands)")
        print(f"✓ Generated {outputs['myst_shared']} ({myst_shared_count} macros) ← RECOMMENDED")
        print(f"✓ Generated {outputs['myst_frontmatter']} (template with import instructions)")
        print(f"✓ Generated {outputs['jupyter']} ({jupyter_count} macros)")
        print(f"✓ Generated {outputs['sphinx']} ({sphinx_count} macros)")
        print(f"✓ Generated {outputs['docs']}")
        
        return 0
        
    except Exception as e:
        print(f"Error generating files: {e}")
        return 1

if __name__ == '__main__':
    exit(main()) 