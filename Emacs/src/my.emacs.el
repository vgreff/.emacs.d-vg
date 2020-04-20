;;**************************************************************************
;;How do you debug a .emacs file?

	;  First start Emacs with the "-q" command line option.  Then, in the
	;  *scratch* buffer, type the following:
	;    (setq debug-on-error t) LFD
	;    (load-file (concat vghome "/.emacs")) LFD

	;  (Type LFD by pressing C-j.)

	;  If you have an error in your .emacs file, this will invoke the debugger
	;  when the error occurs.  If you don't know how to use the debugger do
	;  (setq stack-trace-on-error t) instead.

(use-package magit)

;;**************************************************************************
;; setup

(require 'comint)
(require 'gud)

(require 'sql)


;;**************************************************************************
;; setup
;; Tell Emacs where to file lisp files

(defvar my_path (concat vgelisphome "/Emacs/src/"))
;; prepend to path
(setq load-path (cons my_path load-path ))

(setq auto-save-default nil)

;;**************************************************************************
(defun vg-emacs-check-exit ()
  "Prevents emacs from quiting"
  (interactive)
  (when 
      ;;(not (yes-or-no-p "Do you want to QUIT Emacs?"))
      (not (y-or-n-p "Do you want to QUIT Emacs?"))
    (error "Emacs is not exiting")))

(add-hook 'kill-emacs-hook 'vg-emacs-check-exit)

;**************************************************************************
;; trailing whitespace in red
					;(setq-default show-trailing-whitespace t)

;;**************************************************************************

(require 'ipython)

;;**************************************************************************
(tool-bar-mode (quote toggle))


;;**************************************************************************

(line-number-mode t)
(column-number-mode t)

;;**************************************************************************
(load-library "paren")
(add-hook 'window-setup-hook '(lambda () (show-paren-mode t)))

;---------------------------------------------------
; Let it fontify buffers up to a 1 meg
;---------------------------------------------------
(require 'font-lock)

;; (if (fboundp 'global-font-lock-mode)
;;           (global-font-lock-mode t))
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(setq font-lock-maximum-size 1000000)


;;**************************************************************************
;; etags mode

(defun previous-file()
  (interactive)
  (next-file nil))

(defun find-tag-stack-previous()
  (interactive)
  (find-tag "" '-))

(defun find-tag-repeat-last()
  (interactive)
  (find-tag last-tag t))

(defun reset-tag-stack()
  (interactive)
  (setq tags-location-stack nil)
  (message "etags stack reseted")
  )

(load "etags-stack")
					;(require 'etags-stack "etags-stack")

;;**************************************************************************

;; Packages we need
(require 'crypt++)			; Automagically decompress files

;;**************************************************************************

(load "commands")
(load "line-num") 
(load "ctl-j-map")

;;**************************************************************************
;; Emacs lisp mode hook
(add-hook 'emacs-lisp-mode-hook
	  '(lambda ()
	     (require 'elisp-installed "elisp-custom")))

;;**************************************************************************
;; c mode stuff

(setq c-auto-newline nil)

;; Read in abbreviations
(if (not (equal window-system 'w32))
    (setq dotFileFix "/")
  (setq dotFileFix ""))

(read-abbrev-file (concat vgelisphome dotFileFix ".abbrev_defs"))
;;**************************************************************************

(add-hook 'c-mode-common-hook 
	  '(lambda( )
	     (abbrev-mode 1)
	     (require 'c++-goodies "c++-goodies")
	     (require 'c++-custom "c++-custom")
	     (require 'xcscope "xcscope")
	     (c-set-offset 'access-label '-)
	     (c-set-style "jump-style")
	     ;; 	     (setq c-basic-offset 3)
	     ;;              (setq indent-tabs-mode nil)
	     ;; 	     (c-toggle-auto-state -1)
	     ;; 	     (c-set-offset 'case-label c-basic-offset)
	     ;; 	     (c-set-offset 'block-open '-)
	     ))

(add-hook 'java-mode-hook
	  '(lambda( ) 
	     (abbrev-mode -1)
             (setq indent-tabs-mode nil)
	     (define-key java-mode-map "\^M" 'reindent-then-newline-and-indent)	     
	     (c-set-offset 'inline-open 0)))


(add-hook 'python-mode-hook 
	  '(lambda( )
	     (abbrev-mode 1)
	     ))

(add-hook 'ruby-mode-hook 
	  '(lambda( )
	     (abbrev-mode 1)
	     ))


;;**************************************************************************
;; global mode key redefinition

(put 'eval-expression 'disabled nil)

(require 'dired)
(global-set-key "\C-x\C-d" 'dired)


(global-set-key "\C-xl" 'display-line-numbers)
(global-set-key "\C-x\C-g" 'goto-line)
(global-set-key "\C-x\C-k" 'kill-rectangle)
(global-set-key "\C-x\C-y" 'yank-rectangle)
(global-set-key "\C-xt" 'indent-region)

(global-set-key "\C-x/" 'point-to-register)
(global-set-key "\C-xj" 'jump-to-register)
(global-set-key "\C-x=" 'what-cursor-position)

(global-set-key "\e(" 'backward-sexp)
(global-set-key "\e)" 'forward-sexp)
(global-set-key "\C-x\C-i" 'insert-buffer)
(global-set-key "\eg" 'goto-line)

(global-set-key  "\C-c\C-b" 'sql-buffer-scroll-right)
(global-set-key  "\C-c\C-f" 'sql-buffer-scroll-left)

;;**************************************************************************
;; Arrange for linked files to work properly

(setq backup-by-copying-when-linked t)
(setq version-control nil)		; set to t to enable numbered backups
(setq require-final-newline t)		; some C compilers require this


;;**************************************************************************
;; file extension and modes

(setq auto-mode-alist
      (append
       '(("\\.t$" . text-mode)
         ("\\.ol$" . outline-mode)
	 ("\\.lisp$" . lisp-mode)
	 (".java$" . java-mode)
         ("\\.\\([chCHi]\\|cc|cpp|\\)$" . c++-mode) 
         ("\\.cu$" . c++-mode)
         ("\\.cuh$" . c++-mode)
         ("\\.ino$" . c++-mode)
         ("\\.X$" . c++-mode)
         ("\\.idl$" . c++-mode)
	 ("\\.\\(pl\\|perl\\)$" . perl-mode)
	 ("\\.ps$" . postscript-mode)
         ("\\.1$" . nroff-mode)
         ("\\.2$" . nroff-mode)
         ("\\.3$" . nroff-mode)
         ("\\.5$" . nroff-mode)
         ("\\.8$" . nroff-mode)
         ("\\.me$" . nroff-mode)
         ("\\.mm$" . nroff-mode)
         ("\\.ms$" . nroff-mode)
         ("\\.tbl$" . sql-mode)
         ("log_sql" . sql-mode)
         ("\\.trg$" . sql-mode)
         ("\\.idx$" . sql-mode)
         ("\\.prm$" . sql-mode)
         ("\\.sql$" . sql-mode)
         ("\\.vw$" . sql-mode)
         ("\\.trg$" . sql-mode)
         ("\\.tbl$" . sql-mode)
         ("\\.idx$" . sql-mode)
         ("\\.alt$" . sql-mode)
	 ("\\.tar$" . tar-mode)
	 ("\\.\\(sh\\|ksh\\|.*profile\\)$" . ksh-mode)
	 ("\\.bison" . 'bison-mode)
	 ("\\([Mm]akefile\\|[Mm]akeinclude\\)" . makefile-mode)
	 ("\\.inc$" . makefile-mode)
	 ("\\.\\(o\\|a\\)$" . hexl-mode)
         ("\\.man$" . nroff-mode)) auto-mode-alist))

;;**************************************************************************
;; Mode hooks
(add-hook 'perl-mode-hook 
	  '(lambda( ) (define-key perl-mode-map "\^M" 'newline-and-indent) (setq indent-tabs-mode nil)))

;;**************************************************************************
;; autoload module

(autoload 'c++-mode "cc-mode" "C++ Editing mode" t)
(autoload 'c-mode "cc-mode" "C Editing mode" t)
(autoload 'java-mode "cc-mode" "Java Editing mode" t)
(autoload 'postscript-mode "postscript" "Postscript editing mode" t)
;;(autoload 'shell "newshell" "CMU shell mode" t)
(autoload 'tar-mode "tar-mode" "Emacs interface to tar files" t)
(autoload 'ksh-mode "ksh-mode" "Shell mode" t)
(autoload 'format-lisp-code-directory "lispdir" nil t)
(autoload 'lisp-dir-apropos "lispdir" nil t)
(autoload 'lisp-dir-retrieve "lispdir" nil t)
(autoload 'lisp-dir-verify "lispdir" nil t)
(autoload 'bison-mode "bison-mode" "Bison Editing Mode" t)
(autoload 'perl-mode "perl-mode" "Perl Editing Mode" t)



;;--------------------------------------------------------------
;; sql mode


(defun run-sql-mode () 
  (interactive)
  
  (find-file (concat vghome "/SQL/sql.sql"))
  (end-of-buffer)
  (sql-mode)
  ;;(sql)

  (load "completion")
  (initialize-completions)

  (sql-postgres)

  )

(add-hook 'sql-mode-hook 
	  '(lambda( )
	     (load "sql-hook-vg")
	     (abbrev-mode 1)
	     ))

;; (autoload 'master-mode "master" "Master mode minor mode." t)
;; (add-hook 'sql-mode-hook
;; 	   (function (lambda ()
;; 		       (abbrev-mode 1)
;; 		       (master-mode t)
;; 		       (master-set-slave sql-buffer))
;; 		     ))
;; (add-hook 'sql-set-sqli-hook
;; 	   (function (lambda ()
;; 		       (master-set-slave sql-buffer))))

;;--------------------------------------------------------------
;; sybase mode

;; (defvar sybase-mode-init nil "if non-nil sybase-mode has been started")

;; (defun sybase-mode () 
;;   (interactive)
;;   (if (eq sybase-mode-init nil)
;;       (progn
;; 	(server-start)
;; 	 (load "completion")
;; 	(initialize-completions)
;; 	(find-file (concat vgsqllog "/log/log_sybase"))
;; 	(setq sybase-mode-init t)
;; 	(end-of-buffer)
;; 	(split-window-vertically)
;; 	(end-of-buffer)
;; 	(message "Sybase-mode has been started"))
;;     (error "Sybase-mode already active")))

;; (defun sybase-save()
;;   (interactive)
;;   (let ((bufname (buffer-name)))
;;     (if (string-match "sql" bufname)
;; 	(progn
;; 	  (delete-other-windows)
;; 	  (end-of-buffer)
;; 	  (beginning-of-line)
;; 	  (next-line 1)
;; 	  (save-buffer)
;; 	  (copy-region-as-kill (point-min) (point-max)) 
;; 	  (find-file (concat vgsqllog "/log/log_sybase"))
;; 	  (end-of-buffer)
;; 	  (insert "--------------------------------------------------------------------")
;; 	  (next-line 1)
;; 	  (yank) 
;; 	  (end-of-buffer)
;; 	  (split-window-vertically)
;; 	  (switch-to-buffer bufname) 
;; 	  (server-edit) 
;; 	  (kill-buffer bufname) 
;; 	  (switch-to-buffer "log_sybase")
;; 	  (save-buffer)
;; 	  (message "Sybase-mode: return to shell"))
;;       (error "Sybase-mode: not an sql-edit buffer"))))


(defun add-sql-code ()
  "Add sql generic statment"
  (interactive)
  (insert (princ "select \n  from \n  where \n  group by \n  having \n"))
  (forward-line -4)
  (end-of-line))

(global-set-key "\C-cs" 'add-sql-code)

;;--------------------------------------------------------------
;; selective display mode

(defun unset-selective-display()
  (interactive)
  (set-selective-display 2))


(defun toggle-selective-display()
  (interactive)
  (if (eq selective-display nil)
      (set-selective-display 2)
    (set-selective-display nil)))

(defun toggle-sql-display()
  (interactive)
  (if (eq selective-display nil)
      (set-selective-display 2)
    (if (eq selective-display 2)
	(set-selective-display 4)
      (if (eq selective-display 4)
	  (set-selective-display nil)))))

;;--------------------------------------------------------------
					; resize window

(defun narrow-window()
  (interactive)
  (enlarge-window -1))

(defun narrow-window-horizontally()
  (interactive)
  (enlarge-window-horizontally -1))

;;--------------------------------------------------------------
;; compile mode

(defun previous-error()
  (interactive)
  (next-error -1))

(defun restart-error()
  (interactive)
  (next-error '(4)))

(setq compile-command "make -j 10")

(defun compile-run()
  (interactive)
  (compile compile-command))

;;--------------------------------------------------------------

(defun show-help-f-key()
  (interactive)
  (grep (concat "grep -n \"global-set-key \\\\[.*f[0-9]*\\\\]\" " (concat vghome "/Emacs/src/my.emacs.el")))
  (read-from-minibuffer "Type Return")
  (other-window 1)
					;  (kill-buffer (buffer-name))
  (delete-window))

;;--------------------------------------------------------------
;; window wrapping


(defun toggle-window-wrap()
  (interactive)
  (setq truncate-lines (not truncate-lines))
  (message "Emacs is %swrapping" (if truncate-lines "NOT " ""))
  (hilit-rehighlight-buffer-quietly)
  )

(defun toggle-show-trailing-whitespace()
  (interactive)
  (setq-default show-trailing-whitespace (not show-trailing-whitespace))
  (message "Emacs is %sshow-trailing-whitespace" (if truncate-lines "NOT " ""))
  (hilit-rehighlight-buffer-quietly)
  )
;;--------------------------------------------------------------

(defun ff-find-other-file_no_include()
  (interactive)
  (ff-find-other-file nil t))

;---------------------------------------------------
; Loop around buffers with F8 and F7
;---------------------------------------------------
(autoload 'last "cl")
(define-key global-map [f8] 'bury-buffer)
(define-key global-map [(f7)]
  (lambda() (interactive) (switch-to-buffer (car (last (buffer-list))))))

;;**************************************************************************

(defun set-title()
  (interactive)
  (let ((vgtitle nil))
    (setq vgtitle (read-from-minibuffer "new title="))
    (setq frame-title-format vgtitle)
    (setq icon-title-format vgtitle)))

;;**************************************************************************
;; choosing vc backend
(defun vg-choose-vc-status()
  (interactive)
  (if (magit-get-top-dir default-directory)
      (git-status (magit-get-top-dir default-directory))
    (svn-status default-directory)))

;;**************************************************************************
;; choosing vc backend
(defun vg-choose-vc-dir()
  (interactive)
  (if (magit-get-top-dir default-directory)
      (vc-dir (magit-get-top-dir default-directory))
    (vc-dir default-directory)))

;;**************************************************************************

					;(global-set-key [s-f1] 'load-marker-list)
(global-set-key [C-S-f1] 'load-marker-list)
(global-set-key [C-f1] 'run-sql-mode)
(global-set-key [S-f1] 'comment-region)
(global-set-key [f1] 'indent-region)

					;(global-set-key [S-f2] ')
					;(global-set-key [s-f2] 'save-marker-list)
					;(global-set-key [C-s-f2] 'save-marker-list)
(global-set-key [C-S-f2] 'save-marker-list)
(global-set-key [C-f2] 'save-buffer)
(global-set-key [f2] 'save-buffer)    ; F2 -> Save buffer

					;(global-set-key [s-f3] 'ff-find-other-file) 
(global-set-key [M-f3] 'ff-find-other-file_no_include)  
(global-set-key [C-S-f3] 'ff-find-other-file) ; 
					;(global-set-key [C-S-f3] 'goto-friend-buffer) ; 
(global-set-key [C-f3] 'compile) ; 
(global-set-key [S-f3] 'compile-run)
(global-set-key [f3] 'previous-error)

(global-set-key [s-f4] 'ediff-buffers)
(global-set-key [C-s-f4] 'ediff-buffers)
(global-set-key [M-f4] 'ediff-revision)
(global-set-key [C-S-f4] 'toggle-tags-go-current)
(global-set-key [C-f4] 'ediff-files)
(global-set-key [S-f4] 'restart-error)
(global-set-key [f4] 'next-error)

(global-set-key [s-M-f5] 'toggle-tags-precision)
(global-set-key [S-M-f5] 'toggle-tags-precision)
(global-set-key [s-f5] 'toggle-move-update)
(global-set-key [C-s-f5] 'toggle-move-update)
(global-set-key [M-f5] 'replace-current-from-stack)
(global-set-key [C-f5] 'insert-current-from-stack)
(global-set-key [C-S-f5] 'add-position-stack)
(global-set-key [S-f5] 'delete-current-from-stack)
(global-set-key [f5] 'tags-move-previous) ;

;(global-set-key [C-f6] 'previous-file)
(global-set-key [s-f6] 'list-stack) ;
(global-set-key [C-M-f6] 'list-stack) ;
(global-set-key [C-s-f6] 'grep) ;
(global-set-key [s-M-f6] 'occur) ;
(global-set-key [S-M-f6] 'occur) ;
(global-set-key [C-f6] 'tags-move-reset)
(global-set-key [C-S-f6] 'grep-word)
(global-set-key [S-f6] 'tags-search) ;
(global-set-key [f6] 'tags-move-next) ;

;(global-set-key [C-f7] 'next-file) ;
(global-set-key [s-f7] 'reset-tag-stack)
(global-set-key [C-s-f7] 'reset-tag-stack)
(global-set-key [M-f7] 'tags-occur) ;
(global-set-key [C-f7] 'visit-tags-table) ;
(global-set-key [C-S-f7] 'occur-word)
(global-set-key [S-f7] 'tags-query-replace) ;
;(global-set-key [f7] 'tags-loop-continue) ;

;(global-set-key [C-f8] '(lambda() (interactive) (find-tag last-tag '-))) ;
(global-set-key [C-f8] 'find-tag) ;
(global-set-key [S-f8] 'find-tag-stack-previous)
(global-set-key [C-S-f8] 'find-next-tag)

(global-set-key [S-f9] 'start-kbd-macro) ;
(global-set-key [C-f9] 'end-kbd-macro) ;
(global-set-key [f9] 'call-last-kbd-macro) ; F9
(global-set-key [s-f9] 'name-last-kbd-macro) ;
(global-set-key [M-s-f9] 'insert-kbd-macro) ;
;(global-set-key [C-S-f9] 'toggle-tab-width) ;

;(global-set-key [s-f10] 'wrap-window) ;
;(global-set-key [C-M-f10] 'wrap-window) ;
;(global-set-key [M-f10] 'no-wrap-window) ;
;(global-set-key [C-f10] 'hscroll-mode) ;
(global-set-key [s-f10]  'split-Screen)
(global-set-key [M-f10]  'split-Screen-switch-file)
(global-set-key [S-f10]  'toggle-window-wrap)
(global-set-key [f10]  'toggle-selective-display)
(global-set-key [C-f10] 'toggle-sql-display)
;(global-set-key [S-f10] 'set-selective-display) ;
;(global-set-key [f10]  'unset-selective-display) ;

;;  F11 stuff
(global-set-key [M-f11] 'repeat-complex-command) ;
(global-set-key [s-f11] 'vg-choose-vc-dir) ;
(global-set-key [f11] 'magit-status) ;
(global-set-key [M-s-f11] 'vg-choose-vc-status)
(global-set-key [C-f11] 'set-title) ;

;; F12 stuff
(global-set-key [S-f12]  'toggle-show-trailing-whitespace);
(global-set-key [C-f12]  'reread-all-file);
(global-set-key [C-S-f12]  'reread-all-file-force);
(global-set-key [s-f12]  'rewrite-all-file);
(global-set-key [f12]  'toggle-case-sensitive);
;;(global-set-key [f12]  'repeat-complex-command); again key

;; (global-set-key [C-SunF37]  'reread-all-file);
;; (global-set-key [SunF37]  'toggle-case-sensitive);

;; (cond ( (equal window-system win32)
;; 	(global-set-key [C-f12]  'reread-all-file);
;; 	(global-set-key [f12]  'toggle-case-sensitive);
;; 	(global-set-key [S-f12]  'start-explorer); again key
;; 	(global-set-key [M-f12]  'start-zsh); again key
;; 	(global-set-key [C-M-f12]  'start-cmd); again key
;; 	(global-set-key [C-f11]  'start-msdev)
;; 	))

(global-set-key [S-home]  'beginning-of-buffer) ; S-home
(global-set-key [S-end]  'end-of-buffer)       ; S-end

;; (global-set-key [S-help]  'show-help-f-key)

;;(global-set-key [S-down-mouse-2]	'yank-menu)
;;(global-set-key [S-down-mouse-3]	'facemenu-menu)


;;(global-set-key [C-down-mouse-1]	'mouse-buffer-menu)
;;(global-set-key [C-down-mouse-2]	'mouse-set-font)

;;**************************************************************************
(global-set-key "\C-cw" 'grep-word)

(defun grep-word ()
  (interactive)
  (grep (concat "grep -n " (extract-word) " *.[CHh]")))

(defun occur-word ()
  (interactive)
  (occur (extract-word)))

;;**************************************************************************
(defmacro inc (var)
  (list 'setq var (list '1+ var)))

(defmacro for (var from init to final do &rest body)
  "Execute a simple \"for\" loop, e.g.,
         (for i from 1 to 10 do (print i))."
  (list 'let (list (list var init))
	(cons 'while (cons (list '<= var final)
			   (append body (list (list 'inc var)))))))

;;**************************************************************************

(defun dired-do-find-file-all-marked()
  (interactive)
  (mapcar 'find-file (dired-get-marked-files)))

(defun dired-do-print-file-all-marked()
  (interactive)
  (mapcar 'print-file (dired-get-marked-files)))

(defun mark-c-files()
  (interactive)
  (dired-mark-files-regexp "^Makefile$\\|\\(\\.\\(cc\\|h\\|c\\)$\\)"))

(defun mark-extension(ext)
  (interactive "sMark (extension) ")
  (dired-mark-files-regexp (concat "\\." ext "$")))

(define-key dired-mode-map "F" 'dired-do-find-file-all-marked)
(define-key dired-mode-map "P" 'dired-do-print-file-all-marked)
(define-key dired-mode-map "y" 'mark-extension)
(define-key dired-mode-map "z" 'mark-c-files)
(define-key dired-mode-map "\C-m" 'dired-mark)
(define-key dired-mode-map "U" 'dired-unmark-all-files-no-query)

(setq dired-deletion-confirmer 'y-or-n-p)


;;**************************************************************************
;; autocomplete in minibuffer

;; (require 'icomplete)

;;**************************************************************************
;; tags-occur mode

;; (require 'tags-occur)

;;**************************************************************************
;; horizontal scroll mode

(require 'hscroll)

;;**************************************************************************
;; mode for editing dos files without ^M

(require 'dos-mode)

;;**************************************************************************
;; emacs diff package

(autoload 'ediff-buffers "ediff" "Visual interface to diff" t)
(autoload 'ediff  "ediff"  "Visual interface to diff" t)
(autoload 'ediff-files "ediff" "Visual interface to diff" t)
(autoload 'epatch  "ediff"  "Visual interface to patch" t)
(autoload 'ediff-patch-file "ediff" "Visual interface to patch" t)
(autoload 'ediff-patch-buffer "ediff" "Visual interface to patch" t)
(autoload 'epatch-buffer "ediff" "Visual interface to patch" t)
(autoload 'vc-ediff "ediff"
  "Interface to diff & version control via vc.el" t) 
(autoload 'rcs-ediff "ediff"
  "Interface to diff & version control via rcs.el" t)

;;**************************************************************************

(defun toggle-case-sensitive()
  (interactive)
  (setq case-fold-search (not case-fold-search))
  (message "Buffer is %scase sensitive" (if case-fold-search "NOT " ""))
  )

;;**************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; FIND-FILE automatically find file for you
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 	"$JVTROOT/*" 
; 	"$JETROOT/*" 
(setq cc-search-directories
      '("."                          ; always look in . first
	".."
	"$SNAPROOT/xr-common/src"
 	"$SNAPROOT/xr-snap/src/xr/snap"
	"$SNAPSTATICROOT/*/include"
	"$SNAPSTATICROOT/*/*/*/include"
	"$SNAPSTATICROOT/*/*/*/include"
	"$SNAPSTATICROOT/"
	"/usr/local/gcc-4.9.1/include/c++/4.9.1"
	"/usr/include" 
	"/usr/include/*" 
	"/usr/local/include/*"       ; for system .h files
	"../*"
	"../../*"
	"../../*/*/*"
	))

;;(setq ff-always-in-other-window t)   ; cleaner
(require 'find-file)
(setq cc-other-file-alist
  '(
    ("\\.cc$"  (".hh" ".h"))
    ("\\.hh$"  (".cc" ".C"))
    ("\\.cuh$"  (".cu"))
    ("\\.cu$"  (".cuh" ".h"))

    ("\\INLINES.C$"   (".H" ))
    ("\\.C$"   ("INLINES.C" ".i" ".H"  ".hh" ".h"))
    ("\\.H$"   (".C" "INLINES.C" ".i" ".CC" ".CXX" ".cpp"))

    ;; ("\\INLINES.C$"   (".C" ".H" ))
    ;; ("\\.C$"   (".i" ".H"  ".hh" ".h"))
    ;; ("\\.H$"   ("INLINES.C" ".C" ".i" ".CC" ".CXX" ".cpp"))

    ("\\.c$"   (".h" ".hpp"))
    ("\\.h$"   (".cpp" ".bpp" ".i" ".c" ".cc" ".C" ".CC" ".cxx" ".CXX" ".cuh"))
    ("\\.hxx$"   (".cpp" ".i" ".c" ".cc" ".C" ".CC" ".cxx" ".CXX" ".cuh"))

    ("\\.i$"   (".H" ".hh" ".h" ".hpp"))

    ("\\.CC$"  (".HH" ".H"  ".hh" ".h"))
    ("\\.HH$"  (".CC"))
    ("\\.hpp$"  (".cpp" ".bpp" ".c"))

    ("\\.CXX$" (".H" ".h"))
    ("\\.cxx$" (".hxx" ".hh" ".h"))
    ("\\.cpp$" (".i" ".hh" ".h" ".H" ".hpp"))
    ("\\.bpp$" (".i" ".hh" ".h" ".H" ".hpp"))
    ))

(define-key global-map "\C-co" 'ff-find-other-file)




;;**************************************************************************
;; garbage collection minimum

(setq gc-cons-threshold 2000000)

;;**************************************************************************

(defun my-compile-end(buffer message)
  (beep)
  )

(setq compilation-finish-function 'my-compile-end)
(setq compilation-scroll-output t)

;;**************************************************************************
;; Emacs's imenu
;;**************************************************************************

(setq imenu-sort-function 'imenu--sort-by-name)
(setq imenu-use-keymap-menu t)
(setq imenu-max-items vgmenu-max-items)

(global-set-key [S-C-mouse-1]	'imenu)
;;(global-set-key [S-down-mouse-3]	'facemenu-menu)
;(add-hook 'c-mode-common-hook '(lambda () (imenu-add-to-menubar "Imenu")))

;;**************************************************************************
;; buffer menu splitting
;;**************************************************************************

(defun split-list(inlist)
  (let ((maxfiles vgmenu-max-items)
	(filesremain (length inlist))
	(nbfiles (length inlist))
	(nblist 0)
	(numlist 0)
	(result nil)
	(num 0)
	(highfiles 0)
	(param nil)
	(pres nil))
    (setq nblist (+ (/ filesremain maxfiles) 1))
    (if (> (length inlist) 0)
	(cons "Buffer Menu"
	      (progn (while (< numlist nblist)
		       (setq highfiles (+ num maxfiles))
		       (if (> highfiles nbfiles) (setq highfiles nbfiles))
		       (if (< num highfiles) (setq result (cons (cons (concat "Select Marker-" (number-to-string (+ numlist 1)))
								      (progn (while (< num highfiles)
									       (setq pres (cons (nth (- nbfiles (+ num 1)) inlist) pres))
									       (setq num (+ num 1)) 
									       )
									     (reverse pres)
									     )
								      ) result)))
		       (setq pres nil)
		       (setq numlist (+ numlist 1))
		       )
		     (reverse result)))
      nil)))


(defun mouse-buffer-menu (event)
  "Pop up a menu of buffers for selection with the mouse.
This switches buffers in the window that you clicked on,
and selects that window."
  (interactive "e")
  (mouse-minibuffer-check event)
  (let ((menu
	 (split-list (reverse
		      (cdr (car (cdr
				 (list "Buffer Menu"
				       (cons "Select Buffer"
					     (let ((tail (buffer-list))
						   (maxbuf 0)
						   head)
					       (while tail
						 (or (eq ?\ (aref (buffer-name (car tail)) 0))
						     (setq maxbuf
							   (max maxbuf
								(length (buffer-name (car tail))))))
						 (setq tail (cdr tail)))
					       (setq tail (buffer-list))
					       (while tail
						 (let ((elt (car tail)))
						   (if (not (string-match "^ "
									  (buffer-name elt)))
						       (setq head
							     (cons
							      (cons
							       (format
								(format "%%%ds  %%s%%s  %%s" maxbuf)
								(buffer-name elt)
								(if (buffer-modified-p elt) "*" " ")
								(save-excursion
								  (set-buffer elt)
								  (if buffer-read-only "%" " "))
								(or (if (buffer-file-name elt) (file-name-directory (buffer-file-name elt)))
								    (save-excursion
								      (set-buffer elt)
								      (if list-buffers-directory
									  (concat (if (buffer-file-name elt) "" "[")
										  (expand-file-name list-buffers-directory)
										  (if (buffer-file-name elt) "" "]"))
									))
								    ""))
							       elt)
							      head))))
						 (setq tail (cdr tail)))
					       (reverse head)))) ))))) ))
    (let ((buf (x-popup-menu event menu))
	  (window (posn-window (event-start event))))
      (if buf
	  (progn
	    (or (framep window) (select-window window))
	    (switch-to-buffer buf))))))

;;**************************************************************************
;; gud stuff
;;**************************************************************************

(defun my-gud-refresh()
  (interactive)
  (let ((result nil)
	(text nil))
    (setq start (marker-position (point-marker)))
    (gud-basic-call "")
    (gud-basic-call "line")
    (gud-basic-call "file")
    (sleep-for 1)
    (goto-char start)
    (replace-regexp comint-prompt-regexp "")
    (goto-char start)
    (replace-regexp "\n" " ")
    (setq text (buffer-substring start (marker-position (point-max-marker))))
    (gud-basic-call "")
    (setq result (list (string-to-number text) (substring text (+ (string-match " " text) 1) -1)))
    (gud-display-line (car (cdr result)) (car result))
    result
    ))

(defun my-gud-hook()
  (define-key (current-local-map) "\C-c\C-f" 'my-gud-refresh)
)
(add-hook 'gud-mode-hook 'my-gud-hook)

;;**************************************************************************

(defun reread-all-file-force()
  (interactive)
  (mapcar (function reread-file-force) (buffer-list))
  (message "All files reloaded (Forced)"))



(defun reread-file-force(buf)
  (if (buffer-file-name buf)
      (save-excursion
	(set-buffer buf)
	(if (file-exists-p (buffer-file-name buf))
	    (revert-buffer t t)
	  (message (format "File '%s' NOT FOUND" (buffer-file-name buf)))))))

(defun reread-all-file()
  (interactive)
  (mapcar (function reread-file) (buffer-list))
  (message "All files reloaded"))


(defun reread-file(buf)
  (if (buffer-file-name buf)
      (save-excursion
	(set-buffer buf)
	(if (file-exists-p (buffer-file-name buf))
	    (if (or (not (verify-visited-file-modtime buf))
		    (eq (file-writable-p (buffer-file-name buf)) buffer-read-only))
		(revert-buffer t t))
	  (message (format "File '%s' NOT FOUND" (buffer-file-name buf)))))))

(defun rewrite-all-file()
  (interactive)
  (mapcar (function rewrite-file) (buffer-list))
  (message "All files written"))



(defun rewrite-file(buf)
  (if (buffer-file-name buf)
      (save-excursion
	(set-buffer buf)
	(if (file-exists-p (buffer-file-name buf))
	    (write-file (buffer-file-name buf) nil)
	  (message (format "File '%s' NOT FOUND" (buffer-file-name buf)))))))


;;**************************************************************************

(defun edit-src()
  "edit $SRCSUN environment variable"
  (interactive)
  (setenv "SRCSUN" (read-from-minibuffer "$SRCSUN=" (getenv "SRCSUN")))
  (message (format "Now: $SRCSUN=%s" (getenv "SRCSUN"))))

;; ;;**************************************************************************

(global-set-key "\C-xq" 'vc-toggle-read-only)
(global-set-key "\C-xve" 'edit-src)


;;(global-set-key "\C-xf" 'find-file-binary)


;;**************************************************************************

;scroll one line at a time
(setq scroll-step 1)

;(setq-default transient-mark-mode t)


(add-hook 'comint-output-filter-functions 'shell-strip-ctrl-m nil t)

;;-------------------------------------------------
;; When a key is pressed and a block is hilited,
;; the selection is replaced by the key pressed
;;-------------------------------------------------
(delete-selection-mode t)

     
;---------------------------------------------------
; Don't show the startup message
;---------------------------------------------------
(setq inhibit-startup-message t)

;;--------------------------------------------------
; Use spaces instead of tabs for indentation
;---------------------------------------------------
(setq indent-tabs-mode nil)

;---------------------------------------------------
; Change the directory of where temp files are
; stored.
;---------------------------------------------------
(defun make-backup-file-name (file)
  (concat vghome (concat "/emacs-bak/" (file-name-nondirectory file)))
 )

(setq make-backup-files nil)
;---------------------------------------------------

;;**************************************************************************
(defun emerge-saveA ()
  (interactive)
  (write-file (emerge-eval-in-buffer emerge-A-buffer buffer-file-name)) t)

(defun my-emerge-startup-hook ()
  (interactive)
  (local-set-key "S" 'emerge-saveA))
(my-emerge-startup-hook)


(add-hook  'emerge-startup-hook  'my-emerge-startup-hook)

;;**************************************************************************
;; csv-mode mode stuff

(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
(add-to-list 'auto-mode-alist '("\\.[Tt][Aa][Bb]\\'" . csv-mode))
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)

;;**************************************************************************

(require 'vg-dev)


