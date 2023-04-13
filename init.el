;; -----------------------------------------------------------------------------

;; (when (>= emacs-major-version 24)
;;   (require 'package)
;;   (add-to-list
;;    'package-archives
;;    '("melpa" . "http://melpa.org/packages/")
;;    t)
;;   (package-initialize))

;; next line required for emacs 26.1 due to race bug, fixed in later version 
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(require 'package)
(add-to-list 'package-archives
         '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents)
    (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------------------
;; git
;(load "/usr/share/doc/git-core/contrib/emacs/git.el")
;(load "/usr/share/doc/git-core/contrib/emacs/git-blame.el")
;(load "/usr/share/doc/git-1.8.2.1/contrib/emacs/git.el")
;(load "/usr/share/doc/git-1.8.2.1/contrib/emacs/git-blame.el")
;(load "/usr/share/doc/git-2.7.2/contrib/emacs/git.el")
;(load "/usr/share/doc/git-2.7.2/contrib/emacs/git-blame.el")

;(load "/usr/share/git-core/doc/contrib/emacs/git.el")
;(load "/usr/share/git-core/doc/contrib/emacs/git-blame.el")
					;
(add-to-list 'vc-handled-backends 'GIT)

;; -----------------------------------------------------------------------------

;;(setq stack-trace-on-error t)
;;(setq debug-on-error t)

(setq vgmenu-max-items 48)

(setq vghome (expand-file-name "~"))
;(setq vghome (expand-file-name "/free/home/vgreff"))
;(setq vghome (expand-file-name "/home/vincent.greff"))
;(setq vghome (expand-file-name "/home/vgreff"))
(setq vgelisphome (concat vghome "/.emacs.d"))
(setq vgsqllog vgelisphome)

;; -----------------------------------------------------------------------------
;; el-get

;; (add-to-list 'load-path (concat vghome "/.emacs.d/el-get/el-get"))
;; (require 'el-get)

;; (setq el-get-sources
;;       '(

;;         (:name magit
;;               ;;  :after (lambda () (global-set-key (kbd "C-x z") 'magit-status))
;; 	       )
;; ))
(load "gud.elc")

;; (el-get)
;; -----------------------------------------------------------------------------

(load (concat vgelisphome "/Emacs/src/my.emacs.el"))

(put 'narrow-to-region 'disabled nil)

(put 'narrow-to-page 'disabled nil)

(put 'downcase-region 'disabled nil)

(put 'upcase-region 'disabled nil)

(put 'eval-expression 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 90 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(compilation-info ((((class color) (min-colors 16) (background light)) (:foreground "Blue" :weight bold))))
 '(font-lock-string-face ((((class color) (background light)) (:foreground "DarkGreen")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(csv-comment-start-default "!")
 '(csv-invisibility-default t)
 '(csv-regionOK-confirm t)
 '(csv-separators '("	" ","))
 '(cvs-force-dir-tag nil)
 '(defcustom mouse-buffer-menu-mode-mult t)
 '(ediff-split-window-function 'split-window-horizontally)
 '(fringe-mode '(nil . 0) nil (fringe))
 '(indicate-buffer-boundaries 'left)
 '(mouse-buffer-menu-maxlen 35)
 '(mouse-buffer-menu-mode-mult 50)
 '(package-selected-packages '(cmake-mode magit))
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(sql-database "vgtest")
 '(sql-postgres-options '("-P" "pager=off" "-w" "--echo-queries"))
 '(sql-product 'postgres)
 '(sql-server "chihq-snapdev-105d")
 '(sql-sybase-options '("-w 4096"))
 '(sql-sybase-program "sqsh")
 '(sql-user "vgreff"))

;;(set-frame-size (selected-frame) 223 85)
;(set-frame-size (selected-frame) 272 74)
;(set-frame-size (selected-frame) 272 60)
(set-frame-size (selected-frame) 200 60)
; to get the current info
;(frame-height )
;(frame-width )

(fset 'yes-or-no-p 'y-or-n-p)

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(setq x-select-enable-primary t)
(setq x-select-enable-clipboard t)

