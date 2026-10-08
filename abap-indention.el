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

(setq abap--keywords-open '("IF" "ELSEIF" "ELSE" "LOOP" "DO" "FORM" "CASE" "CLASS" "TRY" "CATCH" "METHOD" "BEGIN OF" "SELECT" "INTERFACE" "WHILE"))

(setq abap--keywords-close '("ENDIF" "ELSEIF" "ELSE" "ENDLOOP" "ENDDO" "ENDFORM" "ENDCASE" "ENDCLASS" "ENDTRY" "CATCH" "ENDMETHOD" "END OF" "ENDSELECT" "ENDINTERFACE" "ENDWHILE"))


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTES
;; - indentation of statements over multiple lines may have to be done manually
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
    ; else
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
              (setq cur-indent (current-indentation))
              (setq not-indented nil))
            ; break if we are at the first line
            (if (bobp)
              (setq not-indented nil))))
        )))
    (if cur-indent
      (indent-line-to cur-indent)
    ; if we didn't see an indentation hint
    (indent-line-to 0)))) ; end of let and if (bobp)
  )


(provide 'abap-indention)
;;; abap-indention.el ends here
