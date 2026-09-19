# SPDX-License-Identifier: Apache-2.0 OR MIT
# Semantic Version: v0.0.1
.PHONY: all build audit test contrast validate compress prune clean help

all: build

help:
	@echo "Available Makefile targets:"
	@echo "  make build      - Compile static site using Rust static-site-generator"
	@echo "  make audit      - Run WCAG 2.2 AAA (Pa11y) and Lighthouse audits"
	@echo "  make contrast   - Verify color tokens against WCAG 2.2 AAA math ratios"
	@echo "  make validate   - Validate Markdown frontmatter schema integrity"
	@echo "  make compress   - Pre-compress static output with Brotli, Zstd & Gzip"
	@echo "  make prune      - Deterministically delete merged local/remote branches"
	@echo "  make clean      - Remove build artifacts and temporary files"

# Builds from ssg.toml, not config/ssg.json. The JSON config names a theme
# (`voxt`) that lives in another repository and sets template_dir to
# templates/tera, a Tera template set this version of ssg cannot render — it
# fails on the first `{{ page.title }}`. ssg.toml points at _layouts/, which is
# the template set that actually renders, and needs no external theme.
#
# ssg does not copy static/ into the output, so the stylesheets and images the
# pages reference have to be placed there afterwards or every one of them 404s.
build:
	@if command -v ssg >/dev/null 2>&1; then \
		ssg; \
		mkdir -p docs; \
		cp -R static/. docs/; \
		echo "copied static/ into docs/"; \
	elif [ -f build.sh ]; then \
		bash build.sh; \
	else \
		echo "Notice: Standard SSG layout ready. Run 'cargo install static-site-generator' to compile."; \
	fi

audit: contrast validate
	@if command -v pa11y-ci >/dev/null 2>&1; then \
		pa11y-ci --config .pa11yci; \
	fi

contrast:
	@/usr/bin/python3 scripts/audit-contrast.py

validate:
	@/usr/bin/python3 scripts/validate-frontmatter.py

compress:
	@bash scripts/compress-assets.sh public

prune:
	@bash scripts/prune-branches.sh origin

clean:
	@rm -rf public dist .cache coverage *.log
	@echo "Workspace cleaned."
