;;;;;;;;;;;;;;;;;;;;;;;;;;; -*- Mode: Emacs-Lisp -*- ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @(#)ksh-mode.el 1.22: sh (ksh, bash) script editing mode for GNU Emacs.
;; Copyright (C) 1992 Gary Ellison.
;; ksh-mode.el --  
;; Author: Gary F. Ellison <Gary_F_Ellison@ATT.COM>
;;                   AT&T Bell Laboratories
;;                   6200 East Broad Street
;;                   Columbus, Ohio 43213 USA
;;
;; Maintainer: Gary F. Ellison <Gary_F_Ellison@ATT.COM>
;; Created: Fri Jun 19
;; Version: 1.22
;; Keywords: shell, korn, bourne, sh, ksh, bash
;;
;; Delta On        : 3/29/93
;; Last Modified By: Dave Brennan
;; Last Modified On: Thu Apr  8 12:49:32 1993
;; Update Count    : 12
;; Status          : Highly Functional
;;
;; HISTORY 
;; 29-Mar-1993		Gary Ellison	
;;    Last Modified: Tue Sep 29 16:14:02 1992 #10 (Gary Ellison)
;;    Integrate line continuation patch supplied by
;;    Haavard Rue <hrue@imf.unit.no>
;;    Name back to ksh-mode to avoid confusion with sh-mode
;;    by Thomas W. Strong, Jr. <strong+@cmu.edu>.
;;
;; 29-Sep-1992		Gary Ellison	
;;    Last Modified: Wed Sep  2 08:51:40 1992 #9 (Gary Ellison)
;;    Full support of ksh88 case items. 
;;    Align statements under "do" and "then" keywords one position 
;;    past the keyword.
;;
;; 2-Sep-1992		Gary Ellison	
;;    Last Modified: Tue Aug  4 14:34:35 1992 #8 (Gary Ellison)
;;    Use make-variable-buffer-local instead of make-local-variable
;;    Get rid of superflous ksh-default variables.
;;    Use end of word match \b for "then", "do", "else", "elif"
;;    Support process substitution lists and exclude ksh 88 case items
;;    Use default-tab-width for indentation defaults.
;;    Moved installation instructions to the mode level documentation 
;;    section.
;;    Fixed auto-mode-alist documentation.
;;
;; 24-Jul-1992		Gary Ellison	
;;    Last Modified: Fri Jul 24 09:45:11 1992 #7 (Gary Ellison)
;;    Modified ksh-indent-region to use marker versus fixed end point.
;;    comment-start-skip regexp no longer fooled by parameter substitution.
;;    Added constant ksh-mode-version.
;;
;; 21-Jul-1992		Gary Ellison	
;;    Last Modified: Tue Jul 21 15:53:57 1992 #6 (Gary Ellison)
;;    Indent with tabs instead of spaces.
;;    Can handle just about all styles.
;;    Anti-newline in REs.
;;    Word delim "\b" in REs
;;    More syntax entries.
;;    Variables with regexp suffix abbreviated to re
;;    Better } handling
;;    Implemented minimal indent-region-function
;;    Mode documentation corrected.
;;    Minor lisp source format changes.
;;    
;; 29-Jun-1992		Gary Ellison	
;;    Last Modified: Mon Jun 29 15:39:35 1992 #5 (Gary Ellison)
;;    Optimize line-to-string
;;    Implicit/Explicit functions aok
;;    More indentation variables
;;    Superfluous defun killed.
;;    renamed to sh-mode
;;    
;; 22-Jun-1992          Gary Ellison
;;    Last Modified: Mon Jun 22 15:01:14 1992 #4 (Gary Ellison)
;;    Cleanup pre att.emacs posting
;;
;; 19-Jun-1992          Gary Ellison
;;    Last Modified: Fri Jun 19 17:19:14 1992 #3 (Gary Ellison)
;;    Minimal case indent handling
;;
;; 19-Jun-1992          Gary Ellison
;;    Last Modified: Fri Jun 19 16:23:26 1992 #2 (Gary Ellison)
;;    Nesting handled except for case statement
;;
;; 19-Jun-1992          Gary Ellison
;;    Last Modified: Fri Jun 19 10:03:07 1992 #1 (Gary Ellison)
;;    Conception of this mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This file is compatible with GNU Emacs but is not part of the official
;; distribution.
;;
;; This program is free software; you can redistribute it and/or modify
;; it at your option.
;;   
;; Gary Ellison makes no representations about the suitability
;; of this software for any purpose.  It is provided "as is" without
;; express or implied warranty.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;;   
;; LCD Archive Entry:
;; ksh-mode|Gary F. Ellison|Gary_F_Ellison@ATT.COM|
;; Mode for editing sh/ksh/bash scripts|
;; 29-Mar-1993|1.22|~/modes/ksh-mode.el.Z|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Description:
;;   sh, ksh, and bash script editing commands for emacs.
;; 
;; Installation:
;;   Put ksh-mode.el in some directory in your load-path.
;;   Refer to the installation section of ksh-mode's function definition.
;;
;; Usage:
;;   This major mode assists shell script writers with indentation
;;   control and control structure construct matching in much the same
;;   fashion as other programming language modes. Invoke describe-mode
;;   for more information.
;; 
;; Bugs:
;;   Function ending brace "}" must be on a separate line for indent-line
;;   to do the right thing.
;;
;;   Explicit function definition matching will proclaim in the minibuffer
;;   "No matching compound command" followed by "Matched ... "
;;
;;   indent-for-comment fails to recognize a comment starting in column 0,
;;   hence it moves the comment-start in comment-column.
;;
;;========================================================================

