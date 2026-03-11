# Econ-ARK Repository Makefile
# Handles mathematical notation generation and common tasks

# Paths
ECON_ARK_DIR := .econ-ark
MACROS_SOURCE := $(ECON_ARK_DIR)/macros.yaml
GENERATED_DIR := $(ECON_ARK_DIR)/generated
GENERATOR := $(ECON_ARK_DIR)/generate-macros.py

# Generated files
STY_FILE := $(GENERATED_DIR)/econark-shortcuts.sty
MYST_FRONTMATTER := $(GENERATED_DIR)/myst-frontmatter.yaml
JUPYTER_CONFIG := $(GENERATED_DIR)/jupyter-book-config.yaml
SPHINX_CONFIG := $(GENERATED_DIR)/sphinx-config.py
DOCS_FILE := $(GENERATED_DIR)/MACROS.md

# All generated files
GENERATED_FILES := $(STY_FILE) $(MYST_FRONTMATTER) $(JUPYTER_CONFIG) $(SPHINX_CONFIG) $(DOCS_FILE)

# Default target
.PHONY: all
all: macros

# Generate all macro files from source
.PHONY: macros
macros: $(GENERATED_FILES)

$(GENERATED_FILES): $(MACROS_SOURCE) $(GENERATOR)
	@echo "Generating macro files from $(MACROS_SOURCE)..."
	python $(GENERATOR)
	@echo "✓ Macro generation complete"

# Check if macro files are up-to-date
.PHONY: check-macros
check-macros:
	@echo "Checking if macro files are up-to-date..."
	python $(GENERATOR) --check

# Force regeneration of macros
.PHONY: regen-macros
regen-macros:
	@echo "Force regenerating macro files..."
	rm -f $(GENERATED_FILES)
	$(MAKE) macros

# Clean generated files
.PHONY: clean-macros
clean-macros:
	@echo "Cleaning generated macro files..."
	rm -f $(GENERATED_FILES)
	@echo "✓ Generated files removed"

# Validate macro source file
.PHONY: validate-macros
validate-macros:
	@echo "Validating $(MACROS_SOURCE)..."
	python -c "import yaml; yaml.safe_load(open('$(MACROS_SOURCE)'))" && echo "✓ YAML is valid"

# Show macro statistics
.PHONY: macro-stats
macro-stats: $(GENERATED_FILES)
	@echo "Macro Statistics:"
	@echo "=================="
	@grep -c "ARKcommand" $(STY_FILE) | sed 's/.*:/LaTeX commands: /' || true
	@grep -c "^  '\\\\" $(MYST_FRONTMATTER) | sed 's/.*:/MyST macros: /' || true
	@grep -c "^    '\\\\" $(SPHINX_CONFIG) | sed 's/.*:/Sphinx macros: /' || true
	@wc -l $(MACROS_SOURCE) | sed 's/.*\/macros.yaml/Source lines: /' | sed 's/^ *//'

# View documentation
.PHONY: view-docs
view-docs: $(DOCS_FILE)
	@cat $(DOCS_FILE)

# Development: continuous regeneration when source changes
.PHONY: watch-macros
watch-macros:
	@echo "Watching $(MACROS_SOURCE) for changes... (Press Ctrl+C to stop)"
	@while true; do \
		$(MAKE) --quiet check-macros || $(MAKE) --quiet macros; \
		sleep 2; \
	done

# Help target
.PHONY: help
help:
	@echo "Econ-ARK Makefile - Mathematical Notation Management"
	@echo "======================================================"
	@echo ""
	@echo "Macro Targets:"
	@echo "  macros          Generate all macro files (default)"
	@echo "  check-macros    Check if macro files are up-to-date"
	@echo "  regen-macros    Force regenerate all macro files"
	@echo "  clean-macros    Remove all generated macro files"
	@echo "  validate-macros Validate YAML syntax"
	@echo "  macro-stats     Show statistics about macros"
	@echo "  view-docs       Display generated documentation"
	@echo "  watch-macros    Continuously regenerate on changes"
	@echo ""
	@echo "General:"
	@echo "  help           Show this help message"
	@echo "  all            Run default targets"
	@echo ""
	@echo "Files:"
	@echo "  Source:           $(MACROS_SOURCE)"
	@echo "  LaTeX Output:     $(STY_FILE)"
	@echo "  MyST Frontmatter: $(MYST_FRONTMATTER)"
	@echo "  Jupyter Book:     $(JUPYTER_CONFIG)"
	@echo "  Sphinx Config:    $(SPHINX_CONFIG)"
	@echo "  Documentation:    $(DOCS_FILE)"

# Include this in your main build targets
# Example usage in paper builds:
.PHONY: example-paper
example-paper: $(STY_FILE)
	@echo "Example: Building paper with generated macros"
	@echo "pdflatex would run here with access to $(STY_FILE)"

# Include this in your Jupyter Book builds
.PHONY: example-jupyter-book
example-jupyter-book: $(JUPYTER_CONFIG)
	@echo "Example: Building Jupyter Book with generated macros"
	@echo "jupyter-book build would run here with config from $(JUPYTER_CONFIG)"

# Include this in your Sphinx builds
.PHONY: example-sphinx
example-sphinx: $(SPHINX_CONFIG)
	@echo "Example: Building Sphinx project with generated macros"
	@echo "sphinx-build would run here with config from $(SPHINX_CONFIG)" 