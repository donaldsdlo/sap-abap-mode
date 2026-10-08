# sap-abap-mode

This is a fork of [qianmarv/sap-abap-mode](https://github.com/qianmarv/sap-abap-mode).
The development of the original project has been discontinued.

`sap-abap-mode` currently supports syntax highlighting and indentation<sup>[1](#footnote1)</sup> of
ABAP development files and CDS views.

## Installation

This package is managed with [straight.el](https://github.com/radian-software/straight.el)
and [use-package](https://github.com/jwiegley/use-package); both are assumed to be already
installed and configured.

Register the local checkout as a straight package (the directory must be a git repository),
then declare each major mode with `use-package`. Because straight already builds the package,
the per-mode blocks use `:straight nil` so use-package only loads them:

```elisp
;; 1. Point straight at your local checkout (requires a git repo)
(straight-use-package
 '(abap-mode :local-repo "path/to/sap-abap-mode" :type git))

;; 2. Declare the modes; straight already built the package, so :straight nil
(use-package abap-mode
  :straight nil
  :mode (("\\.abap\\'" . abap-mode)
         ("\\.\\(asprog\\|asinc\\|aclass\\)\\'" . abap-mode)))

(use-package abap-cds-mode
  :straight nil
  :mode (("\\.cds\\'" . abap-cds-mode)
         ("\\.asddls\\'" . abap-cds-mode)))
```

If you prefer to let straight pull from the upstream repository instead of a local checkout,
replace the `straight-use-package` form with a `:straight` recipe on the mode declaration,
for example:

```elisp
(use-package abap-mode
  :straight (:host github :repo "qianmarv/sap-abap-mode")
  :mode (("\\.abap\\'" . abap-mode)
         ("\\.\\(asprog\\|asinc\\|aclass\\)\\'" . abap-mode)))
```

## Change Log

### 2026-10-08
- **Indentation default is now 4 spaces.** `abap-indent-level`, `abap-cds-indent-level`,
  and `abap-ddic-indent-level` changed from `2` to `4`.
- **Documentation reference updated.** The keyword list in `abap-mode.el` now points to the
  current ABAP Keyword Documentation (ABAP for Cloud Development, latest 7.58) instead of the
  stale 7.51 static page.
- **Modern ABAP (7.5x) keywords added.** `abap-mode.el` now highlights `REDUCE`, `FILTER`,
  `LINES OF`, `FOR`, `STEP`, `EXACT`, `RAISE SHORTDUMP`, and `SHORTDUMP`; the built-in type
  list gained `INT8`, `UTCLONG`, `DATN`, and `TIMN`.
- **Installation docs converted** to `use-package` + `straight.el` format.
- **SELECT SQL clauses no longer indented.** `SELECT` and `ENDSELECT` were removed
  from the block open/close keyword lists in `abap-indention.el`, so `FROM`,
  `FOR ALL ENTRIES`, `WHERE`, `INTO`, etc. now align with the `SELECT` keyword
  instead of being indented (modern single-statement `SELECT ... INTO TABLE`
  style). Note: as a consequence, `SELECT ... ENDSELECT` loop bodies are also
  no longer indented.
- **Multi-line statement continuation rules.** A line is now treated as a
  continuation of the previous statement when the previous non-empty line does
  not end with a statement-terminating period (periods inside strings/comments
  are ignored). For such continuations:
  - a line that **does not** start with a keyword is indented one level relative
    to the statement's first keyword;
  - a line that **does** start with a keyword (e.g. the `FROM`/`WHERE`/`INTO`
    clauses of a `SELECT`, or `EXPORTING`/`IMPORTING` of a `CALL FUNCTION`)
    aligns with the statement's first keyword.
  This makes `IMPORT a` / `b FROM MEMORY ID ...` and similar spans indent the
  operand line while aligning keyword-led clauses. Known limitation: a string
  literal split across lines cannot be tracked per-line, so the continuation
  following its closing quote may be mis-indented.

<a name="footnote1">1</a>: the indentation rules only cover basic statements
