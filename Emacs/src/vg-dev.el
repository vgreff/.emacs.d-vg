;; (require 'srefactor)
;; (require 'srefactor-lisp)
;; (semantic-mode 1) ;; -> this is optional for Lisp

;; (define-key c-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
;; (define-key c++-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
;;     (global-set-key (kbd "M-RET o") 'srefactor-lisp-one-line)
;;     (global-set-key (kbd "M-RET m") 'srefactor-lisp-format-sexp)
;;     (global-set-key (kbd "M-RET d") 'srefactor-lisp-format-defun)
;;     (global-set-key (kbd "M-RET b") 'srefactor-lisp-format-buffer)


(use-package which-key :ensure t :pin melpa
  :config
  ;; (setq which-key-show-early-on-C-h t)
  ;; ;; make sure which-key doesn't show normally but refreshes quickly after it is
  ;; ;; triggered.
  ;; (setq which-key-idle-delay 10000)
  ;; (setq which-key-(insert )dle-secondary-delay 0.05)
  (which-key-mode)
  )

(use-package xah-lookup :ensure t :pin melpa)

(defun xah-lookup-cppreference (&optional word)
  "Lookup definition of current word or text selection in URL."
  (interactive)
  (xah-lookup-word-on-internet
   word
   ;; Use word02051 as a placeholder in the query URL.
   "http://en.cppreference.com/mwiki/index.php?search=word02051"
   xah-lookup-browser-function))

(require 'cc-mode)

;; Add shortcut for c++-mode
(define-key c++-mode-map (kbd "C-c d") #'xah-lookup-cppreference)

;; Another example with http://www.boost.org
(defun xah-lookup-boost (&optional word)
  (interactive)
  (xah-lookup-word-on-internet
   word
   "https://cse.google.com/cse?cx=011577717147771266991:jigzgqluebe&q=word02051"
   xah-lookup-browser-function)
  )

(define-key c++-mode-map (kbd "C-c b") #'xah-lookup-boost)

;;; Yasnippet
(use-package yasnippet :ensure t :pin melpa
  :config ;;(yas-global-mode +1)
  (progn
    (add-hook 'prog-mode-hook #'yas-minor-mode)
    (add-hook 'text-mode-hook #'yas-minor-mode))
  )

(use-package yasnippet-snippets :ensure t :pin melpa
  :after yasnippet
  :config (yas-reload-all)
  )

(use-package company
  :config
  (setq company-idle-delay 0.3)
  (setq company-minimum-prefix-length 1)

  (global-company-mode 1)

  (global-set-key (kbd "C-<tab>") 'company-complete)
  )

(use-package lsp-mode
  :config
  (add-hook 'c++-mode-hook #'lsp)
  (add-hook 'python-mode-hook #'lsp)
  (add-hook 'rust-mode-hook #'lsp)
  (setq lsp-clients-clangd-args '("-j=4" "-background-index" "-log=error" "-completion-style=detailed"))

  (setq lsp-prefer-flymake nil) ;; Prefer using lsp-ui (flycheck) over flymake.
  ;; ..
  )


(use-package lsp-ui
  :requires lsp-mode flycheck
  :config

  (setq lsp-ui-doc-enable t
	lsp-ui-doc-header t
	lsp-ui-doc-include-signature t
        lsp-ui-doc-use-childframe t
        lsp-ui-doc-position 'top
        lsp-ui-doc-include-signature t
        lsp-ui-sideline-enable nil
        lsp-ui-flycheck-enable t
        lsp-ui-flycheck-list-position 'right
        lsp-ui-flycheck-live-reporting t
        lsp-ui-peek-enable t
        lsp-ui-peek-list-width 60
        lsp-ui-peek-peek-height 25)

  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  )


(use-package hydra)

(use-package helm)

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)

(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(helm-mode 1)

(use-package helm-lsp
  :config
  (defun netrom/helm-lsp-workspace-symbol-at-point ()
    (interactive)
    (let ((current-prefix-arg t))
      (call-interactively #'helm-lsp-workspace-symbol)))

  (defun netrom/helm-lsp-global-workspace-symbol-at-point ()
    (interactive)
    (let ((current-prefix-arg t))
      (call-interactively #'helm-lsp-global-workspace-symbol)))
  :commands helm-lsp-workspace-symbol
  )

(use-package lsp-treemacs :commands lsp-treemacs-errors-list)


(use-package lsp-mode
  :requires hydra helm helm-lsp
	     
  :config
  (setq netrom--general-lsp-hydra-heads
        '(;; Xref
          ("d" xref-find-definitions "Definitions" :column "Xref")
          ("D" xref-find-definitions-other-window "-> other win")
          ("r" xref-find-references "References")
          ("s" netrom/helm-lsp-workspace-symbol-at-point "Helm search")
          ("S" netrom/helm-lsp-global-workspace-symbol-at-point "Helm global search")

          ;; Peek
          ("C-d" lsp-ui-peek-find-definitions "Definitions" :column "Peek")
          ("C-r" lsp-ui-peek-find-references "References")
          ("C-i" lsp-ui-peek-find-implementation "Implementation")

          ;; LSP
          ("p" lsp-describe-thing-at-point "Describe at point" :column "LSP")
          ("C-a" lsp-execute-code-action "Execute code action")
          ("R" lsp-rename "Rename")
          ("t" lsp-goto-type-definition "Type definition")
          ("i" lsp-goto-implementation "Implementation")
          ("f" helm-imenu "Filter funcs/classes (Helm)")
          ("C-c" lsp-describe-session "Describe session")

          ;; Flycheck
          ("l" lsp-ui-flycheck-list "List errs/warns/notes" :column "Flycheck"))

        netrom--misc-lsp-hydra-heads
        '(;; Misc
          ("q" nil "Cancel" :column "Misc")
          ("b" pop-tag-mark "Back"))
	)


  ;; Create general hydra.
  (eval `(defhydra netrom/lsp-hydra (:color blue :hint nil)
           ,@(append
              netrom--general-lsp-hydra-heads
              netrom--misc-lsp-hydra-heads))
	)

  (add-hook 'lsp-mode-hook
            (lambda () (local-set-key (kbd "C-c C-l") 'netrom/lsp-hydra/body) ) )
  )
(define-key lsp-mode-map (kbd "<mouse-3>")  nil)
(define-key lsp-mode-map (kbd "S-<mouse-3>")  #'lsp-mouse-click)

;; (with-eval-after-load 'lsp-mode
;;   (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(use-package company-lsp
  :requires company
  :config
  (push 'company-lsp company-backends)

   ;; Disable client-side cache because the LSP server does a better job.
  (setq company-transformers nil
        company-lsp-async t
        company-lsp-cache-candidates nil)
  )


;; from gtags
(use-package company-c-headers
  ;;:init
  ;;(add-to-list 'company-backends 'company-c-headers)
  :config (add-to-list 'company-c-headers-path-system "/usr/include/c++/9/")
  )

(use-package sr-speedbar)
(global-set-key (kbd "s-s") 'sr-speedbar-toggle)

(require 'setup-editing)


;; (use-package c++-mode
;; :config
;;    (yas-minor-mode 1)
;; )

;; (require 'yasnippet)
;; (yas-reload-all)
;; (add-hook 'prog-mode-hook 'yas-minor-mode)
;;(yas-global-mode 1)

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(package-selected-packages
;;    (quote
;;     (hydra company-lsp dap-mode flycheck helm-lsp lsp-ivy lsp-mode lsp-treemacs lsp-ui zygospore yasnippet ws-butler volatile-highlights use-package undo-tree rtags-xref iedit helm-swoop helm-rtags helm-projectile helm-gtags flycheck-rtags dtrt-indent company-rtags company-c-headers comment-dwim-2 clean-aindent-mode anzu))))

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  )

(provide 'vg-dev)
