;
; FILE: %M%
;
; VERSION: %I%
;    
; CREATED: May 27, 1994
;
; MODIFIED:     
;
; PROGRAMMER: 
;
; AUTHOR: Wellington Financial Group
;
; DESCRIPTION:
;
; Copyright %G% Wellington Financial Group. 
;
;;**************************************************************************
;(global-set-key [A-S-f5] 'toggle-tags-precision)
;(global-set-key [A-f5] 'toggle-move-update)
;(global-set-key [M-f5] 'replace-current-from-stack)
;(global-set-key [C-f5] 'insert-current-from-stack)
;(global-set-key [C-S-f5] 'add-position-stack)
;(global-set-key [S-f5] 'delete-current-from-stack)

;(global-set-key [f5] 'tags-move-previous) ;
;(global-set-key [f6] 'tags-move-next) ;

;(global-set-key [A-f6] 'list-stack) ;


(require 'etags)

(defvar tags-position-stack nil)
(defvar tags-not-moving nil)
(defvar tags-position-precise t)
(defvar tags-position-move-update t)
(defvar tags-position-index 0)
(defvar tags-position-go-current nil)
;; internals
(defvar defaultDirectory nil)
;--------------------------------------------------------------

(if (not(fboundp 'old-find-tag-noselect))
    (fset 'old-find-tag-noselect (symbol-function 'find-tag-noselect)))

(defun find-tag-noselect (tagname &optional next-p regexp-p)
  "Find tag (in current tags table) whose name contains TAGNAME.
Returns the buffer containing the tag's definition and moves its point there,
but does not select the buffer.
The default for TAGNAME is the expression in the buffer near point.

If second arg NEXT-P is t (interactively, with prefix arg), search for
another tag that matches the last tagname or regexp used.  When there are
multiple matches for a tag, more exact matches are found first.  If NEXT-P
is the atom `-' (interactively, with prefix arg that is a negative number
or just \\[negative-argument]), pop back to the previous tag gone to.

If third arg REGEXP-P is non-nil, treat TAGNAME as a regexp.

See documentation of variable `tags-file-name'."
  (interactive (find-tag-interactive "Find tag: "))
  (setq tags-not-moving nil)
  (add-position-stack)
  (old-find-tag-noselect tagname next-p regexp-p))

;--------------------------------------------------------------

(defun toggle-tags-precision()
  (interactive)
  (setq tags-position-precise (not tags-position-precise))
  (message "tags precision: %s" (if tags-position-precise "ON" "OFF")))

;--------------------------------------------------------------

(defun toggle-tags-go-current()
  (interactive)
  (setq tags-position-go-current (not tags-position-go-current))
  (message "tags go-current: %s" (if tags-position-go-current "ON" "OFF")))
;--------------------------------------------------------------

(defun toggle-move-update()
  (interactive)
  (setq tags-position-move-update (not tags-position-move-update))
  (message "tags move-update: %s" (if tags-position-move-update "ON" "OFF")))

;--------------------------------------------------------------

(defun delete-last-tag-from-stack()
  (interactive)
  (let ((last-mark (car tags-position-stack)))
    (setq tags-position-stack (cdr tags-position-stack))
    (setq tags-not-moving (- (length tags-position-stack) 1))
    (setq tags-position-index 0)
    (message "delete last mark from stack (%s)" (marker-buffer last-mark)))
  )

;--------------------------------------------------------------

(defun add-position-stack()
  (interactive)
  (progn
    (setq tags-position-stack (cons (point-marker) tags-position-stack))
    (message "added stack mark"))
)

;--------------------------------------------------------------

(defun delete-current-from-stack()
  (interactive)
  (let ((num (- (length tags-position-stack) 1))
	(tmp-stack tags-position-stack))
    (setq tags-position-stack nil)
    (while (>= num 0)
      (if (not (eq tags-position-index num))
	  (setq tags-position-stack 
		(cons (nth num  tmp-stack)  tags-position-stack))
	(message "deleted %s from stack" (marker-buffer (nth num  tmp-stack))))
      (setq num (- num 1)))
    (if (not (eq tags-position-index 0))
	(setq tags-position-index (- tags-position-index 1)))
    (let ((marker (nth tags-position-index tags-position-stack)))
      (switch-to-buffer (marker-buffer marker))
      (if tags-position-precise
	  (goto-char (marker-position marker))))))

;--------------------------------------------------------------

(defun insert-current-from-stack()
  (interactive)
  (let ((num (- (length tags-position-stack) 1))
	(tmp-stack tags-position-stack))
    (setq tags-position-stack nil)
    (while (>= num 0)
      (setq tags-position-stack 
	    (cons (nth num  tmp-stack)  tags-position-stack))
      (if (eq tags-position-index num)
	  (prog1(setq tags-position-stack 
		      (cons (point-marker) tags-position-stack))
	    (message "inserted %s into stack" (marker-buffer (point-marker)))))
      (setq num (- num 1)))))

;--------------------------------------------------------------

(defun replace-current-from-stack()
  (interactive)
  (let ((num (- (length tags-position-stack) 1))
	(tmp-stack tags-position-stack))
    (setq tags-position-stack nil)
    (while (>= num 0)
      (if (not (eq tags-position-index num))
	  (setq tags-position-stack 
		(cons (nth num  tmp-stack)  tags-position-stack))
	  (prog1(setq tags-position-stack 
		      (cons (point-marker) tags-position-stack))
	    (message "replaced %s from stack" (marker-buffer (point-marker)))))
      (setq num (- num 1)))))

;--------------------------------------------------------------

(defun check-if-marker-pending()
  (if (eq tags-not-moving nil)
      (progn
	(add-position-stack)
	(setq tags-not-moving (- (length tags-position-stack) 1))
	(setq tags-position-index 0))))


;--------------------------------------------------------------

(defun tags-move-to-current-buffer()
  (interactive)
  (switch-to-buffer (marker-buffer (nth tags-position-index tags-position-stack))))

;--------------------------------------------------------------

(defun tags-move-previous()
  (interactive)
  (if (not (eq tags-position-stack nil))
      (progn
	(check-if-marker-pending)
	(setq tags-not-moving (- (length tags-position-stack) 1))
	(if (< tags-position-index tags-not-moving)
	    (progn
	      (if tags-position-go-current (tags-move-to-current-buffer))
	      (if tags-position-move-update (replace-current-from-stack))
	      (setq tags-position-index (+ tags-position-index 1))
	      (let ((marker (nth tags-position-index tags-position-stack))
		    (old-buff (marker-buffer (nth (- tags-position-index 1) tags-position-stack))))
		(switch-to-buffer (marker-buffer marker))
		(if tags-position-precise
		    (goto-char (marker-position marker)))
		(my-recenter)
		(message "%s <- %s (previous)" (marker-buffer marker) old-buff)))
	  (error "At top of tags stack")))
    (error "stack empty (previous)")))

;--------------------------------------------------------------

(defun tags-move-next()
  (interactive)
  (if (not (eq tags-position-stack nil))
      (progn
	(if (>= tags-position-index (length tags-position-stack))
	    (setq tags-position-index 0))
	(if (> tags-position-index 0)
	    (progn
	      (if tags-position-go-current (tags-move-to-current-buffer))
	      (if tags-position-move-update (replace-current-from-stack))
	      (setq tags-position-index (- tags-position-index 1))
	      (let ((marker (nth tags-position-index tags-position-stack))
		    (old-buff (marker-buffer (nth (+ tags-position-index 1) tags-position-stack))))
		(switch-to-buffer (marker-buffer marker))
		(if tags-position-precise
		    (goto-char (marker-position marker)))
		(my-recenter)
		(message "%s -> %s (next)" old-buff  (marker-buffer marker))))
	  (error "At bottom of tags stack")))
    (error "stack empty (next)")))
    

;--------------------------------------------------------------

(defun tags-move-reset()
  (interactive)
  (setq tags-position-stack nil)
  (setq tags-position-index 0)
  (message "stack reseted")
  )

;--------------------------------------------------------------

(defun find-next-tag()
  (interactive)
  (delete-last-tag-from-stack)
  (find-tag-repeat-last))

(if (not(fboundp 'old-tags-search))
    (fset 'old-tags-search (symbol-function 'tags-search)))

(defun tags-search (regexp &optional file-list-form)
  "Search through all files listed in tags table for match for REGEXP.
Stops when a match is found.
To continue searching for next match, use command \\[tags-loop-continue].

See documentation of variable `tags-file-name'."
  (interactive (find-tag-interactive "Tags search (regexp): "))
  (old-tags-search regexp file-list-form))

;--------------------------------------------------------------

;;**************************************************************************

(defun mapcar* (f &rest args)
  "Apply FUNCTION to successive cars of all ARGS, until one ends.
          Return the list of results."
  ;; If no list is exhausted,
  (if (not (memq 'nil args))
      ;; Apply function to CARs.
      (cons (apply f (mapcar 'car args))
	    (apply 'mapcar* f
		   ;; Recurse for rest of elements.
		   (mapcar 'cdr args)))))

(defun my-print(mark position)
  (interactive)
  (if (markerp mark)
      (progn 
	(insert (concat (princ (number-to-string (line-nb mark)))
			(princ "\t")
			(princ (if (eq position 1)
				   "------> "
				 "        "))
			(princ (buffer-name (marker-buffer mark)))
			(princ "\n"))))))

(defun list-stack()
  (interactive)
  (check-if-marker-pending)
  (split-window-vertically)
  (other-window 1)
  (switch-to-buffer "*list-stack*")
  (let ((num (- (length tags-position-stack) 1))
	(param nil))
    (while (>= num 0)
	  (setq param  
		(if (not (eq tags-position-index num))
		    (cons 0 param)
		  (cons  1 param)))
	  (setq num (- num 1)))
    (insert (princ "Line\t        Buffer\n----\t        -------------------\n"))
    (mapcar* 'my-print (reverse tags-position-stack) (reverse param)))
  (read-from-minibuffer "Type Return")
  (kill-buffer (buffer-name))
  (delete-window))

(defun line-nb(mark)
  (let ((new-buff-pos (marker-position mark))
	(new-buff-name (marker-buffer mark))
	(old-buff-name (marker-buffer (point-marker)))
	(ret nil))
    (set-buffer new-buff-name)
    (setq ret (+ 1 (count-lines 1 new-buff-pos)))
    (set-buffer old-buff-name)
    ret))

;;**************************************************************************
(defun my-print-menu(mark position)
  (interactive)
  (if (markerp mark)
      (progn 
	(cons (format "%5d %s %s%s%s " 
		      (line-nb mark)
		      (if (buffer-modified-p (marker-buffer mark)) "*" 
			(save-excursion
			  (set-buffer (marker-buffer mark))
			  (if buffer-read-only "%" " ")))
		      (if (eq position tags-position-index) ">" " ")
		      (buffer-name (marker-buffer mark))
		      (if (eq position tags-position-index) "<" " "))
	      (list position mark)))))

(defun build-marker-menu-single-list()
  (if (> (length tags-position-stack) 0)
      (list "Buffer Menu"
	    (cons "     Select Marker       "
		  (let ((num (- (length tags-position-stack) 1))
			(param nil))
		    (while (>= num 0)
		      (setq param  
			    (cons num param))
		      (setq num (- num 1)))
		    (mapcar* 'my-print-menu (reverse tags-position-stack) (reverse param)))))
  nil))
  
(defun build-marker-menu-list()
  (let ((maxfiles vgmenu-max-items)
	(filesremain (length tags-position-stack))
	(nbfiles (length tags-position-stack))
	(nblist 0)
	(numlist 0)
	(result nil)
	(num 0)
	(highfiles 0)
	(param nil)
	(pres nil))
    (setq nblist (+ (/ filesremain maxfiles) 1))
    (if (> (length tags-position-stack) 0)
	;"Module Menu"
	(cons ""
	      (progn (while (< numlist nblist)
		       (setq highfiles (+ num maxfiles))
		       (if (> highfiles nbfiles) (setq highfiles nbfiles))
		       (if (< num highfiles) (setq result (cons (cons (concat "Split-" (number-to-string (+ numlist 1)))
						(progn (while (< num highfiles)
							 (setq pres (cons (my-print-menu (nth (- nbfiles (+ num 1)) tags-position-stack) (- nbfiles (+ num 1))) 
									  pres))
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

(defun tags-goto-nth-marker(position)
  (tags-goto-marker (nth position tags-position-stack) position))

(defun tags-goto-marker(marker position)
  (progn
    (let ((old-buff (buffer-name)))
      (if tags-position-move-update (replace-current-from-stack))
      (setq tags-position-index position)
      (switch-to-buffer (marker-buffer marker))
      (if tags-position-precise
	  (goto-char (marker-position marker)))
      (my-recenter)
      (message "%s -> %s" old-buff  (marker-buffer marker)))))

(defun my-recenter()
  (recenter nil))
;  (hilit-recenter nil))


(defun my-tags-menu (event)
  (interactive "e")
  (check-if-marker-pending)
  (let ((ret (build-marker-menu-list)))
    (if (not (eq ret nil))
	(progn
	  (setq ret (x-popup-menu event (build-marker-menu-list)))
	  (if (not (eq ret nil))
	      (tags-goto-marker (car (cdr ret)) (car ret))
	    (error "stack empty"))))))

(global-set-key [S-down-mouse-1]	'my-tags-menu)

(defun create-marker-list(m)
  (insert (concat (princ "(set-marker (make-marker) ")
		  (princ (number-to-string (marker-position m)))
		  (princ " (get-buffer \"")
		  (princ (buffer-name (marker-buffer m)))
		  (princ "\"))\n"))))


(defun save-marker-list()
  (interactive)
  (find-file ".stack.el.conv")
  (if (eq buffer-read-only t) (vc-toggle-read-only))
  (kill-region (point-min) (point-max))
  (insert (princ ";; sccsId = \"@(#)$Workfile$	$Revision$	$Modtime$\"\n"))
  (mapcar 'generate-files-to-load-from-marker tags-position-stack)
  (insert (princ "(setq tags-position-stack (list \n"))
  (mapcar 'create-marker-list tags-position-stack)
  (insert (princ "))\n")
	  (princ "(setq tags-position-index ")
	  (number-to-string tags-position-index)
	  (princ ")\n")
	  (princ "(tags-goto-nth-marker tags-position-index)\n"))
  (write-file ".stack.el.conv")
  (if (or (not (eq (getenv "JVTROOT") nil)) (not (eq (getenv "JETROOT") nil)))
      (replace-string-with-src-var)
    (write-file ".stack.el"))
  (kill-this-buffer)
)

(defun replace-string-with-src-var()
  (interactive)
  (if (eq buffer-read-only t) (vc-toggle-read-only))
  (setq defaultDirectory default-directory)
  (goto-char (point-min))
  (while (search-forward (getenv "JETSTREAMROOT") nil t)
    (replace-match "$JETSTREAMROOT" t t))
  (goto-char (point-min))
  (while (search-forward (getenv "JETROOT") nil t)
    (replace-match "$JETROOT" t t))
  (goto-char (point-min))
  (while (search-forward (getenv "JVTROOT") nil t)
    (replace-match "$JVTROOT" t t))
  (write-file (concat defaultDirectory ".stack.el")))

(defun replace-src-var-with-string(shouldSetDefaultDir)
  (interactive)
  (save-excursion
    (find-file "./.stack.el")
    (if (eq buffer-read-only t) (vc-toggle-read-only))
    (if shouldSetDefaultDir
	(setq defaultDirectory default-directory))
    (goto-char (point-min))
    (while (search-forward "$JETSTREAMROOT" nil t)
      (replace-match (getenv "JETSTREAMROOT") t t))
    (goto-char (point-min))
    (while (search-forward "$JETROOT" nil t)
      (replace-match (getenv "JETROOT") t t))
    (goto-char (point-min))
    (while (search-forward "$JVTROOT" nil t)
      (replace-match (getenv "JVTROOT") t t))
    (goto-char (point-min))
    (while (search-forward "$JVTBRC" nil t)
      (replace-match (getenv "JVTBRC") t t))
    (goto-char (point-min))
    (write-file (concat defaultDirectory ".stack.el.conv") nil))
  (kill-this-buffer))

(defun load-etags-list()
  (interactive "directory?")
  (save-excursion
    (setq defaultDirectory (getenv "DIR"))
    (find-file (concat defaultDirectory ".stack.el"))
    (if (eq buffer-read-only t) (vc-toggle-read-only))
    (goto-char (point-min))
    (while (search-forward "$JETSTREAMROOT" nil t)
      (replace-match (getenv "JETSTREAMROOT") t t))
    (goto-char (point-min))
    (while (search-forward "$JETROOT" nil t)
      (replace-match (getenv "JETROOT") t t))
    (goto-char (point-min))
    (while (search-forward "$JVTROOT" nil t)
      (replace-match (getenv "JVTROOT") t t))
    (write-file (concat defaultDirectory ".stack.el.conv") nil))
  ;(kill-this-buffer)
  (load-marker-list-once)
  (tags-move-previous)
  (tags-move-next)
  (load-marker-list-once))

(defun load-marker-list()
  (interactive)
  (replace-src-var-with-string t)
  (load-marker-list-once)
  (tags-move-previous)
  (tags-move-next)
  (load-marker-list-once))


(defun load-marker-list-once()
  (interactive)
  (setq tags-position-move-update nil)
  (load-file (concat defaultDirectory ".stack.el.conv"))
  (setq tags-position-move-update t))


(defun generate-files-to-load-from-marker(mark)
  (interactive)
  (if (not (eq (buffer-file-name (marker-buffer mark)) nil))
      (insert (princ "(find-file \"")
	      (buffer-file-name (marker-buffer mark))
	      (princ "\")\n"))))




(provide 'etags-stack)
