; mon jun 18 10:31 1990 -- valas
; commands.el contains functions which are for general use.  functions
; which are specific to particular modes, languages or development
; environments will be found elsewhere.  (found, it is hoped, wherever
; is most appropriate....)


(defun insert-stamp (&optional pre)
  "Insert moderately robust, visually appealing time stamps.
With PREFIX, wrap it in appropriate comment syntax."
  (interactive "P")
  (if pre
      (insert-time-stamp-comment)
    (insert (time-stamp))))


(defun insert-time-stamp-comment ()
  "Insert moderately robust, visually appealing time stamps."
  (interactive)

  ; if there's no known comment-start, use # instead
  (insert (if comment-start comment-start "#"))

  ; ensure a blank after comment-start
  (if (not (looking-at "[ \t]"))
      (insert " "))

  (insert (time-stamp) comment-end)
  (if (not (looking-at "[ \t\n]"))
      (insert " ")))


(defun time-stamp ()
  "returns time-stamp string, properly formatted...."
   (concat (substring (current-time-string) 0 16)
	   (substring (current-time-string) 19)
	   "  "
	   (user-login-name)))

(defun virgin-emacs ()
  "Restores emacs to pristine state of being by deleting
all non-essential buffers."
  (interactive)
  (save-some-buffers t)
  (mapcar 'flush-buffers (buffer-list))
  (switch-to-buffer "*scratch*")
  (erase-buffer)
  (delete-other-windows))

(defun flush-buffers (buff)
  (let ((buf (buffer-name buff)))
    (cond ((string= buf "*scratch*")
	   t)
	  ((string= buf "*Buffer List*")
	   t)
	  ((string= buf " *Minibuf-0*")
	   t)
	  (t
	   (kill-buffer buff)))))

(defun zap-to-char (arg char)
  "Kill up to (but not including) next occurrence of CHAR.
Goes backward if prefix universal arg exists; goes to end
of buffer if CHAR not found."
  (interactive "*P\ncZap to char: ")
  (let ((dir (if arg -1 1)))
    (kill-region (point) (if (search-forward
			      (char-to-string char) nil t dir)
			 (progn 
			   (goto-char (if (> dir 0) (1- (point)) (1+ (point))))
				(point))
		       (if (> dir 0) (point-max) (point-min))))))


(defun newline-to-space (in-string)
  "Converts all newlines in STRING to spaces...."
 (if (not (= (length in-string) 0))
     (if (string-match (char-to-string 10) in-string)
	 (concat (substring in-string 0 (match-beginning 0))
		 " "
		 (newline-to-space 
		  (substring in-string (match-end 0))))
       in-string)))


(defun find-this-file-other-window ()
  "Extract the word about or after point, confirm it's
an existing file, and find it in the other window."
  (interactive)
  (let (target-file)
    (if (file-readable-p (setq target-file (extract-word)))
	(find-file-other-window target-file)      
      (find-file-other-window
       (read-file-name (format "Couldn't read \"%s\" !  Which file? "
			       target-file)
		       default-directory)))))
      


;; this version of extract-word was lifted from the tags.el file
;; mon jun 11 09:42 1990 -- valas

(defun extract-word ()
  "Buffer-substrings the next word and returns it.  Note that the
chars \"_\", \"-\" and \".\" are treated as word syntax, without affecting
the local buffer syntax."
  (save-excursion
    (re-search-forward "\\sw" nil t)
    (while (looking-at "\\sw\\|\\_\\|\\-\\|\\.") (forward-char -1))
    (forward-char 1)
    (buffer-substring
     (point)
     (progn
       (while (looking-at "\\sw\\|\\_\\|\\-\\|\\.") (forward-char 1))
       (point)))))


;; Snagged this from usenet:

;;; adapted from emacs/etc/FAQ:
(defun see-chars (arg)
  "Displays characters/events typed, terminated by a 3-second timeout.
With prefix arg or if output is longer than echo area,
result goes to buffer \"*Help*\"."
  (interactive "P")
  (let ((chars "Characters entered:")
	(inhibit-quit t))
    (message "Enter characters, terminated by 3-second timeout.")
    (while (not (sit-for 3))
      (let ((seq (read-key-sequence nil)))
	(setq chars (concat chars " " (if (vectorp seq)
					  (format "%s" seq)
					(key-description seq)))
	      quit-flag nil)))		; quit-flag maybe set by C-g
    (if (and (not arg) (<= (length chars) (frame-width)))
	(message "%s" chars)
      (with-output-to-temp-buffer "*Help*"
	(princ (format "%s" chars)))
      )))


(defun add-file-header ()
  "Adds a typical file header to the current buffer. Uses the perl script addHdr."
  (interactive)
  (beginning-of-buffer)
  (let ((cmd "addHdr "))
    (if comment-start
        (setq cmd (concat cmd "-c \"" comment-start " " comment-end "\" ")))
    (shell-command (concat cmd (buffer-file-name)) t )
    (if (featurep 'hilit19)
        (hilit-rehighlight-buffer-quietly))))

(global-set-key "\C-ch" 'add-file-header)

(require 'find-file)
(global-set-key "\C-cf" 'ff-find-other-file)
