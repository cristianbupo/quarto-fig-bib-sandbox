# -----------------------------
# LaTeX + Quarto build helper (independent switches)
#
# Variables:
#   MODE       = final | draft | all          (default: final)
#   THEME      = light | dark                 (default: light)
#   BIB        = yes | no                     (default: yes)
#   MAIN       = paper                        (default: paper)
#   QMD        = paper.qmd                    (default: $(MAIN).qmd)
#   ENGINE     = pdflatex | lualatex | xelatex (default: pdflatex)
#   BIBTOOL    = bibtex | biber               (default: bibtex)
#   USE_QUARTO = yes | no                     (default: yes)
#   QUARTO     = quarto                       (default: quarto)
#
# Examples:
#   make
#   make build MODE=draft
#   make build MODE=all THEME=dark
#   make build MODE=draft THEME=dark BIB=no
#   make build ENGINE=lualatex MODE=draft THEME=dark
#   make lua MODE=all THEME=dark
#   make nobib MODE=all THEME=dark ENGINE=xelatex
#   make build USE_QUARTO=no   # compile existing .tex only
# -----------------------------

MAIN   ?= paper
QMD    ?= $(MAIN).qmd
OUTDIR ?= build

TEXFILE := $(MAIN).tex
PDF     := $(OUTDIR)/$(MAIN).pdf

MODE    ?= final
THEME   ?= light
BIB     ?= yes
ENGINE  ?= lualatex
BIBTOOL ?= bibtex

USE_QUARTO ?= yes
QUARTO     ?= quarto
# Extra CLI args if you need them later, e.g. QUARTO_ARGS='-P foo=bar'
QUARTO_ARGS ?=

LATEXFLAGS ?= -interaction=nonstopmode -halt-on-error -file-line-error
LATEX := $(ENGINE) $(LATEXFLAGS)

VALID_ENGINES := pdflatex lualatex xelatex
ifeq ($(filter $(ENGINE),$(VALID_ENGINES)),)
$(error Invalid ENGINE='$(ENGINE)'. Use one of: $(VALID_ENGINES))
endif

VALID_BIBTOOLS := bibtex biber
ifeq ($(filter $(BIBTOOL),$(VALID_BIBTOOLS)),)
$(error Invalid BIBTOOL='$(BIBTOOL)'. Use one of: $(VALID_BIBTOOLS))
endif

VALID_USE_QUARTO := yes no
ifeq ($(filter $(USE_QUARTO),$(VALID_USE_QUARTO)),)
$(error Invalid USE_QUARTO='$(USE_QUARTO)'. Use one of: $(VALID_USE_QUARTO))
endif

# Build TeX definitions (no extra spaces)
DEFS_THEME :=
ifeq ($(THEME),dark)
DEFS_THEME :=\def\darkMode{1}
endif

DEFS_MODE :=
ifneq ($(MODE),final)
DEFS_MODE :=\def\docMode{$(MODE)}
endif

DEFS :=$(DEFS_THEME)$(DEFS_MODE)

.PHONY: default build final draft all light dark bib nobib clean dirs \
        pdf lua xe showconfig qmd2tex texonly

default: build

dirs:
	@mkdir -p "$(OUTDIR)"

showconfig:
	@echo "MAIN=$(MAIN)"
	@echo "QMD=$(QMD)"
	@echo "OUTDIR=$(OUTDIR)"
	@echo "MODE=$(MODE)"
	@echo "THEME=$(THEME)"
	@echo "BIB=$(BIB)"
	@echo "ENGINE=$(ENGINE)"
	@echo "BIBTOOL=$(BIBTOOL)"
	@echo "USE_QUARTO=$(USE_QUARTO)"
	@echo "QUARTO=$(QUARTO)"
	@echo "QUARTO_ARGS=$(QUARTO_ARGS)"
	@echo "LATEX=$(LATEX)"
	@echo "DEFS=$(DEFS)"

# Generate $(TEXFILE) from $(QMD) before LaTeX compilation (default behavior)
qmd2tex:
	@if [ "$(USE_QUARTO)" = "yes" ]; then \
		if [ ! -f "$(QMD)" ]; then \
			echo "ERROR: Quarto source not found: $(QMD)"; \
			exit 1; \
		fi; \
		echo "==> Quarto: $(QMD) -> $(TEXFILE)"; \
		$(QUARTO) render "$(QMD)" --to latex --output "$(TEXFILE)" $(QUARTO_ARGS); \
	else \
		echo "==> Skipping Quarto step (USE_QUARTO=no)"; \
	fi

