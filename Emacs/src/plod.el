;;;;
;;;; plod.el
;;;;
;;;; Emacs interface to PLOD --- A (Perl) tool to keep track of the work you do
;;;; PLOD was written by pomeranz@irving.nas.nasa.gov (Hal R. Pomeranz).
;;;;
;;;; This software is FREE to all and may be used for any purpose as long as this 
;;;; notice remains intact.  The author does not assume responsibility for anything.
;;;; 
;;;; Suggested addition to .emacs:
;;;; 	(load-library "plod")
;;;; 	(plod-alarm-on 60) ; once an hour
;;;;
;;;; When you are tired of PLODding use "M-x plod-alarm-off"
;;;; 
;;;; Alternately, use "M-x plod" whenever you want to log something.
;;;; 
;;;; paul@ascent.com (Paul Foley)	Wednesday January 20, 1993


;;;
;;; Variables
;;;

;; Name of executable --- should be in your $PATH
(defvar plod-program-name "plod")
(defvar plod-buffer-name "*PLOD*")

;;;
;;; Manual Interface
;;;

(defvar plod-buffer-process nil)

;; Interactive command to invoke PLOD in a shell-mode buffer.
;;

(defun plod ()
  "Invoke PLOD."
  (interactive)
  (switch-to-buffer (get-buffer-create plod-buffer-name) nil)
  (indented-text-mode)
  (local-set-key "\C-c\C-c" 'plod-send-plod-buffer))

(defun plod-send-plod-buffer( )
  "Sends the plod buffer to plod"
  (interactive)
  (cond ((get-buffer plod-buffer-name)
	 (save-excursion
	   (set-buffer plod-buffer-name)
	   (cond ((eq (point-min) (point-max))
		  (error "Plod buffer empty"))
		 (t (goto-char (point-max))
		     (if (not (eq (preceding-char) ?\n))
			   (insert-char ?\n 1))
		     (plod-send-region (point-min) (point-max) t)
		     (set-buffer-modified-p nil)))))
	(t (error "No plod buffer to send"))))

(defun plod-send-region (start end &optional delete)
  "Sends the region to plod"
  (interactive "r")
  (message "Sending text to plod...")
  (call-process-region start end plod-program-name delete nil nil)
  (message "Sending text to plod...done"))


;;;
;;; Alarm interface
;;;

(defvar plod-alarm-on-p nil)		; t if alarm is on
(defvar plod-alarm-process nil)

;; run when plod-alarm-process is killed
(defun plod-alarm-sentinel (proc reason)
  (or (eq (process-status proc) 'run)
      (setq plod-alarm-on-p nil)
      (ding) 
      (message "PLOD alarm off")))

;; run every interval & at initial call to plod-alarm-on
(defun plod-alarm-filter (proc string)
  (if plod-alarm-on-p
      (plod)
    (setq plod-alarm-on-p t)))

;; Set alarm to call PLOD every so often
;;
(defun plod-alarm-on (interval)
  "Turn the Emacs PLOD alarm on.  The alarm goes off every INTERVAL minutes
and you will be switched to the PLOD buffer automatically.  
Use plod-alarm-off to stop this behaviour."
  (interactive "nEnter PLOD alarm interval (in minutes): ")
  (let ((live (and plod-alarm-process
		   (eq (process-status plod-alarm-process) 'run))))
    (if (not live)
	(progn
	  (setq plod-alarm-on-p nil)
	  (if plod-alarm-process
	      (delete-process plod-alarm-process))
	  (let ((process-connection-type nil))
	    (setq plod-alarm-process
		  (start-process "plod-alarm" nil 
				 (concat exec-directory "wakeup")
				 ; convert minutes -> seconds for wakeup
				 (int-to-string (* 60 interval)))))
	  (process-kill-without-query plod-alarm-process)
	  (set-process-sentinel plod-alarm-process 'plod-alarm-sentinel)
	  (set-process-filter plod-alarm-process 'plod-alarm-filter)))))

;; Turn PLOD alarm off
;;
(defun plod-alarm-off ()
  "Turn the Emacs PLOD alarm off."
  (interactive)
  (if plod-alarm-on-p (kill-process plod-alarm-process)))

;;; End