(defconst ksh-mode-version "1.22"
  "*Version numbers of this version of ksh-mode")
;;
;; Context/indentation regular expressions
;; 
;; indenting expressions
;;
(defconst ksh-then-do-re     "^[^#'`\"\n]*\\b\\(then\\|do\\)\\b"
  "*Regexp used to locate grouping keywords: \"then\" and \"do\"" )

(defconst ksh-do-re          "^[ \t]*\\bdo\\(\\b\\|$\\)"
  "*Regexp used to match keyword: do")

(defconst ksh-then-re        "^[ \t]*\\bthen\\(\\b\\|$\\)"
  "*Regexp used to match keyword: then")

;;
;; Structure starting/indenting keywords
;;
(defconst ksh-else-re           "^[ \t]*\\belse\\(\\b\\|$\\)"
  "*Regexp used to match keyword: else")

(defconst ksh-elif-re           "^[ \t]*\\belif\\(\\b\\|$\\)"
  "*Regexp used to match keyword: elif")

(defconst ksh-brace-re           "^[^#\n]*{[ \t\n]"
  "*Regexp used to match syntactic entity: { ")

(defconst ksh-case-item-end-re           "^[^#\n]*;;[ \t\n]"
  "*Regexp used to match case item end syntactic entity: ;;")