# Build PDF (automatically runs Quarto first unless USE_QUARTO=no)
build: qmd2tex dirs
	@echo "==> Building: MAIN=$(MAIN) MODE=$(MODE) THEME=$(THEME) BIB=$(BIB) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) -> $(PDF)"
	@$(LATEX) -output-directory="$(OUTDIR)" -jobname="$(MAIN)" "$(DEFS)\input{$(TEXFILE)}"
	@if [ "$(BIB)" = "yes" ]; then \
		if [ "$(BIBTOOL)" = "bibtex" ]; then \
			bibtex "$(OUTDIR)/$(MAIN)" >/dev/null 2>&1 || true; \
		else \
			biber --input-directory "$(OUTDIR)" --output-directory "$(OUTDIR)" "$(MAIN)" >/dev/null 2>&1 || true; \
		fi; \
		$(LATEX) -output-directory="$(OUTDIR)" -jobname="$(MAIN)" "$(DEFS)\input{$(TEXFILE)}"; \
		$(LATEX) -output-directory="$(OUTDIR)" -jobname="$(MAIN)" "$(DEFS)\input{$(TEXFILE)}"; \
	else \
		$(LATEX) -output-directory="$(OUTDIR)" -jobname="$(MAIN)" "$(DEFS)\input{$(TEXFILE)}"; \
	fi

# Compile existing .tex only (skip Quarto generation)
texonly:
	@$(MAKE) build USE_QUARTO=no MODE=$(MODE) THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL)

# Convenience aliases (still independent — you can override other vars)
final:
	@$(MAKE) build MODE=final THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

draft:
	@$(MAKE) build MODE=draft THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

all:
	@$(MAKE) build MODE=all THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

light:
	@$(MAKE) build THEME=light MODE=$(MODE) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

dark:
	@$(MAKE) build THEME=dark MODE=$(MODE) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

bib:
	@$(MAKE) build BIB=yes MODE=$(MODE) THEME=$(THEME) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

nobib:
	@$(MAKE) build BIB=no MODE=$(MODE) THEME=$(THEME) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) ENGINE=$(ENGINE) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

# Engine aliases
pdf:
	@$(MAKE) build ENGINE=pdflatex MODE=$(MODE) THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

lua:
	@$(MAKE) build ENGINE=lualatex MODE=$(MODE) THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

xe:
	@$(MAKE) build ENGINE=xelatex MODE=$(MODE) THEME=$(THEME) BIB=$(BIB) MAIN=$(MAIN) QMD=$(QMD) OUTDIR=$(OUTDIR) BIBTOOL=$(BIBTOOL) USE_QUARTO=$(USE_QUARTO)

clean:
	@echo "==> Removing LaTeX temporary files (and PDF) for MAIN=$(MAIN)"
	@rm -rf "$(OUTDIR)"
	@rm -f "$(MAIN).pdf" "$(MAIN).aux" "$(MAIN).bbl" "$(MAIN).blg" "$(MAIN).log" "$(MAIN).out" \
		"$(MAIN).toc" "$(MAIN).lof" "$(MAIN).lot" "$(MAIN).fls" "$(MAIN).fdb_latexmk" "$(MAIN).synctex.gz" \
		"$(MAIN).bcf" "$(MAIN).run.xml" "$(MAIN).nav" "$(MAIN).snm" "$(MAIN).vrb" "$(MAIN).xdv" "$(MAIN).dvi"
	@rm -f "$(OUTDIR)/$(MAIN).pdf" "$(OUTDIR)/$(MAIN).aux" "$(OUTDIR)/$(MAIN).bbl" "$(OUTDIR)/$(MAIN).blg" "$(OUTDIR)/$(MAIN).log" "$(OUTDIR)/$(MAIN).out" \
		"$(OUTDIR)/$(MAIN).toc" "$(OUTDIR)/$(MAIN).lof" "$(OUTDIR)/$(MAIN).lot" "$(OUTDIR)/$(MAIN).fls" "$(OUTDIR)/$(MAIN).fdb_latexmk" "$(OUTDIR)/$(MAIN).synctex.gz" \
		"$(OUTDIR)/$(MAIN).bcf" "$(OUTDIR)/$(MAIN).run.xml" "$(OUTDIR)/$(MAIN).nav" "$(OUTDIR)/$(MAIN).snm" "$(OUTDIR)/$(MAIN).vrb" "$(OUTDIR)/$(MAIN).xdv" "$(OUTDIR)/$(MAIN).dvi"
	@echo "==> Cleaned."
