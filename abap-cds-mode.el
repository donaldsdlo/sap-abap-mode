;;; abap-cds-mode.el --- ABAP CDS Major Mode    -*- lexical-binding: t; -*-

;; Copyright (C) 2020-  Marian Piatkowski

;; Author: Marian Piatkowski <marianpiatkowski@web.de>
;; Keywords: SAP ABAP CDS Mode, Emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Major mode for SAP ABAP CDS (CDS = Core Data Services)

;;; Code:

(defvar abap-cds-mode-hook nil)

(defcustom abap-cds-indent-level 4
  "Indentation of ABAP CDS with respect to current scope."
  :type 'integer)

(defun abap-cds-is-empty-line()
  "Check whether line is empty, whitespaces and TABs are not significant."
  ;; (beginning-of-line)
  (save-excursion
    ;; (back-to-indentation)
    ;; (looking-at "$")))
    (beginning-of-line)
    (looking-at-p "[[:space:]]*$")))

(defun abap-cds-in-comment-p()
  "Check whether cursor is in comment block."
  (nth 4 (syntax-ppss)))

(defun abap-cds-indent-line()
  "Indent line."
  (interactive)
  (let ((cur-indent 0))
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at "[{]")
              (setq cur-indent (+ cur-indent abap-cds-indent-level))))
        (error nil))) ; end save-excursion
    (save-excursion
      (back-to-indentation)
      (cond ((abap-cds-in-comment-p) ; check for multiline comment block
             (setq cur-indent (+ cur-indent 1)))
            ((and (looking-at "[}]") (>= cur-indent abap-cds-indent-level))
             (setq cur-indent (- cur-indent abap-cds-indent-level)))))
    (indent-line-to cur-indent)))

(setq abap-cds-keywords
      '(
        "DEFINE" "VIEW" "SELECT" "AS" "FROM" "ASSOCIATION" "PROJECTION" "ON" "WHERE" "NOT NULL"
        "KEY" "REDIRECTED" "TO" "LOCALIZED" "ENTITY" "ROOT" "PARENT" "COMPOSITION CHILD" "EXTEND"
        ;; RAP
        "IMPLEMENTATION UNMANAGED" "IMPLEMENTATION MANAGED" "IMPLEMENTATION ABSTRACT" "MANAGED WITH ADDITIONAL SAVE"
        "BEHAVIOR FOR" "LATE NUMBERING" "PERSISTENT TABLE" "LOCK MASTER" "LOCK DEPENDENT"
        "MAPPING FOR" "CORRESPONDING"
        "CREATE" "UPDATE" "DELETE"
        "ACTION"
        ))
(setq abap-cds-keywords (append abap-cds-keywords (mapcar 'downcase abap-cds-keywords)))

(setq abap-cds-keywords-regexp (regexp-opt abap-cds-keywords 'symbols))
(setq abap-cds-font-lock-keywords
      `(
        ("^@.*$" . font-lock-builtin-face)
        (,abap-cds-keywords-regexp . font-lock-keyword-face)
        ))

(defun abap-cds-syntax-propertize-annotation (start end)
  (let ((case-fold-search nil))
    (goto-char start)
    (funcall
     (syntax-propertize-rules
      ("\\(^@.*\\)$" (0 "w")))
     start end)
     ))

(defvar abap-cds-mode-syntax-table
  (let ((abap-cds-mode-syntax-table (make-syntax-table)))
    ;; set \" back to non-comment syntax
    (modify-syntax-entry ?\" "w" abap-cds-mode-syntax-table)
    (modify-syntax-entry ?' "\"" abap-cds-mode-syntax-table)
    (modify-syntax-entry ?_  "w" abap-cds-mode-syntax-table)
    ;; comments in ABAP CDS
    (modify-syntax-entry ?\/ ". 124b" abap-cds-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" abap-cds-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" abap-cds-mode-syntax-table)
    abap-cds-mode-syntax-table)
  "Syntax table for ABAP CDS Mode")

;;;###autoload
(define-derived-mode abap-cds-mode prog-mode
  "ABAP CDS Mode"
  ;; Major mode for ABAP Core Data Services
  (set-syntax-table abap-cds-mode-syntax-table)

  ;;; Search Based
  ;; Code for syntax highlighting
  (setq-local font-lock-defaults '(abap-cds-font-lock-keywords nil nil))
  (setq-local indent-line-function 'abap-cds-indent-line)
  (setq-local syntax-propertize-function 'abap-cds-syntax-propertize-annotation)

  (run-hooks 'abap-cds-mode-hook)
  )

;; clear memory
(setq abap-cds-keywords nil)
(setq abap-cds-keywords-regexp nil)

;; add the mode to the list
(provide 'abap-cds-mode)
