;;; abap-ddic-mode.el --- ABAP DDIC Major Mode    -*- lexical-binding: t; -*-

;; Copyright (C) 2020-  Marian Piatkowski

;; Author: Marian Piatkowski <marianpiatkowski@web.de>
;; Keywords: SAP ABAP DDIC Mode, Emacs

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
;; Major mode for SAP ABAP DDIC

;;; Code

(defvar abap-ddic-mode-hook nil)

(defcustom abap-ddic-indent-level 4
  "Indentation of ABAP DDIC with respect to current scop."
  :type 'integer)

(defun abap-ddic-is-empty-line()
  "Check whether line is empty, whitespaces and TABs are not significant."
  ;; (beginning-of-line)
  (save-excursion
    ;; (back-to-indentation)
    ;; (looking-at "$")))
    (beginning-of-line)
    (looking-at-p "[[:space:]]*$")))

(defun abap-ddic-in-comment-p()
  "Check whether cursor is in comment block."
  (nth 4 (syntax-ppss)))

(defun abap-ddic-indent-line()
  "Indent line."
  (interactive)
  (let ((cur-indent 0))
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at "[{]")
              (setq cur-indent (+ cur-indent abap-ddic-indent-level))))
        (error nil))) ; end save-excursion
    (save-excursion
      (back-to-indentation)
      (cond ((abap-ddic-in-comment-p) ; check for multiline comment block
             (setq cur-indent (+ cur-indent 1)))
            ((and (looking-at "[}]") (>= cur-indent abap-ddic-indent-level))
             (setq cur-indent (- cur-indent abap-ddic-indent-level)))))
    (indent-line-to cur-indent)))

(setq abap-ddic-keywords
      '(
        "DEFINE TYPE" "DEFINE TABLE"
        "KEY" "WITH FOREIGN KEY" "WITH VALUE HELP" "INCLUDE" "WITH SUFFIX" "NOT NULL"
        "WHERE" "AND"
        ))
(setq abap-ddic-keywords (append abap-ddic-keywords (mapcar 'downcase abap-ddic-keywords)))

(setq abap-ddic-keywords-regexp (regexp-opt abap-ddic-keywords 'symbols))
(setq abap-ddic-font-lock-keywords
      `(
        ("^@.*$" . font-lock-builtin-face)
        (,abap-ddic-keywords-regexp . font-lock-keyword-face)
        ))

(defun abap-ddic-syntax-propertize-annotation (start end)
  (let ((case-fold-search nil))
    (goto-char start)
    (funcall
     (syntax-propertize-rules
      ("\\(^@.*\\)$" (0 "w")))
     start end)))

(defvar abap-ddic-mode-syntax-table
  (let ((abap-ddic-mode-syntax-table (make-syntax-table)))
    ;; set \" back to non-comment syntax
    (modify-syntax-entry ?\" "w" abap-ddic-mode-syntax-table)
    (modify-syntax-entry ?' "\"" abap-ddic-mode-syntax-table)
    (modify-syntax-entry ?_  "w" abap-ddic-mode-syntax-table)
    ;; comments in ABAP DDIC
    (modify-syntax-entry ?\/ ". 124b" abap-ddic-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" abap-ddic-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" abap-ddic-mode-syntax-table)
    abap-ddic-mode-syntax-table)
  "Syntax table for ABAP DDIC Mode")

;;;###autoload
(define-derived-mode abap-ddic-mode prog-mode
  "ABAP DDIC Mode"
  ;; Major mode for ABAP Dictionary
  (set-syntax-table abap-ddic-mode-syntax-table)

  ;;; Search Based
  ;; Code for syntax highlighting
  (setq-local font-lock-defaults '(abap-ddic-font-lock-keywords nil nil))
  (setq-local indent-line-function 'abap-ddic-indent-line)
  (setq-local syntax-propertize-function 'abap-ddic-syntax-propertize-annotation)

  (run-hooks 'abap-ddic-mode-hook)
  )

;; clear memory
(setq abap-ddic-keywords nil)
(setq abap-ddic-keywords-regexp nil)

;; add the mode to the list
(provide 'abap-ddic-mode)
