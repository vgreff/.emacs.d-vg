;;; printer.el
;;; Mon Mar 13 21:42:32 1989 Andrew Smith (andy@caen.engin.umich.edu)
;;;
;;; taken from print-select.el
;;;    Tue Apr  5 17:13:40 1988 by jcgs (John Sturdy) on harlqn
;;;    controlling the printer flags; switch on or off the banners, and change
;;;    the current printer
;;; and from Modified PRINT-BUFFER
;;;    by Olin Shivers (Olin.Shivers@CS.CMU.EDU)
;;;    11/11/87
;;;    If the buffer belongs to a file, and the file is up to date,
;;;    just print the file itself.
;;;    Support for different printing programs, other than lpr.
;;;
;;; Sun Mar 12 22:27:49 1989 -- Michael Hucka
;;;    Added check-printer-defined and made interactive functions
;;;    call this to make sure printer variable is defined.  Also
;;;    screwed around with comment format -- it's an obnoxious
;;;    habit I have.

(require 'cl)
(provide 'print-select)

(defvar printer nil
  "*If non-nil, specifies the printer to send files to.")

(defvar printer-program nil
  "*The program to use to send text to the printer. If nil, lpr is used.
   Set by calling PRINT-USING-LPR, PRINT-USING-ENSCRIPT.
   If you change this another way, be sure to change also:  PRINT-TITLE-HOOK,
   PRINT-DEST-HOOK, and PRINT-JOB-HOOK")

(defvar printer-switches '("")
  "*List of extra switches to pass to printer program.")

;;;============================================================================
;;; Helper functions:
;;; DELEQUAL CHECK-PRINTER-DEFINED
;;;

(defun delequal (thing l)
  (cond ((null l)
	 nil)
	((equal (car l) thing)
	 (delequal thing (cdr l)))
	(t
	 (cons (car l) (delequal thing (cdr l))))))

(defun check-printer-defined ()
  (interactive)
  (if (null printer)
      (error "You must first define a printer using select-printer."))
  printer)

;;; examining the printer queues

(defun lpq (&optional just-me)
  "Display the printer queue; 
   with a prefix argument, display only your own entries."
  (interactive "P")
  (when (check-printer-defined)
    (let ((buffer-name (concat "*" printer " queue*"))
	  (old-buffer (current-buffer)))
      (with-output-to-temp-buffer
	  buffer-name
	(set-buffer (get-buffer buffer-name))
	(message (buffer-name))
	(shell-command
	 (concat "lpq " (concat "-P" printer)
		 (if just-me
		     (concat " " (user-login-name))
                   "" ))
	 t))
      (set-buffer old-buffer))))

(defvar printer-name-alist nil
  "alist containing in the car parts the name strings for all printers
on this system. Used for completion in selecting a printer.")

(defun select-printer ()
  "Set the current printer to one chosen by the user. Completion on printer
names is done using \"/etc/printcap\" to provide the printer names."
  (interactive)
  (if (null printer-name-alist) (get-printer-names))
  (setq printer
        (completing-read "Choose printer: "
                         printer-name-alist
                         nil            ; predicate
                         t))            ; requires match
  (save-window-excursion
    (message "Checking that printer %s is OK" printer)
    (set-buffer (get-buffer-create " *printer selection check*"))
    (erase-buffer)
    (shell-command (concat "lpq " (concat "-P" printer)) t)
    (goto-char (point-min))
    (end-of-line) (forward-char)
    (if (re-search-backward "off\\|disabled" (point-min) t) ; BUG?!?!?
        (message "Problem with %s: %s"
                 printer (first-line-of-buffer))
      (message "Printer %s selected" printer))
    (kill-buffer (current-buffer))))

(defun add-printer (printer-name)
  "Add PRINTER to the list of printers used for completion in select-printer."
  (setq printer-name-alist (cons
                            (cons printer-name nil)
                            printer-name-alist)))

(defun get-printer-names ()
  "Find all the valid printer names from \"/etc/printcap\"."
  (save-window-excursion
    (message "Reading /etc/printcap...")
    (set-buffer (get-buffer-create " *printcap file*"))
    (setq printer-name-alist nil)       ; empty the name list
    (erase-buffer)                      ; clear the buffer
    (insert-file-contents "/etc/printcap" t) ; t marks as unmodified
    (goto-char (point-min))
    (while (re-search-forward "^[^# \t]" (point-max) t)
                                        ; scan for lines with printer names
      (beginning-of-line)
      (while (not (eq (char-after (- (point) 1)) ?\:))
                                        ; next line after last name on this one
        (let ((start (point)))
          (re-search-forward "[:|]" (point-max) t) ; get next name on line
          (add-printer (buffer-substring start (- (point) 1))))))
    (message "Reading /etc/printcap... done")
    (kill-buffer (current-buffer))))

;;; end of print-select.el

;;;============================================================================
;;; Basic user interface:
;;; PRINT-BUFFER PRINT-REGION
;;;

(defun print-buffer ()
  "Send buffer contents to the printer. See variables PRINTER, PRINTER-PROGRAM,
   and PRINTER-SWITCHES for customisation."
  (interactive)
  (when (check-printer-defined)
    (if (or (buffer-modified-p) (not buffer-file-name))
      (print-region-1 (point-min) (point-max))
      (print-file buffer-file-name))))

(defun print-region (start end)
  "Send region to the printer. See variables PRINTER, PRINTER-PROGRAM,
   and PRINTER-SWITCHES for customisation."
  (interactive "r")
  (when (check-printer-defined)
    (print-region-1 start end)))

;;;============================================================================
;;; Simple printer-choosers:
;;; PRINT-USING-LPR PRINT-USING-ENSCRIPT
;;;
;;; Feel free to customise the functions yourself. In particular, you
;;; might like to make them set the value of PRINTER-SWITCHES. Also,
;;; note that when you are printing a non-file (buffer or region), and
;;; PRINT-TITLE-HOOK is used to set the header of the printout to
;;; be "foo.c Emacs buffer", there is a small problem. Setting the header
;;; to get the buffer name can cause page numbers to go away. Cz, and enscript
;;; without the -G option have this problem. There's no way to set the
;;; filename part of the header without setting the entire header, thus
;;; blasting the page numbers. Lpr -p doesn't have this problem, because
;;; the -T switch just sets the filename part of the header. But if you
;;; are using cz or enscript without -G, you have to choose for headers:
;;; 1. no buffername:   "11/9/87           stdin            page 3"
;;; 2. only buffername: "           foo.c Emacs buffer            "
;;; You get option 2 by specifying a real PRINT-TITLE-HOOK, or by default.
;;; You get option 1 by setting the PRINT-TITLE-HOOK to be a no-op,
;;; i.e. '(LAMBDA (TITL) '()).
;;; There's nothing that can be done to fix this problem, since it's
;;; a problem with the printing programs, not with the emacs end of things.
;;;
;;; For all printing programs, however, you avoid all this mess when you use
;;; the PRINT-BUFFER command to print out saved buffers. In this case,
;;; PRINT-BUFFER cleverly just prints the file itself, and the retarded
;;; print program has a chance to get the headers right.


(defun print-using-enscript ()
  "Causes enscript to be the print program. Sets PRINTER-SWITCHES to (\"-G\")"
  (interactive)
  (setq print-dest-hook nil)
  (setq print-title-hook '(lambda (titl) (list (concat "-b" titl))))
  (setq print-job-hook nil)
  (setq printer-program "enscript")
  (setq printer-switches '("-G")))

(defun print-using-lpr ()
  "Causes lpr to be the print program. Sets PRINTER-SWITCHES to (\"\")"
  (interactive)
  (setq print-dest-hook nil)
  (setq print-title-hook nil)
  (setq print-job-hook nil)
  (setq printer-program "lpr")
  (setq printer-switches '("")))

;;;============================================================================
;;; Printer interface functions and hooks:
;;; PRINT-DEST-HOOK PRINT-TITLE-HOOK PRINT-JOB-HOOK
;;;

(defvar print-dest-hook nil
  "*If non-nil, a function mapping a printer name to the appropriate
    list of arguments for the print program. E.g.,
    (lambda (pr) (list \"-P\" pr))")

(defun print-dest (printer)
  "Takes the name of a printer, and turns it into a list of arguments
   for the print program. Defaults to (\"-P\" printer)."
  (if print-dest-hook
      (funcall print-dest-hook printer)
      (list "-P" printer)))

(defvar print-title-hook nil
  "*If non-nil, a function mapping a print title to the appropriate
    list of arguments for the print program. E.g.,
    (lambda (titl) (list \"-T\" titl))")

(defun print-title (titl)
  "Takes the print title for a print job, and turns into a list of arguments
   for the print program. Defaults to (\"-T\" titl)."
  (if print-title-hook
      (funcall print-title-hook titl)
      (list "-T" titl)))

(defvar print-job-hook nil
  "*If non-nil, a function mapping a job name to the appropriate
    list of arguments for the print program. E.g.,
    (lambda (jname) (list \"-J\" jname))")

(defun print-job (jname)
  "Takes the job name of a print job, and turns it into a list of arguments
   for the print program. Defaults to (\"-J\" jname)."
  (if print-job-hook
      (funcall print-job-hook jname)
      (list "-J" jname)))

;;;============================================================================
;;; Programs that really do it:
;;; PRINT-FILE PRINT-REGION-1;;;

(defun print-file (filename)
  "Print file."
  (interactive "ffile: ")
  ;; Check to see if the file should be saved before printed.
  (when (check-printer-defined)
    (let ((buff (get-file-buffer filename)))
      (if (and buff
	       (buffer-modified-p buff)
	       (y-or-n-p (format "Save buffer %s first? "
				 (buffer-name buff))))
	  ;; Save BUFF.
	  (let ((old-buffer (current-buffer)))
	    (set-buffer buff)
	    (save-buffer)
	    (set-buffer old-buffer))))
    (message "Spooling file to %s..." printer )
    (apply 'call-process (or printer-program "lpr")
	   nil 0 nil
	   (append (if printer (print-dest printer))
		   printer-switches
		   (list filename)))
    (message "Spooling file to %s...done" printer)))

(defun print-region-1 (start end)
  (save-excursion
   (message "Spooling to %s..." printer)
   (if (/= tab-width 8)
       (let ((oldbuf (current-buffer)))
        (set-buffer (get-buffer-create " *spool temp*"))
        (widen) (erase-buffer)
        (insert-buffer-substring oldbuf)
        (call-process-region start end "expand"
                             t t nil
                             (format "-%d" tab-width))))
   (let ((title (concat (buffer-name) " Emacs buffer")))
     (apply 'call-process-region start end
            (or printer-program "lpr")
            nil nil nil
            (append (print-title title)
                    (if printer (print-dest printer))
                    (print-job title)
                    printer-switches)))
   (message "Spooling to %s...done" printer)))

(defun set-print-using-enscript-G-2r ()
 "Set the printer program to be enscript -G -2r"
  (interactive)
  (print-using-enscript)
  (setq printer-switches '("-G -2r"))
  (message  "Set the printer program to be enscript -G -2r (%s)" printer)  )

(defun set-print-using-enscript-G-fCourier7 ()
 "Set the printer program to be enscript -G -fCourier7"
  (interactive)
  (print-using-enscript)
  (setq printer-switches '("-G -fCourier7"))
  (message  "Set the printer program to be enscript -G -fCourier7 (%s)" printer)  )

(defun set-print-using-lpr ()
 "Set the printer program to be lpr"
  (interactive)
  (print-using-lpr)
  (message  "Set the printer program to be lpr (%s)" printer)  )

(defun printer-name ()
 "Print the printer name"
  (interactive)
  (message  "The printer is %s" printer)  )

;;(set-print-using-enscript-G-2r)

