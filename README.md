# Quarto & LaTeX Build Helper

This `Makefile` provides a flexible, automated build system for compiling Quarto (`.qmd`) documents into LaTeX, and subsequently into PDF documents. It supports dynamic switching between themes, document modes, LaTeX engines, and bibliography tools without requiring changes to your source code.
## Features
* **Quarto Integration:** Automatically renders `.qmd` to `.tex` before building the PDF.
* **Pure LaTeX Mode:** Skip the Quarto step entirely if you prefer to work directly with `.tex` files.
* **Dynamic LaTeX Definitions:** Injects `\darkMode` and `\docMode` definitions into your LaTeX compilation based on your CLI arguments.
* **Engine & Bibliography Selection:** Easily switch between `pdflatex`, `lualatex`, `xelatex`, `bibtex`, and `biber`.
* **Clean Workspace:** Auxiliary files and the final PDF are neatly organized in a `build/` directory.
## Prerequisites
To use this build system, ensure you have the following installed on your system:
* `make`
* [Quarto CLI](https://quarto.org/docs/get-started/)
* A LaTeX distribution (e.g., TeX Live, MiKTeX, MacTeX)
## Usage
Simply open your terminal in the project directory and run `make`. By default, this will render `paper.qmd` to `paper.tex`, and then compile it to `build/paper.pdf` using `lualatex` and `bibtex`.
### Configuration Variables
You can override default behaviors by passing variables directly in the command line. 

| Variable          | Options                           | Default       | Description                                             |
| :---------------- | :-------------------------------- | :------------ | :------------------------------------------------------ |
| **`MAIN`**        | Any string                        | `paper`       | The base name of your primary file (without extension). |
| **`QMD`**         | Any filename                      | `$(MAIN).qmd` | The target Quarto source file.                          |
| **`MODE`**        | `final`, `draft`, `all`           | `final`       | Sets `\def\docMode{...}` in LaTeX (skipped if `final`). |
| **`THEME`**       | `light`, `dark`                   | `light`       | Sets `\def\darkMode{1}` in LaTeX if `dark` is selected. |
| **`ENGINE`**      | `pdflatex`, `lualatex`, `xelatex` | `lualatex`    | The LaTeX engine to compile the PDF.                    |
| **`BIB`**         | `yes`, `no`                       | `yes`         | Toggles bibliography compilation.                       |
| **`BIBTOOL`**     | `bibtex`, `biber`                 | `bibtex`      | The tool used for bibliography processing.              |
| **`USE_QUARTO`**  | `yes`, `no`                       | `yes`         | Toggles Quarto `.qmd` to `.tex` rendering.              |
| **`QUARTO_ARGS`** | CLI flags                         | *(empty)*     | Pass extra arguments to the Quarto render command.      |

### Command Examples
#### Basic Builds:
```bash
make                 # Builds final paper.pdf using lualatex and bibtex
make build MODE=draft # Builds paper with \def\docMode{draft}
```
#### Customizing Themes and Modes:
```bash
make build MODE=all THEME=dark
```
#### Changing Engines and Bibliography Tools:
```bash
make build ENGINE=xelatex BIBTOOL=biber
make build MODE=draft THEME=dark BIB=no
```
#### Working with Pure LaTeX (Bypassing Quarto):
```bash
make build USE_QUARTO=no
# Or use the built-in alias:
make texonly
```
#### Convenience Targets
Instead of typing out long variable strings, you can use built-in aliases for quick builds:
- `make draft`: Compiles with `MODE=draft`.
- `make dark`: Compiles with `THEME=dark`.
- `make nobib`: Skips the bibliography step.
- `make lua` / `make pdf` / `make xe`: Forces a specific LaTeX engine.
- `make showconfig`: Prints the current variable setup without building anything. Useful for debugging.
- `make clean`: Deletes the `build/` directory and removes any stray temporary LaTeX files from the root directory.    
---
_Note: To fully utilize `MODE` and `THEME`, ensure your LaTeX preamble is set up to read `\docMode` and `\darkMode` conditionals._