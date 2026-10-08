;;; abap-indention.el --- Indentation functions    -*- lexical-binding: t; -*-

;; Copyright (C) 2020-  Marian Piatkowski
;; Copyright (C) 2018  Marvin Qian

;; Author: Marian Piatkowski <marianpiatkowski@web.de>
;; Author: Marvin Qian <qianmarv@gmail.com>
;; Keywords: ABAP indentation, Emacs

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

;;

;;; Code:

(defcustom abap-indent-level 4
  "Indentation of ABAP statements with respect to containing block."
  :type 'integer)

(setq abap--keywords-open '("IF" "ELSEIF" "ELSE" "LOOP" "DO" "FORM" "CASE" "CLASS" "TRY" "CATCH" "METHOD" "BEGIN OF" "INTERFACE" "WHILE"))
;; Note: SELECT is intentionally NOT treated as a block-opening keyword.
;; The SQL clauses (FROM, WHERE, INTO, ...) are aligned with the SELECT
;; keyword instead of being indented, matching the modern single-statement
;; SELECT ... INTO TABLE style.

(setq abap--keywords-close '("ENDIF" "ELSEIF" "ELSE" "ENDLOOP" "ENDDO" "ENDFORM" "ENDCASE" "ENDCLASS" "ENDTRY" "CATCH" "ENDMETHOD" "END OF" "ENDINTERFACE" "ENDWHILE"))
;; Note: ENDSELECT is intentionally omitted so it aligns with its SELECT
;; rather than being dedented to the enclosing block level.

;; Keywords that, when they begin a continuation line, align with the
;; first keyword of the statement (instead of being indented by one level).
;; This covers the SQL clauses of SELECT (FROM/WHERE/INTO/...), the
;; parameter clauses of CALL FUNCTION (EXPORTING/IMPORTING/...), and the
;; open/close keywords so a continuation never drifts unexpectedly.
(defvar abap--indent-align-keywords
  (append abap--keywords-open
          abap--keywords-close
          '("FROM" "WHERE" "INTO" "BY" "UP" "ORDER" "GROUP" "HAVING"
            "SET" "FOR" "WITH" "APPENDING" "CORRESPONDING" "FIELDS"
            "TABLE" "JOIN" "ON" "LEFT" "RIGHT" "INNER" "OUTER" "UNION"
            "USING" "CHANGING" "EXPORTING" "IMPORTING" "RECEIVING"
            "EXCEPTIONS" "MAPPING" "ASSOCIATION" "TO" "OF" "IN" "AND"
            "OR" "NOT"))
  "Keywords that align a continuation line with the statement's first keyword.")

(defvar abap--indent-align-keywords-regexp
  (regexp-opt abap--indent-align-keywords 'words)
  "Regexp matching `abap--indent-align-keywords' as whole words.")


(defun abap-is-empty-line()
  "Check whether line is empty, whitespaces and TABs are not significant."
  ;; (beginning-of-line)
  (save-excursion
    ;; (back-to-indentation)
    ;; (looking-at "$")))
    (beginning-of-line)
    (looking-at-p "[[:space:]]*$")))

(defun abap-is-comment-line()
  "Check whether line is a ABAP comment line."
  (save-excursion
    (back-to-indentation)
    (if (looking-at "\"")
        t
      (beginning-of-line)
      (looking-at "*"))
    ))


(defun abap-line-ends-statement-p ()
  "Return non-nil if the current line ends an ABAP statement, i.e.
its last significant character (outside of strings and comments) is
a period."
  (save-excursion
    (let ((eol (progn (end-of-line) (point)))
          (in-string nil)
          (last-term-pos nil))
      (goto-char (line-beginning-position))
      (while (< (point) eol)
        (cond
          ;; a double quote outside a string starts a comment to EOL
          ((and (not in-string) (eq (char-after) ?\"))
           (goto-char eol))
          ((eq (char-after) ?')
           (if in-string
               (progn
                 (forward-char 1)
                 (if (and (< (point) eol) (eq (char-after) ?'))
                     (forward-char 1)   ; escaped quote (doubled ')
                   (setq in-string nil)))
             (setq in-string t)
             (forward-char 1)))
          ((and (not in-string) (eq (char-after) ?.))
           (setq last-term-pos (point))
           (forward-char 1))
          (t (forward-char 1))))
      (and last-term-pos
           (not in-string)
           (save-excursion
             (goto-char last-term-pos)
             (forward-char 1)
             (skip-chars-forward " \t")
             (or (eolp) (eq (char-after) ?\") (eq (char-after) ?\n)))))))

(defun abap-line-is-continuation-p ()
  "Return non-nil if the current line is a continuation of the
previous statement: the nearest preceding non-empty, non-comment line
does not end with a statement-terminating period."
  (save-excursion
    (let ((cont nil) (done nil))
      (forward-line -1)
      (while (not done)
        (back-to-indentation)
        (cond
          ((abap-is-empty-line)
           (if (bobp)
               (progn (setq done t) (setq cont nil))
             (forward-line -1)))
          ((abap-is-comment-line)
           (if (bobp)
               (progn (setq done t) (setq cont nil))
             (forward-line -1)))
          ((abap-line-ends-statement-p)
           (setq done t) (setq cont nil))
          (t
           (setq done t) (setq cont t))))
      cont)))

(defun abap-statement-start-indent ()
  "Return the indentation column of the first line of the current
statement.  Assumes the current line is a continuation line."
  (save-excursion
    (let ((indent 0) (done nil))
      (forward-line -1)                 ; begin at the line above current
      (while (not done)
        (if (bobp)
            (progn
              (back-to-indentation)
              (cond
                ((or (abap-is-empty-line) (abap-is-comment-line))
                 (setq indent 0) (setq done t))
                ((abap-line-ends-statement-p)
                 (forward-line 1)
                 (while (and (not (eobp))
                             (or (abap-is-empty-line) (abap-is-comment-line)))
                   (forward-line 1))
                 (back-to-indentation)
                 (setq indent (current-indentation))
                 (setq done t))
                (t
                 (setq indent (current-indentation))
                 (setq done t))))
          (back-to-indentation)
          (cond
            ((abap-is-empty-line)
             (forward-line -1))
            ((abap-is-comment-line)
             (forward-line -1))
            ((abap-line-ends-statement-p)
             (forward-line 1)
             (while (and (not (eobp))
                         (or (abap-is-empty-line) (abap-is-comment-line)))
               (forward-line 1))
             (back-to-indentation)
             (setq indent (current-indentation))
             (setq done t))
            (t (forward-line -1)))))
      indent)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTES
;; - A statement that spans several lines is detected by the absence
;;   of a statement-terminating period on the previous line.
;; - Continuation lines that start with a keyword (e.g. the FROM /
;;   WHERE / INTO clauses of a SELECT, or EXPORTING of a CALL) align
;;   with the first keyword of the statement; continuation lines that
;;   start with an operand are indented by one level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun abap-indent-line ()
  "Indent ABAP Line"
  (interactive)
  (beginning-of-line)
  ; first line is always not indented
  (if (bobp)
      (indent-line-to 0)
    ; else
    (let ((not-indented t) cur-indent)
      (back-to-indentation)
      ; look for closing keywords or visibility attributes
      (if (or (looking-at (regexp-opt abap--keywords-close 'words))
              (looking-at (regexp-opt '("PUBLIC SECTION" "PROTECTED SECTION" "PRIVATE SECTION") 'words)))
          (progn
            (save-excursion
              (forward-line -1)
              (while (abap-is-empty-line)
                (forward-line -1))
              (back-to-indentation)
              (if (looking-at (regexp-opt abap--keywords-open 'words))
                  (setq cur-indent (current-indentation))
                (setq cur-indent (- (current-indentation) abap-indent-level)))) ; end save-excursion
            (if (< cur-indent 0) ; we can't indent past the left margin
                (setq cur-indent 0))) ; end progn
        ; else: is this a continuation line?
        (if (abap-line-is-continuation-p)
            (let ((start-indent (abap-statement-start-indent)))
              (if (looking-at abap--indent-align-keywords-regexp)
                  (setq cur-indent start-indent)            ; keyword-led clause -> align
                (setq cur-indent (+ start-indent abap-indent-level)))) ; operand -> indent
          ; else: a new statement -> original backward scan
          (save-excursion
            (while not-indented ; iterate backwards until we find an indentation hint
              (forward-line -1)
              (back-to-indentation)
              ; look whether previous line starts with an opening keyword
              (if (looking-at (regexp-opt abap--keywords-open 'words))
                  (progn
                    (setq cur-indent (+ (current-indentation) abap-indent-level))
                    (setq not-indented nil))
                ; otherwise look whether line is non-empty and does not contain any visibility attributes
                (if (and (not (abap-is-empty-line))
                         (not (looking-at (regexp-opt '("PUBLIC SECTION" "PROTECTED SECTION" "PRIVATE SECTION") 'words))))
                    (progn
                      (setq cur-indent (if (abap-line-is-continuation-p)
                                          (abap-statement-start-indent)
                                        (current-indentation)))
                      (setq not-indented nil))
                  ; break if we are at the first line
                  (if (bobp)
                      (setq not-indented nil))))))))
      (if cur-indent
          (indent-line-to cur-indent)
        ; if we didn't see an indentation hint
        (indent-line-to 0))))) ; end of let and if (bobp)


(provide 'abap-indention)
;;; abap-indention.el ends here
