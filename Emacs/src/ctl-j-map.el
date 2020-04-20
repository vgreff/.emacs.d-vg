;;
;;  Control L Keymap (for those *special* functions)
;;

;;  Additions to this map should be installed in alpha key order in
;;  the "Populate keys" block below.  If the function is general-purpose,
;;  it should be included below.  If not (lisp-hackers tb, etc.) it should
;;  be loaded at startup since this map always is.
 
;;  Make the map:
(defvar ctl-j-map (make-keymap)
  "Extra keymap for control-j prefix.  Special functions are here.")

(fset 'ctl-j-prefix ctl-j-map)

;;  Populate the keys:
(define-key global-map "\^j" 'ctl-j-prefix)
;;(define-key c-mode-map "\^j" 'ctl-j-prefix)
(define-key lisp-mode-map "\^j" 'ctl-j-prefix)
(define-key ctl-j-map "\^i" 'insert-sccs-id)
(define-key ctl-j-map "\^l" 'recenter)	;; provides redraw-screen
(define-key ctl-j-map "\M-!" 'recenter)	;; provides redraw-screen
(define-key ctl-j-map "\^j" 'newline-and-indent)
(define-key ctl-j-map "\^m" 'match-paren)
(define-key ctl-j-map "\^p"  'insert-parentheses)
(define-key ctl-j-map "\^r"  'redraw-display)
(define-key ctl-j-map "C" 'c++-mode)
(define-key ctl-j-map "H" 'hexl-mode)
(define-key ctl-j-map "a" 'add-position-stack)
(define-key ctl-j-map "b" 'shell)
;;(define-key ctl-j-map "c" 'c-mode)
(define-key ctl-j-map "c" 'compile-run)
(define-key ctl-j-map "d" 'delete-current-from-stack)
(define-key ctl-j-map "^d" 'toggle-debug-on-error)
;;(define-key ctl-j-map "e" 'print-buffer)
(define-key ctl-j-map "e" 'next-error)
;;(define-key ctl-j-map "f" 'fundamental-mode)
(define-key ctl-j-map "f" 'goto-friend-buffer)
(define-key ctl-j-map "g" 'grep)
(define-key ctl-j-map "h" 'help-for-control-j-map)
(define-key ctl-j-map "i" 'indented-text-mode)
(define-key ctl-j-map "k" 'save-kill-this-buffer)
;;(define-key ctl-j-map "l" 'emacs-lisp-mode)
(define-key ctl-j-map "l" 'list-stack)
;;(define-key ctl-j-map "m" 'compile)
(define-key ctl-j-map "n" 'tags-move-next)
(define-key ctl-j-map "o" 'occur)
(define-key ctl-j-map "p" 'perl-mode)
(define-key ctl-j-map "r" 'tags-move-reset)
(define-key ctl-j-map "s" 'insert-stamp)
(define-key ctl-j-map "u" 'set-current-selective)
;;(define-key ctl-j-map "v" 'set-variable)
(define-key ctl-j-map "v" 'tags-move-previous)
(define-key ctl-j-map "x" 'save-and-compile)
(define-key ctl-j-map "y" 'add-file-header)
(define-key ctl-j-map "z" 'toggle-case-fold-search)


(defun insert-sccs-id ( )
  "Insert the ever famous SCCS ID: %W%<TAB>%E%<SPACE>%U%"
  (interactive)
  (insert comment-start " SCCS ID: %W%	%E% %U%\n"))

(defun save-and-compile ( )
"Save the current buffer and compile it"
  (interactive)
  (save-buffer)
  (compile compile-command))

(defun toggle-case-fold-search()
  "Toggles the case-fold-search variable."
  (interactive)
  (setq case-fold-search (not case-fold-search))
  (message "case-fold-search is %s" case-fold-search))

(defun toggle-debug-on-error ()
  "Toggles the debug-on-error variable."
  (interactive)
  (setq debug-on-error (not debug-on-error))
  (message "debug-on-error is %s" debug-on-error))

(defun toggle-debug-on-entry (cmd)
  "Toggles the debug-on-entry state for FUNCTION."
  (interactive "aToggle debug on function? ")
  (cond ((get (quote cmd) 'dbg)
	 (progn
	   (cancel-debug-on-entry cmd)
	   (put (quote cmd) 'dbg nil)
	   (message "debug-on-entry disabled for %s" cmd)))
	(t
	 (progn
	   (debug-on-entry cmd)
	   (put (quote cmd) 'dbg t)
	   (message "debug-on-entry enabled for %s" cmd)))))


(defun help-for-control-j-map ()
  "Help for the control-j-map."
  (interactive)
  (save-excursion
    (save-window-excursion
      (with-output-to-temp-buffer "*Help*"
	(princ "Current ctl-j functions are:\n")
	(princ (substitute-command-keys "\
\\{ctl-j-map}")))
      (Helper-help-scroller))))

(require 'helper)

(defun save-kill-this-buffer ()
  "Saves the current buffer and then kills it."
  (interactive)
; Save the buffer if it is not read only and if there is a file name for it
 (cond ((and (not buffer-read-only) (buffer-file-name)) (save-buffer)))
  (kill-buffer (current-buffer)))

(defun set-current-selective (pre)
  "Make the current column the set-selective-display value.  As 
long as the buffer has a set-selective-display in effect, no writes
are permitted.  Writes are restored on exit with prefix arg set."
  (interactive "P")
  (cond ((null pre)
	 (setq buffer-read-only t)
	 (set-selective-display (current-column)))
	(t 
	 (setq buffer-read-only nil)
	 (set-selective-display 0))))

;; taken from match-paren.el. Author: unknown
(defun match-paren ()
  "Jumps to the paren matching the one under point, if there is one."
  (interactive)
  (cond ((looking-at "[\(\[{]")
	 (forward-sexp 1)
	 (backward-char))
	((looking-at "[])}]")
	 (forward-char)
	 (backward-sexp 1))
	(t (message "Could not find matching paren."))))
