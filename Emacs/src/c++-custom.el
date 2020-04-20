
;(setq c-basic-offset 2)
;
;(setq c-tab-always-indent 1)
;(define-key c-mode-map "\^M" 'reindent-then-newline-and-indent)
;(define-key c++-mode-map "\^M" 'reindent-then-newline-and-indent)

;(setq comment-column 56)


;;**************************************************************************
;; buffer switching

(defun goto-friend-buffer ()
"switches between .cc or .C and .h or .H buffers"
  (interactive)
  (let ((filename-orig (file-name-nondirectory (buffer-file-name)))
	(filename (file-name-nondirectory (buffer-file-name)))
	(friend-files-alist '(("\\.\\(cc\\|cxx\\|CXX\\|cpp\\|C\\|c\\)" "../include/" ".h" ".H")
			      ("\\.[Hh]"                   "../src/"     ".cc" ".cxx" ".CXX" ".cpp" ".bpp" ".c" ".C")))
	(other-suffixes nil)
	(other-dir nil)
	(suffix nil)
	(root nil))
    (while (and (not other-suffixes) friend-files-alist)
      (if (string-match (car (car friend-files-alist)) filename)
	  (setq suffix (substring filename (match-beginning 0))
		root (substring filename 0 (match-beginning 0))
		other-dir (car (cdr (car friend-files-alist)))
		other-suffixes (cdr (cdr (car friend-files-alist)))))
      (setq friend-files-alist (cdr friend-files-alist)))
    (cond (other-suffixes
	   (let ((found nil))
	     (while (and (not found) other-suffixes)
	       (setq filename (concat root (car other-suffixes)))
	       (cond ((file-readable-p filename)
		      (setq found t))
		     ((file-readable-p (concat other-dir filename))
		      (setq filename  (concat other-dir filename)
			    found t)))
	       (setq other-suffixes (cdr other-suffixes)))
	     (find-file filename)
	     (message "%s -> %s" filename-orig filename)))
	  (t
	   (error "%s not a C++ file" filename)))))



;;**************************************************************************

(defun add-debug-code ( )
  "Add code for debugging"
  (interactive)
  (beginning-of-line)
  (let ((beg (point)))
    (insert "#ifdef DEBUG //================================================================================\n")
    (beginning-of-line)
    (insert "#endif //--------------------------------------------------------------------------------------\n")
    (indent-region beg (point) nil)
    (forward-line -2)
    (c-indent-command)))

;;(define-key c-mode-map "\C-cd" 'add-debug-code)

;;**************************************************************************

(defun create-get-set_functions()
  "Generate get set functions to the current buffer. Uses the perl script createGetSetFunctions.pl"
  (interactive)
  (let ((cmd "createGetSetFunctions.pl "))
    (shell-command-on-region (mark t) (point) cmd t )))

;;**************************************************************************

(defun create-get-set_functions-under()
  "Generate get set functions to the current buffer. Uses the perl script createGetSetFunctions.pl"
  (interactive)
  (let ((cmd "createGetSetFunctions_.pl "))
    (shell-command-on-region (mark t) (point) cmd t )))

;;**************************************************************************

(defun create-get-set_functions-underscore()
  "Generate get set functions to the current buffer. Uses the perl script create_get_set_functions.pl"
  (interactive)
  (let ((cmd "create_get_set_functions.pl "))
    (shell-command-on-region (mark t) (point) cmd t )))

;;**************************************************************************

(defun create-db-functions()
  "Generate database functions to the current buffer. Uses the perl script createFromDb.pl"
  (interactive)
  (let ((cmd "createFromDb.pl "))
    (shell-command-on-region (mark t) (point) cmd t )))


;;**************************************************************************

(defun create-trans-functions()
  "Translates DbRow syntax to regular syntax to the current buffer. Uses the perl script trans.pl"
  (interactive)
  (let ((cmd "trans.pl "))
    (shell-command-on-region (mark t) (point) cmd t )))

(global-set-key [SunF36] 'create-trans-functions) ;; sun F11

;;**************************************************************************

(defun create-snippets()
  "Generate get set functions to the current buffer. Uses the perl script createGetSetFunctions.pl"
  (interactive)
  (let ((cmd "addSnippet "))
    (shell-command-on-region (mark t) (point) cmd t )))

;;**************************************************************************

(global-set-key "\C-ce" 'create-snippets)
(global-set-key "\C-cu" 'create-get-set_functions-underscore)
(global-set-key "\C-cf" 'create-get-set_functions)
(global-set-key "\C-c_" 'create-get-set_functions-under)
(global-set-key "\C-cb" 'create-db-functions)
(define-key c++-mode-map "\C-cf" 'create-get-set_functions)

;;**************************************************************************

(provide 'c++-custom)
