;; (c-add-style "helios-style" '('ellemtel
;;                                 (c-basic-offset . 3)
;;                                 (c-offsets-alist
;;                                  (class-open . 0)
;;                                  (class-close . 0)
;;                                  (defun-open . 0)
;;                                  (defun-close . 0)
;;                                  (namespace-open . 0)
;;                                  (namespace-close . 0)
;;                                  (innamespace . 3)
;;                                  (substatement-open . 0)
;;                                  (case-label . 3)
;;                                  (inline-open . 0)
;;                                  (inclass . 6)
;;                                  )
;;                                 (indent-tabs-mode . nil)
;;                                 ) )

;;   (c-add-style "helios-struct-style" '('helios-style
;;                                        (c-offsets-alist
;;                                         (inclass . 3)
;;                                         )
;;                                        ) )
(c-add-style "jump-style" '('ellemtel
                                (c-basic-offset . 2)
                                (c-offsets-alist
                                 (class-open . 0)
                                 (class-close . 0)
                                 (defun-open . 0)
                                 (defun-close . 0)
                                 (namespace-open . 0)
                                 (namespace-close . 0)
                                 (innamespace . 0)
                                 (substatement-open . 0)
                                 (case-label . 2)
                                 (inline-open . 0)
                                 (inclass . 4)
                                 )
                                (indent-tabs-mode . nil)
                                ) )

  ;; (c-add-style "xr-style" '('ellemtel
  ;;                               (c-basic-offset . 4)
  ;;                               (c-offsets-alist
  ;;                                (class-open . 0)
  ;;                                (class-close . 0)
  ;;                                (defun-open . 0)
  ;;                                (defun-close . 0)
  ;;                                (namespace-open . 0)
  ;;                                (namespace-close . 0)
  ;;                                (innamespace . 0)
  ;;                                (substatement-open . 0)
  ;;                                (case-label . 4)
  ;;                                (inline-open . 0)
  ;;                                (inclass . 4)
  ;;                                )
  ;;                               (indent-tabs-mode . nil)
  ;;                               ) )

  (c-set-offset 'access-label '-)
  ;(c-set-style "helios-style")
  ;(c-set-style "jump-style")
  ;(c-set-style "xr-style")

;;  (local-set-key "\C-c\C-s"
;;       (lambda () (interactive) (c-set-style "helios-struct-style")))
;;  (local-set-key "\C-c\C-r"
;;        (lambda () (interactive) (c-set-style "helios-style")))

;; (defun c++-set-indents()
;;   (interactive)
;;   (c-set-style "Stroustrup")
;;   (setq c-hanging-braces-alist '((brace-list-close nil)
;; 				 (brace-list-intro nil)
;; 				 (brace-list-entry nil)))
;;   ;(c-set-offset 'arglist-cont '+)
;; )

;; (defun c++-theo-set-indents()
;;   (interactive)
;;   (c-set-style "GNU")
;;   (setq c-hanging-braces-alist '((brace-list-close nil)
;; 				 (brace-list-intro nil)
;; 				 (brace-list-entry nil)))
;;   (setq c-basic-offset 8)
;;   (c-set-offset 'block-open 0)
;;   (c-set-offset 'defun-open 0)
;;   (c-set-offset 'defun-block-intro 8)
;;   (c-set-offset 'defun-close 0)
;;   (c-set-offset 'statement-block-intro 0)
;;   (c-set-offset 'arglist-cont 0))


;; (c++-set-indents)

;; (add-hook 'c-mode-common-hook
;; 	  '(lambda( )
;; 	     (c++-set-indents)))

(define-key c++-mode-map [menu-bar c save-and-compile-c++-file]
  '("Compile" . c++-save-and-compile))
(define-key c++-mode-map [menu-bar c ff-find-other-file]
  '("Find friend file" . ff-find-other-file))
(define-key c++-mode-map [menu-bar c c++-add-file-header]
  '("Add file header" . c++-add-file-header))
(define-key c++-mode-map [menu-bar c c++-ifout-region]
  '("#if out region" . c++-ifout-region))

(defvar c++-debug-ifdef "#ifndef NDEBUG"
  "Preprocessor directive indicating following code is for debugging purposes")

(defun c++-save-and-compile( )
  (interactive)
  (save-buffer)
  (compile (if (boundp 'compile-command) compile-command "make -k")))

(defun c++-ifdef-region(start end &optional ifdef)
  "Puts #ifndef NDEBUG/#endif around region"
  (interactive "r")
  (if (> start end)
      (let ((temp start))
        (setq start end
              end temp)))
  (save-excursion
    (goto-char end)
    (cond ((= (current-column) 0)
	   (insert "#endif\n"))
	  (t
	   (end-of-line)
	   (insert "\n#endif")))
    (goto-char start)
    (beginning-of-line)
    (or ifdef (setq ifdef c++-debug-ifdef))
    (insert ifdef "\n")))


(defun c++-add-debug-code (&optional arg)
  "Add code for debugging"
  (interactive "P")
  (if arg
      (c++-ifdef-region (region-beginning) (region-end))
    (progn
      ; Make the current line a region and ifdef it
      (beginning-of-line)
      (let ((start (point)))
	    (forward-line 1)
	    (c++-ifdef-region start (point))
	    (forward-line -1)
	    ; Indent the line
	    (c-indent-command)))))


(defun c++-ifout-region (start end)
  "Surround region with #if 0/#endif pair"
  (interactive "r")
  (c++-ifdef-region start end "#if 0"))

(defun c++-add-file-header ()
  "Adds a typical file header to the current buffer. Uses the perl script addHdr."
  (interactive)
  (beginning-of-buffer)
  (let ((cmd "addHdr "))
    (if comment-start
        (setq cmd (concat cmd "-c \"" comment-start " " comment-end "\" ")))
    (shell-command (concat cmd (buffer-file-name)) t )
    (if (featurep 'hilit19)
        (hilit-rehighlight-buffer-quietly))))

(require 'find-file)

; probably should be in user's .emacs file
(local-set-key "^Cd" 'c++-add-debug-code)
(local-set-key "^Cr" 'c++-ifout-region)
;; (local-set-key "f" 'ff-find-other-file)
;; (local-set-key "^Ch" 'c++-add-file-header)

;(global-set-key "\C-cf" 'ff-find-other-file)
;(global-set-key "\C-ch" 'c++-add-file-header)

;(if (featurep 'hilit19)
;    (progn
;      ;;; Fix the hilit compilation regular expression
;      (hilit-set-mode-patterns
;       'compilation-mode
;       '(("^[-_./\"A-Za-z0-9]+\\(:\\|, line \\)[0-9]+: [Ww]arning[ :].*$" nil warning)
;	 ("^[-_./\"A-Za-z0-9]+\\(:\\|, line \\)[0-9]+: Note[ :].*$" nil note)
;	 ("^[-_./\"A-Za-z0-9]+\\(:\\|, line \\)[0-9]+:.*$" nil error)))
;      (hilit-translate note 'blue-italic)
;      ;;; And rehilite compilation buffer when compilation finishes
;      (setq compilation-finish-function
;      '(lambda(buffer msg)
;	 (let ((oldbuf (current-buffer)))
;	   (save-excursion
;	     (set-buffer buffer)
;	     (hilit-rehighlight-buffer-quietly))
;	   (set-buffer oldbuf))))))

(provide 'c++-goodies)