(defconst ksh-keywords-re
  "^[^#'`\"\n]*\\b\\(else\\|if\\|elif\\|case\\|while\\|for\\|until\\|select\\)\\b"
  "*Regexp used to detect compound command keywords: if, else, elif case, 
while, for, until, and select")

(defconst ksh-if-re         "^[^#'`\"\n]*\\b\\(if\\)\\b"
  "*Regexp used to match keyword: if")

(defconst ksh-wufs-re 
  "^[^#'`\"\n]*\\b\\(while\\|for\\|until\\|select\\)\\b"
  "*Match one of the keywords: while, until, for, select")

(defconst ksh-case-re           "^[^#'`\"\n]*\\b\\(case\\)\\b"
  "*Regexp used to match keyword: case")

(defconst ksh-explicit-func-re
  "^[ \t]*\\(function[ \t][a-zA-z_][a-zA-Z0-1]*\\)\\b"
  "*Match an explicit function definition: function name")

(defconst ksh-implicit-func-re
  "^[ \t]*\\([a-zA-z_][a-zA-Z0-1_]*\\)[ \t]*()[ \t]*"
  "*Match an implicit function definition: name ()")

(defconst ksh-func-brace-re "^[ \t]*\\(.*{\\)[ \t\n]+"
  "*Match a implicit function definition brace: name { ")

;;
;; indenting 
(defconst ksh-case-item-re           "^[^#`'\"\n]*\\()\\)"
  "*Regexp used to match case-items including ksh88")

(defconst ksh-paren-re           "^[^#`'\"\n]*)[ \t\n]+"
  "*Regexp used to match compound list & case items")

;;
;; structure ending keyword regular expressions
(defconst ksh-fi-re            "^[ \t]*fi\\b"
  "*Regexp used to match keyword: fi")

(defconst ksh-esac-re          "^[ \t]*esac\\b"
  "*Regexp used to match keyword: esac")

(defconst ksh-done-re          "^[ \t]*done\\b"
  "*Regexp used to match keyword: done")

(defconst ksh-brace-end-re  "^[ \t]*}[ \t]*"
  "*Regexp used to match function brace-groups")

;;
;; Variables controlling indentation style
;;
(defvar ksh-indent default-tab-width)
(defvar ksh-case-item-indent default-tab-width)
(defvar ksh-case-indent nil)
(defvar ksh-group-indent (- 0 default-tab-width))
(defvar ksh-brace-indent 0)
(defvar ksh-match-and-tell t)

;;
;; Create mode specific tables
(defvar ksh-mode-syntax-table nil
  "Syntax table used while in sh mode.")
(if ksh-mode-syntax-table
    ()
  (setq ksh-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\' "\"" ksh-mode-syntax-table)
  (modify-syntax-entry ?` "\"" ksh-mode-syntax-table)
  (modify-syntax-entry ?\n ">   " ksh-mode-syntax-table)
  (modify-syntax-entry ?\f ">   " ksh-mode-syntax-table)
  (modify-syntax-entry ?# "<   " ksh-mode-syntax-table)
  (modify-syntax-entry ?_ "w" ksh-mode-syntax-table)
  (modify-syntax-entry ?< "." ksh-mode-syntax-table)
  (modify-syntax-entry ?> "." ksh-mode-syntax-table)
  (modify-syntax-entry ?& "." ksh-mode-syntax-table)
  (modify-syntax-entry ?| "." ksh-mode-syntax-table)
  (modify-syntax-entry ?$ "." ksh-mode-syntax-table)
  (modify-syntax-entry ?% "." ksh-mode-syntax-table)
  (modify-syntax-entry ?= "." ksh-mode-syntax-table)
  (modify-syntax-entry ?/ "." ksh-mode-syntax-table)
  (modify-syntax-entry ?+ "." ksh-mode-syntax-table)
  (modify-syntax-entry ?* "." ksh-mode-syntax-table)
  (modify-syntax-entry ?- "." ksh-mode-syntax-table)
  (modify-syntax-entry ?; "." ksh-mode-syntax-table)
  )

(defvar ksh-mode-abbrev-table nil
  "Abbrev table used while in sh mode.")
(define-abbrev-table 'ksh-mode-abbrev-table ())

(defvar ksh-mode-map nil 
  "Keymap used in sh mode")

(if ksh-mode-map
    ()
  (setq ksh-mode-map (make-sparse-keymap))
  (define-key ksh-mode-map "\C-i"    'ksh-indent-line)
  (define-key ksh-mode-map "\177"    'backward-delete-char-untabify)
  (define-key ksh-mode-map "\C-j"    'reindent-then-newline-and-indent)
  )


(defun ksh-mode ()
  "Major mode for editing (Bourne, Korn or Bourne again) shell scripts.
Special key bindings and commands:
\\{ksh-mode-map}
Variables controlling indentation style:
ksh-indent
    Additional indentation of the first statement under keyword.
    Default value is 8.
ksh-case-indent
    Additional indentation for statements under case items.
    Default value is nil which will align the statements one position 
    past the \")\" of the pattern.
ksh-case-item-indent
    Additional indentation for case items within a case statement.
    Default value is 8.
ksh-group-indent
    Additional indentation for keywords \"do\" and \"then\".
    Default value is -8.
ksh-brace-indent
    Indentation of { under a function definition.
    Default value is 0.
ksh-match-and-tell
    If non-nil echo in the minibuffer the matching compound command
    for the \"done\", \"}\", \"fi\", or \"esac\". Default value is t.

Style Guide.
 By setting
    (setq ksh-indent default-tab-width)
    (setq ksh-group-indent 0)

    The following style is obtained:

    if [ -z $foo ]
        then bar        <-- ksh-group-indent is additive to ksh-indent
             foo
    fi

 By setting
    (setq ksh-indent default-tab-width)
    (setq ksh-group-indent (- 0 ksh-indent))

    The following style is obtained:

    if [ -z $foo ]
    then bar
         foo
    fi

 By setting
    (setq ksh-case-item-indent 1)
    (setq ksh-case-indent nil)

    The following style is obtained:

    case x in *
     foo) bar           <-- ksh-case-item-indent
          baz;;         <-- ksh-case-indent aligns with \")\"
     foobar) foo
             bar;;
    esac

 By setting
    (setq ksh-case-item-indent 1)
    (setq ksh-case-indent 6)

    The following style is obtained:

    case x in *
     foo) bar           <-- ksh-case-item-indent
           baz;;        <-- ksh-case-indent
     foobar) foo
           bar;;
    esac
    

Installation:
  Put ksh-mode.el in some directory in your load-path.
  Put the following forms in your .emacs file.

 (autoload 'ksh-mode \"ksh-mode\" \"Major mode for editing sh Scripts.\" t)

 (setq auto-mode-alist
      (append auto-mode-alist
	      (list
	       '(\"\\\\.sh$\" . ksh-mode)
	       '(\"\\\\.ksh$\" . ksh-mode)
               '(\"\\\\.bashrc\" . ksh-mode)
               '(\"\\\\..*profile\" . ksh-mode))))

 (setq ksh-mode-hook
      (function (lambda ()
         (setq ksh-indent 8)
	 (setq ksh-group-indent -8))
	 (setq ksh-brace-indent 0)   
         (setq ksh-match-and-tell t)
	 )))

"
  (interactive)
  (kill-all-local-variables)
  (use-local-map ksh-mode-map)
  (setq major-mode 'ksh-mode)
  (setq mode-name "Ksh")
  (setq local-abbrev-table ksh-mode-abbrev-table)
  (set-syntax-table ksh-mode-syntax-table)
  (make-variable-buffer-local 'ksh-indent)
  (make-variable-buffer-local 'ksh-case-item-indent)
  (make-variable-buffer-local 'ksh-case-indent)
  (make-variable-buffer-local 'ksh-group-indent)
  (make-variable-buffer-local 'ksh-brace-indent)
  (make-variable-buffer-local 'ksh-match-and-tell)
  (make-variable-buffer-local 'indent-line-function)
  (setq indent-line-function 'ksh-indent-line)
  (make-variable-buffer-local 'indent-region-function)
  (setq indent-region-function 'ksh-indent-region)
  (make-variable-buffer-local 'comment-start)
  (setq comment-start "# ")
  (make-variable-buffer-local 'comment-end)
  (setq comment-end "")
  (make-variable-buffer-local 'comment-column)
  (setq comment-column 32)
  (make-variable-buffer-local 'comment-start-skip)
  (setq comment-start-skip "#+ *")
  (run-hooks 'ksh-mode-hook)
  ) ;; defun

;;
;; Support functions

(defun ksh-indentation-on-this-line ()
  "Return current indentation level (no. of columns) that this line is
indented"
  (save-excursion
    (back-to-indentation)
    (current-column))
  ) ;; defun

(defun ksh-current-line ()
  "Return the vertical position of point in the buffer.
Top line is 1."
  (+ (count-lines (point-min) (point))
     (if (= (current-column) 0) 1 0))
  )


(defun ksh-line-to-string ()
  "From point, construct a string from all characters on
current line"
  (skip-chars-forward " \t") ;; skip tabs as well as spaces
  (buffer-substring (point)
                    (progn
                      (end-of-line 1)
                      (point))))

(defun ksh-get-nest-level ()
  "Return a 2 element list (nest-level nest-line) describing where the
current line should nest."
  (let (
    	(level)
	(anchor (point))
    	);; bind
    (save-excursion
      (forward-line -1)
      (while (and (not (bobp))
		  (null level))
	(if (and (not (looking-at "^[ \t]*$"))
;;; Rue
 		 (not (save-excursion
 			(forward-line -1)
 			(beginning-of-line)
 			(looking-at "^.*\\\\$")))
;;; Rue
		 (not (looking-at "^[ \t]*#")))
	    (setq level (cons (ksh-indentation-on-this-line) 
			      (ksh-current-line)))
	  (forward-line -1)
	  );; if
	);; while
      (if (null level)
	  (cons (ksh-indentation-on-this-line) (ksh-current-line))
	level)
      )
    )
  )

(defun ksh-looking-at-compound-list ()
  "Return true if current line contains an indenting keyword"
  (or 
   (looking-at ksh-do-re)
   (looking-at ksh-then-re)
   ) ;; or
  ) ;; defun

(defun ksh-looking-at-case-item ()
  "Return true if current line is a case-item .vs. paren compound list"
  (save-excursion
    (beginning-of-line)
    ;;
    ;; Handle paren indentation constructs for this line
    (cond ((looking-at ksh-paren-re)
	   (goto-line (cdr (ksh-get-nest-level)))
	   ;;
	   ;; The question is whether this is really a case item or just
	   ;; parenthesized compound list.
	   (cond ((or (looking-at ksh-case-re)
		      (looking-at ksh-case-item-end-re)))
		 ;;
		 ;; turns out to be a parenthesized compound list
		 ;; so propigate the nil for cond
		 )
	   ))
    )
  ) ;; defun

(defun ksh-get-case-indent ()
  "Return the column of the closest open case statement"
  (save-excursion
    (let (
	  (nest-list (ksh-get-compound-level ksh-case-re ksh-esac-re (point)))
	  )
      (if (null nest-list)
	  (progn 
	    (if ksh-match-and-tell
		(message "No matching case for ;;"))
	    0)
	(car nest-list)))
    )
  )

;;
;; Functions which make this mode what it is
;;

(defun ksh-get-nester-column (nest-line)
  "Return the column to indent to with respect to nest-line taking 
into consideration keywords and other nesting constructs."
  (save-excursion 
    (let (
	  (this-line (ksh-current-line))
	  )
      ;;
      ;; Handle case item indentation constructs for this-line
      (cond ((ksh-looking-at-case-item)
	     (goto-line nest-line)
	     (let (
		   (fence-post (save-excursion (end-of-line) (point)))
		   )
	       ;;
	       ;; Now know there is a case-item so detect whether
	       ;; it is first under case, just another case-item, or
	       ;; a case-item and case-item-end all rolled together.
	       ;;
	       (cond ((re-search-forward ksh-case-re fence-post t)
		      (goto-char (match-beginning 1))
		      (+ (current-column) ksh-case-item-indent))

		     ((ksh-looking-at-case-item)
		      (ksh-indentation-on-this-line))

		     ((looking-at ksh-case-item-end-re)
		      (end-of-line)
		      (+ (ksh-get-case-indent) ksh-case-item-indent))
		     )
	       ))
	    (t				
	     ;;
	     ;; this-line is not a case-item. So figure out what to do
	     ;; relative to the nest-line.
	     (goto-line nest-line)
	     (let* (
		    (fence-post (save-excursion (end-of-line) (point)))
		    (nester-column
		     (cond
		      ;; In order to locate the column of the keyword,
		      ;; which might be embedded within a case-item,
		      ;; it is necessary to use re-search-forward.
		      ((re-search-forward ksh-keywords-re fence-post t)
		       (goto-char (match-beginning 1))
		       (if (looking-at ksh-case-re)
			   (+ (current-column) ksh-case-item-indent)
			 (+ (current-column) ksh-indent)))

		      ((re-search-forward ksh-then-do-re fence-post t)
		       (goto-char (match-end 1))
		       (+ (current-column) 1))

		      ((looking-at ksh-brace-re)
		       (+ (ksh-indentation-on-this-line) ksh-indent))
		      ;;
		      ;; Forces functions to first column
		      ((or (looking-at ksh-implicit-func-re)
			   (looking-at ksh-explicit-func-re))
		       (if (looking-at ksh-func-brace-re)
			   ksh-indent
			 ksh-brace-indent))

		      ;;
		      ;; Need to first detect the end of a case-item
		      ((looking-at ksh-case-item-end-re)
		       (end-of-line)
		       (+ (ksh-get-case-indent) ksh-case-item-indent))
		      ;;
		      ;; Now detect first statement under a case item
		      ((ksh-looking-at-case-item)
		       (if (null ksh-case-indent)
			   (progn
			     (re-search-forward ksh-case-item-re fence-post t)
			     (goto-char (match-end 1))
			     (+ (current-column) 1))
			 (+ (ksh-indentation-on-this-line) ksh-case-indent)))

		      ;;
		      (t (ksh-indentation-on-this-line)))
		     ))
	       (goto-line this-line)
	       ;;
	       ;; Handle additional indentation constructs for this line
	       (cond ((ksh-looking-at-compound-list)
		      (+ nester-column ksh-group-indent))
		     (t nester-column))
	       )))
      )
    );; excursion
  );; defun


(defun ksh-indent-line ()
  "Indent current line as far as it should go according
to the syntax/context"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (bobp)
        nil
      ;;
      ;; Align this line to current nesting level
      (let*
          (
	   (level-list (ksh-get-nest-level))     ; Where to nest against
           (last-line-level (car level-list))
           (this-line-level (ksh-indentation-on-this-line))
           (level-diff (- this-line-level last-line-level))
           )
	(if (not (zerop level-diff))
	    (progn
	      (indent-to last-line-level)
	      (let ((beg (point)))
		(back-to-indentation)
		(delete-region beg (point)))
	      )
	  ) ;; if
	;;
	;; At this point this line is aligned with last line
	;; So given context of last line indent or leave alone
        (let
            (
             (nester-column (ksh-get-nester-column (cdr level-list)))
	     )
	  (beginning-of-line)
	  (indent-to nester-column)
	  (let ((beg (point)))
	    (back-to-indentation)
	    (delete-region beg (point)))
          ) ;; let
	;;
	;; Now unindent if need be
	(ksh-match-structure-and-reindent) ;; match structures and reindent
        ) ;; let*
      ) ;; if
    ) ;; excursion
  ;;
  ;; Position point on this line
  (let*
      (
       (this-line-level (ksh-indentation-on-this-line))
       (this-bol (save-excursion
                   (beginning-of-line)
                   (point)))
       (this-point (- (point) this-bol))
       )
    (cond ((> this-line-level this-point) ;; point in initial white space
           (back-to-indentation))
           (t nil)
           ) ;; cond
    ) ;; let*
  ) ;; defun


(defun ksh-match-structure-and-reindent ()
  "If the current line matches one of the indenting keywords
or one of the control structure ending keywords then reindent. Also
if ksh-match-and-tell is non-nil the matching structure will echo in
the minibuffer"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (cond ((looking-at ksh-else-re)
	   (ksh-match-indent-level ksh-if-re ksh-fi-re))
	  ((looking-at ksh-elif-re)
	   (ksh-match-indent-level ksh-if-re ksh-fi-re))
	  ((looking-at ksh-fi-re)
	   (ksh-match-indent-level ksh-if-re ksh-fi-re))
	  ((looking-at ksh-done-re)
	   (ksh-match-indent-level ksh-wufs-re ksh-done-re))
	  ((looking-at ksh-esac-re)
	   (ksh-match-indent-level ksh-case-re ksh-esac-re))
	  ;;
	  ((looking-at ksh-brace-end-re)
	   (cond
	    ((ksh-match-indent-level ksh-implicit-func-re ksh-brace-end-re))
	    ((ksh-match-indent-level ksh-explicit-func-re ksh-brace-end-re))
	    ((ksh-match-indent-level ksh-func-brace-re ksh-brace-end-re))
	    (t nil)))
	  (t nil)
	  );; cond
    )
  )

(defun ksh-match-indent-level (begin-re end-re)
  "Match the compound command and indent. Return nil on no match, t otherwise"
  (interactive)
  (let* (
	 (nest-list 
	  (save-excursion
	    (ksh-get-compound-level begin-re end-re (point))
	    ))
	 ) ;; bindings
    (if (null nest-list)
	(progn 
	  (if ksh-match-and-tell
	      (message "No matching compound command"))
	  nil) ;; propagate a miss
      (progn
	(let* (
	       (nest-level (car nest-list))
	       (match-line (cdr nest-list))
	       (diff-level (- (ksh-indentation-on-this-line) nest-level))
	       ) ;; bindings
	    (if ksh-match-and-tell
		(save-excursion
		  (goto-line match-line)
		  (message (format "Matched ... %s" (ksh-line-to-string)))
		  ) ;; excursion
	      )
	  (save-excursion
	    (if (not (zerop diff-level))
		(progn
		  (beginning-of-line)
		  (indent-to nest-level)
		  (let ((beg (point)))
		    (back-to-indentation)
		    (delete-region beg (point)))
		  )
	      ) ;; if
	    ) ;; excursion
	  ) ;; let* nest-line
	t) ;; progn propagate a hit
      ) ;; if
    ) ;; let* nest-list
  ) ;; defun ksh-match-indent-level 

(defun ksh-get-compound-level 
  (begin-re end-re anchor-point &optional balance-list)
  "Determine how much to indent this structure. Return a list (level line) 
of the matching compound command or nil if no match found."
  (let* 
      (;; Locate the next compound begin keyword bounded by point-min
       (match-point (if (re-search-backward begin-re (point-min) t)
			(match-beginning 1) 0))
       (nest-column (if (zerop match-point)
			1 
		      (progn
			(goto-char match-point)
			(current-column))))
       (nest-list (cons 0 0))    ;; sentinel cons since cdr is >= 1
       )
    (if (zerop match-point)
	nil ;; graceful exit from recursion
      (progn
	(if (nlistp balance-list)
	    (setq balance-list (list)))
	;; Now search forward from matching start keyword for end keyword
	(while (and (consp nest-list) (zerop (cdr nest-list))
		    (re-search-forward end-re anchor-point t))
	  (if (not (memq (point) balance-list))
	      (progn
		(setq balance-list (cons (point) balance-list))
		(goto-char match-point)  ;; beginning of compound cmd
		(setq nest-list
		      (ksh-get-compound-level begin-re end-re
					     anchor-point balance-list))
		)))

	(cond ((consp nest-list)
	       (if (zerop (cdr nest-list))
		 (progn
		   (goto-char match-point)
		   (cons nest-column (ksh-current-line)))
		 nest-list))
	      (t nil)
	      )
	)
      )
    )
  )


(defun ksh-indent-region (start end)
  "From start to end, indent each line."
  ;;
  ;; The algorithm is just moving through the region line by line with 
  ;; the match noise turned off.
  (save-excursion
    (let ((match-and-tell ksh-match-and-tell)
	  (endmark (copy-marker end)))

      (setq ksh-match-and-tell nil)
      (goto-char start)
      (beginning-of-line)
      (setq start (point))
      (while (> (marker-position endmark) start)
	(ksh-indent-line)
	(forward-line 1)
	(setq start (point)))

      (set-marker endmark nil)
      (setq ksh-match-and-tell match-and-tell)
      )
    )
  )
