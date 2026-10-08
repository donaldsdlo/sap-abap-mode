;;; abap-mode.el --- ABAP Major Mode    -*- lexical-binding: t; -*-

;; Copyright (C) 2020-  Marian Piatkowski
;; Copyright (C) 2018  Marvin Qian

;; Author: Marian Piatkowski <marianpiatkowski@web.de>
;; Author: Marvin Qian <qianmarv@gmail.com>
;; Keywords: SAP ABAP Mode, Emacs

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
;; Major mode for SAP ABAP Language (ABAP = Advanced Business Application Programing)
;;==============================================================================
;; Special Thanks
;;
;; This program is developed on the basis of abap-mode developed by:
;;   hugo-dc (https://github.com/hugo-dc/abap-mode)
;;
;; And is inspired by:
;;   Vincent.Zhang <vincent.zhang@sap.com>
;;==============================================================================

;;; Code:

;; define keywords
;; ABAP keywords
;; Refer to the ABAP Keyword Documentation (latest, ABAP for Cloud Development):
;; https://help.sap.com/docs/abap-cloud/abap-keyword/abap-keyword-documentation?locale=en-US
(require 'abap-indention)
(defvar abap-mode-hook nil)

(setq abap-keywords
      '(
        ;; Introductory Statements for Programs
        "CLASS-POOL"
        "FUNCTION-POOL"
        "INTERFACE-POOL"
        "PROGRAM"
        "REPORT"
        "TYPE-POOL"
        "LINE-SIZE"

        ;; Modularization Statements
        ;;; Procedures
        "FUNCTION" "ENDFUNCTION"
        "METHOD" "ENDMETHOD"
        ;;; Dialog Modules
        "MODULE" "ENDMODULE"
        ;;; Event Blocks
        "AT LINE-SELECTION"
        "AT USER-COMMAND"
        "END-OF-PAGE"
        "GET"
        "LOAD-OF-PROGRAM"
        "START-OF-SELECTION"
        "TOP-OF-PAGE"
        ;;; Source Code Modules
        "DEFINE" "END-OF-DEFINITION"
        "INCLUDE"

        ;; Declarative Statement
        ;;; Data Types and Data Objects
        "CONSTANTS" "DATA" "FIELD-SYMBOLS" "INCLUDE" "NODES" "STATICS" "TABLES" "TYPES"
        ;;; Classes and Interfaces
        "ALIASES"
        "CLASS" "ENDCLASS"
        "CLASS-DATA"
        "CLASS-EVENTS"
        "CLASS-METHODS"
        "EVENTS"
        "INTERFACE"
        "ENDINTERFACE"
        "INTERFACES" "PARTIALLY IMPLEMENTED"
        "METHODS"
        "PRIVATE SECTION"
        "PROTECTED SECTION"
        "PUBLIC SECTION"
        "INHERITING FROM"
        "REDEFINITION"
        "FRIENDS"
        ;;; Object Creation
        "CREATE DATA"
        "CREATE OBJECT"
        "NEW"
        "CAST" "CONV"

        ;; Calling and Exiting Program Units
        ;;; Calling Programs
        "CALL TRANSACTION"
        "LEAVE TO TRANSACTION"
        "SUBMIT" "AND RETURN"
        ;;; Calling Processing Blocks
        "CALL CUSTOMER-FUNCTION"
        "CALL FUNCTION"
        "CALL DIALOG"
        "CALL METHOD"
        "PERFORM"
        "FORM" "ENDFORM"
        "RAISE EVENT"
        "SET HANDLER"
        "SET USER-COMMAND"
        ;;; Exiting Program Units
        "CHECK"
        "CONTINUE"
        "EXIT"
        "LEAVE PROGRAM"
        "REJECT"
        "RETURN"
        "STOP"

        ;; Program Flow Logic
        ;;; Control Structure
        "DO" "ENDDO"
        "CASE" "WHEN" "WHEN OTHERS" "ENDCASE"
        "CASE TYPE OF" "WHEN TYPE" "ENDCASE"
        "IF" "ELSEIF" "ELSE" "ENDIF"
        "WHILE" "ENDWHILE"
        "COND" "SWITCH"
        ;;; Program Interruption
        "WAIT UP TO"
        ;;; Exception Handling
        "RAISE" "RAISE EXCEPTION"
        "TRY" "CATCH" "CLEANUP" "ENDTRY"
        "RESUME"

        ;; Assignment
        ;;; Special Assignment
        "MOVE-CORRESPONDING"
        "ADD-CORRESPONDING"
        "DIVIDE-CORRESPONDING"
        "MULTIPLY-CORRESPONDING"
        "SUBTRACT-CORRESPONDING"
        "UNPACK"
        ;;; Setting References
        "ASSIGN" "ASSIGN COMPONENT" "OF STRUCTURE"
        "UNASSIGN"
        "GET REFERENCE OF" "REF" "REFERENCE INTO"
        "CORRESPONDING"
        ;;; Initizalization
        "CLEAR"
        "FREE"

        ;; Processing Internal Data
        ;;; Calculation Statements
        "ADD"
        "DIVIDE"
        "MULTIPLY"
        "SUBTRACT"
        "DIV"
        "MOD"
        ;;; Character String and Byte String Processing
        "CONDENSE"
        "CONVERT"
        "FIND"
        "FIND FIRST OCCURRENCE OF" "FIND FIRST OCCURRENCE OF SUBSTRING"  "FIND FIRST OCCURRENCE OF REGEX"
        "FIND ALL OCCURRENCES OF" "FIND ALL OCCURRENCES OF SUBSTRING" "FIND ALL OCCURRENCES OF REGEX"
        "IGNORING CASE" "RESPECTING CASE"
        "MATCH COUNT" "MATCH OFFSET" "MATCH LENGTH"
        "GET BIT"
        "OVERLAY"
        "REPLACE"
        "SET BIT"
        "SHIFT"
        "SPLIT"
        "TRANSLATE"
        "WRITE TO"
        "SEPARATED BY" "RESPECTING BLANKS"
        "IN CHARACTER MODE" "IN BYTE MODE"
        ;;; Date and Time Processing
        "CONVERT INTO TIME STAMP"
        "CONVERT TIME STAMP"
        "GET TIME"
        "GET TIME STAMP"
        ;;; Internal Tables
        "APPEND"
        "COLLECT"
        "DELETE"
        "FIND IN TABLE"
        "INSERT" "INITIAL LINE"
        "LOOP AT" "ENDLOOP"
        "LOOP AT GROUP" "ENDLOOP"
        "AT"
        "MODIFY"
        "READ TABLE"
        "REPLACE IN TABLE"
        "TABLE OF" "LINE OF" "RANGE OF"
        "SORT"
        "SUM"
        ;;; Meshes
        "SET ASSOCIATION"
        ;;; Attributes of Data Objects
        "DESCRIBE" "DESCRIBE FIELD" "DESCRIBE DISTANCE"

        ;; Processing External Data
        ;;; ABAP SQL
        "CLOSE CURSOR"
        "DELETE"
        "DELETE FROM"
        "FETCH NEXT CURSOR"
        "INSERT"
        "MODIFY"
        "OPEN CURSOR"
        "SELECT" "SELECT SINGLE"
        "FIELDS"
        "CORRESPONDING FIELDS OF"
        "ENDSELECT"
        "UPDATE" "SET"
        "UP TO"
        "LIKE"
        "CASE" "WHEN" "THEN" "ELSE" "END"
        "INNER JOIN" "LEFT OUTER JOIN" "RIGHT OUTER JOIN" "ON"
        "UNION" "UNION ALL" "UNION DISTINCT"
        "IS NULL" "NOT NULL"
        "BYPASSING BUFFER"
        "INDICATORS" "SET STRUCTURE" "NOT SET STRUCTURE"
        "INTERSECT DISTINCT" "EXCEPT DISTINCT" ;; "INTERSECT ALL" formally part of the SQL standard, but only implemented by one DB
        "EXTENDED RESULT"
        ;;; Native SQL
        "EXEC SQL" "ENDEXEC" "EXIT FROM SQL"
        ;;; ABAP and HANA
        "CALL DATABASE PROCEDURE"
        ;;; Secondary Database Connections
        "COMMIT CONNECTION"
        "ROLLBACK CONNECTION"
        ;;; Data Clusters
        "DELETE"
        "EXPORT"
        "FREE MEMORY"
        "IMPORT"
        "IMPORT DIRECTORY"
        ;;; File Interface
        "CLOSE DATASET"
        "DELETE DATASET"
        "GET DATASET"
        "OPEN DATASET"
        "READ DATASET"
        "SET DATASET"
        "TRANSFER"
        "TRUNCATE DATASET"
        ;;; Data Consistency
        "AUTHORITY-CHECK"
        "COMMIT WORK"
        "COMMIT WORK AND WAIT"
        "ROLLBACK WORK"
        "SET UPDATE TASK LOCAL"

        ;; Program Parameters
        ;;; SAP Memory
        "GET PARAMETER"
        "SET PARAMETER"
        ;;; Language Environment
        "GET LOCALE"
        "SET COUNTRY"
        "SET LANGUAGE"
        "SET LOCALE"

        ;; Program Editing
        ;;; Testing and Checking Programs
        "ASSERT"
        "BREAK-POINT"
        "LOG-POINT"
        "GET RUN TIME"
        "SET RUN TIME"
        "TEST-SEAM"
        "END-TEST-SEAM"
        "TEST-INJECTION"
        "END-TEST-INJECTION"
        ;;; Dynamic Program Development
        "GENERATE SUBROUTINE POOL"
        "INSERT REPORT"
        "GENERATE REPORT"
        "INSERT TEXTPOOL"
        "READ REPORT"
        "READ TEXTPOOL"
        "SYNTAX-CHECK"

        ;; ABAP Data and Communication Interfaces
        ;;; Remote Function Call
        "CALL FUNCTION DESTINATION"
        "RECEIVE"
        "WAIT FOR ASYNCHRONOUS TASKS"
        "WAIT FOR MESSAGING CHANNELS"
        ;;; ABAP and XML
        "CALL TRANSFORMATION"
        ;;; OLE Interface
        "CALL METHOD"
        "FREE OBJECT"
        "GET PROPERTY"
        "SET PROPERTY"

        ;; User Dialogs
        ;;; Dynpros
        "CALL SCREEN"
        "CALL SELECTION-SCREEN"
        "CONTROLS"
        "EXIT FROM STEP-LOOP"
        "GET CURSOR"
        "GET PF-STATUS"
        "LEAVE [TO]"
        "LOOP AT SCREEN" "ENDLOOP"
        "MODIFY SCREEN"
        "REFRESH CONTROL"
        "SET CURSOR"
        "SET HOLD DATA"
        "SET PF-STATUS"
        "SET SCREEN"
        "SET TITLEBAR"
        "SUPPRESS DIALOG"
        ;;; Selection Screens
        "PARAMETERS"
        "SELECTION-SCREEN"
        "SELECT-OPTIONS"
        ;;; List
        "BACK"
        "DESCRIBE LIST" "DESCRIBE TABLE"
        "FORMAT"
        "GET CURSOR"
        "HIDE"
        "LEAVE TO LIST-PROCESSING"
        "LEAVE LIST-PROCESSING"
        "MODIFY LINE"
        "NEW-LINE"
        "NEW-PAGE"
        "POSITION"
        "PRINT-CONTROL"
        "READ LINE"
        "RESERVE"
        "SCROLL LIST"
        "SET BLANK LINES"
        "SET CURSOR"
        "SET MARGIN"
        "SET PF-STATUS"
        "SET LEFT SCROLL-BOUNDARY"
        "SET TITLEBAR"
        "SKIP"
        "ULINE"
        "WINDOW"
        "WRITE"
        ;; Messages
        "MESSAGE"

        ;; Enhancements
        ;;; Source Code Enhancement
        "ENHANCEMENT" "ENDENHANCEMENT"
        "ENHANCEMENT-POINT"
        "ENHANCEMENT-SECTION" "END-ENHANCEMENT-SECTION"
        ;;; Enhancements Using BAdls
        "GET BADI"
        "CALL BADI"

        ;; Statements for Experts
        "INFOTYPES"
        "PROVIDE" "ENDPROVIDE"

        ;; EML and RAP
        "TYPE STRUCTURE FOR" "TYPE STRUCTURE FOR CREATE" "TYPE STRUCTURE FOR CHANGE"
        "TYPE TABLE FOR" "TYPE TABLE FOR CREATE" "TYPE TABLE FOR CHANGE"
        "MAPPING FROM ENTITY"

        ;; Modern ABAP Expressions (7.5x, per current ABAP Keyword Documentation)
        ;;; Table Expressions / Constructor Operators
        "REDUCE"
        "FILTER"
        "LINES OF"
        "FOR"
        "STEP"
        "EXACT"
        "RAISE SHORTDUMP"
        "SHORTDUMP"

        ;; Not Listed in Previous Section, But Somehow is Keyword
        ;; TODO Should be assembled in a regular expression form
        "FIELD-SYMBOL"
        "ASSIGNING" "CASTING"
        "MOVE" "MOVE EXACT"
        "CA" "CN" "CO" "CP" "CS" "EQ" "GE" "GT" "LE" "LT" "NA" "NE"
        "IS" "INITIAL" "BOUND" "FOUND" "INSTANCE OF"
        "AND" "OR" "NOT" "IN"
        "USING" "CHANGING"
        "VALUE" "INTO"
        "WHERE" "ORDER BY" "ASCENDING" "DESCENDING" "GROUP BY" "HAVING"
        "TYPE" "LENGTH" "REF TO" "BY"
        "IMPLEMENTATION" "DEFINITION" "DEFERRED"
        "EXPORTING" "IMPORTING" "RETURNING" "OPTIONAL" "EXCEPTIONS"
        "BEGIN OF" "END OF" "OCCURS" "BEGIN OF ENUM" "END OF ENUM" "BASE TYPE"
        "ADJACENT" "DUPLICATES" "FROM" "LINES"
        "WITH" "DEFAULT KEY" "UNIQUE KEY" "NON-UNIQUE KEY" "EMPTY KEY"
        "TRANSPORTING" "NO FIELDS"
        "STANDARD" "TABLE" "SORTED TABLE" "HASHED TABLE" "ANY TABLE" "INDEX TABLE"
        "PUBLIC" "FINAL" "ABSTRACT" "CREATE PUBLIC" "CREATE PROTECTED" "CREATE PRIVATE" "RAISING"
        "FOR TESTING"
        "RISK LEVEL HARMLESS" "RISK LEVEL DANGEROUS" "RISK LEVEL CRITICAL"
        "DURATION SHORT" "DURATION MEDIUM" "DURATION LONG"
        "MESSAGE-ID" "SHORTDUMP-ID"
        "BY KERNEL MODULE"
        )) ;; end setq abap-keywords

;; we don't need this here as case-insensitivity is treated below (define-derived-mode)
;; (setq abap-keywords (append abap-keywords-open abap-keywords-close abap-keywords))

(setq abap-types    '("C" "I" "F" "STRING" "X" "XSTRING" "N" "P" "ABAP_BOOL" "DECFLOAT16" "DECFLOAT34" "INT8" "UTCLONG" "DATN" "TIMN") )
(setq abap-constants '("SPACE" "ABAP_FALSE" "ABAP_TRUE"))
(setq abap-events    '("INITIALIZATION" "START-OF-SELECTION" "AT SELECTION-SCREEN" "END-OF-SELECTION" "VERIFICATION-MESSAGE"))
(setq abap-functions '("STRLEN" "CONCATENATE" "CONDENSE" "SPLIT" "SUBSTRING" ))

;; Generate regex string for each category
(setq abap-keywords-regexp  ( regexp-opt abap-keywords  'words))
(setq abap-type-regexp      ( regexp-opt abap-types     'words))
(setq abap-constants-regexp ( regexp-opt abap-constants 'words))
(setq abap-event-regexp     ( regexp-opt abap-events    'words))
(setq abap-functions-regexp ( regexp-opt abap-functions 'words))

;; create the list for font-lock
(setq abap-font-lock-keywords
      `(
        (,abap-constants-regexp . font-lock-constant-face)
        (,abap-event-regexp     . font-lock-builtin-face)
        (,abap-functions-regexp . font-lock-function-name-face)
        (,abap-keywords-regexp  . font-lock-keyword-face)
        (,abap-type-regexp      . font-lock-type-face)
        ;; Order above matters, in general longer words first
        ))

(defun abap-syntax-propertize-comment(start end)
  "Check whether line is a ABAP comment line and highlight it as such."
  (let ((case-fold-search nil))
    (goto-char start)
    (funcall
     (syntax-propertize-rules
      ("\\(^*.*\\)$" (0 "<")))
     start end)
    ))

;;;###autoload
(define-derived-mode abap-mode prog-mode
  "ABAP Mode"
  ;; "Major mode for the ABAP Programming Language"

  ;;; Syntax Table
  (modify-syntax-entry ?' "\"")
  ;; backticks (for string literals) as a string delimiter
  (modify-syntax-entry ?` "\"")
  (modify-syntax-entry ?_  "w")
  (modify-syntax-entry ?-  "w")
  (modify-syntax-entry ?\\ "w")
  (modify-syntax-entry ?|  "\"")
  ;; Comment Style of Starting with "
  (modify-syntax-entry ?\" "<")
  (modify-syntax-entry ?\n ">")

  ;;; Search Based
  ;; Code for syntax highlighting
  (setq-local font-lock-defaults '(abap-font-lock-keywords nil t))
  (setq-local indent-line-function 'abap-indent-line)

  ;;; Try to Hack into Syntactic Analyses
  ;;; When * Is not at the beginning of line, shouldn't be Comment
  (setq-local syntax-propertize-function 'abap-syntax-propertize-comment)

  ;; (setq-local comment-start "*")
  ;; (setq-local comment-style "plain")
  (run-hooks 'abap-mode-hook)

  )


;; clear memory
(setq abap-keywords nil)
(setq abap-types    nil)
(setq abap-constants nil)
(setq abap-events    nil)
(setq abap-functions nil)

(setq abap-keywords-regexp nil)
(setq abap-type-regexp    nil)
(setq abap-constants-regexp nil)
(setq abap-event-regexp    nil)
(setq abap-functions-regexp nil)

;; add the mode to the list
(provide 'abap-mode)

;; Local Variables:
;; coding: utf-8
;; End:
