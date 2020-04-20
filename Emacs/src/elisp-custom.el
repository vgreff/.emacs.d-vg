;;
;; Emacs-Lisp mode customizations
;;


(defun byte-compile-this-file ()
  "Byte-compiles the file in the current buffer"
  (interactive)
  (if (buffer-modified-p (current-buffer))
      (if (y-or-n-p
           (concat "Save buffer "
                   (buffer-file-name)
                   "  "))
          (save-buffer (buffer-file-name))))
  (byte-compile-file (buffer-file-name)))

(defun load-this-file ()
  "load the file in the current buffer"
  (interactive)
  (if (buffer-modified-p (current-buffer))
      (if (y-or-n-p
           (concat "Save buffer "
                   (buffer-file-name)
                   "  "))
          (save-buffer (buffer-file-name))))
  (load-file (buffer-file-name)))

(local-set-key "" 'newline-and-indent)
;(local-set-key "\M-\C-c" 'byte-compile-this-file)
;(local-set-key "\M-\C-f" 'load-this-file)
(local-set-key "\C-x\M-c" 'byte-compile-this-file)
(local-set-key "\C-x\M-f" 'load-this-file)

(provide 'elisp-installed) 
