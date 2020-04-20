;;; hscroll.el: Minor mode to automatically scroll truncated lines horizontally
;;; Copyright (C) 1992 Wayne Mesard
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; The GNU General Public License is available by anonymouse ftp from
;;; prep.ai.mit.edu in pub/gnu/COPYING.  Alternately, you can write to
;;; the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139,
;;; USA.
;;--------------------------------------------------------------------

;;; DESCRIPTION
;;    Automatically scroll horizontally when the point moves off the
;;    left or right edge of the window.  Type "M-x hscroll-mode" to
;;    invoke it in the current buffer.  This only has effect when
;;    the current line is truncated by Emacs.  Say "Control-h f 
;;    hscroll-truncate-lines" for details.
;;
;;    HScroll's sensitivity is controlled by the variable hscroll-margin.
;;    How much HScroll adjusts the window is determined by hscroll-step.
;;
;;    Most users won't have to mess with the other variables and functions 
;;    defined here.  But they're all documented, and they all start with 
;;    "hscroll-" if you're curious.
;;
;;    Oh, you should also know that if you set the hscroll-margin and
;;    hscroll-step large enough, you can get an interesting, but
;;    undesired ping-pong effect as the point bounces from one edge to
;;    the other.
;;
;;    WMesard@cs.stanford.edu

;;; HISTORY
;;    1.1 wmesard - Aug 18, 1992: Fixed setq-default bug
;;    1.0 wmesard - Aug 11, 1992: Created

;;  LCD Archive Entry:
;;  hscroll|Wayne Mesard|wmesard@cs.stanford.edu|
;;  Minor mode to automatically scroll horizontally|
;;  92-11-11|1.1|~/modes/hscroll.el.Z|


;;; 
;;; PUBLIC VARIABLES
;;; 

(defvar hscroll-margin 5 
  "*How many columns away from the edge of the window point is allowed to get
before HScroll will horizontally scroll the window.")

(defvar hscroll-step 25
  "*How far away to place the point from the window's edge when scrolling.
Expressed as a percentage of the window's width.")

(defvar hscroll-poll-period "1"
  "*Interval between polling for HScroll mode (in seconds).
This is how often HScroll will test to see if the point has exceeded
a horizontal margin.  If nil, it will test continuously (but this is
not recommended, since it will slow down your machine and annoy Emacs).")

(defvar hscroll-mode nil 
  "Whether hscroll-mode is enabled for the current buffer.
Ordinarily set indirectly (via \\[hscroll-mode]).  However,
   (setq-default hscroll-mode t)
will put buffers in HScroll mode by default.  Automatically becomes local
when set.")


;;; 
;;; PRIVATE VARIABLES
;;; 

(defvar hscroll-process nil)

;;; 
;;; PUBLIC FUNCTIONS
;;; 

(defun hscroll-mode (&optional onoff)
  "Toggle HScroll mode in the current buffer.
With arg, turn HScroll mode on if arg is positive, off otherwise.
In HScroll mode, truncated lines will automatically scroll left or right
when point gets near either edge of the window."
  (interactive "P")
  (if (null hscroll-process)
      (progn
	(make-variable-buffer-local 'hscroll-mode)
	;; So that the last line in this func will do the right thing
	;; when default value is t and this is the first buffer.
	(setq hscroll-mode nil)
	(or (assq 'hscroll-mode minor-mode-alist)
	    (setq minor-mode-alist
		  (cons '(hscroll-mode " HScr")
			minor-mode-alist)))
	(setq hscroll-process (start-process "hscroll" nil
					     (concat exec-directory "wakeup")
					     (or hscroll-poll-period
						 "0")))
	(set-process-sentinel hscroll-process 'hscroll-sentinel)
	(set-process-filter hscroll-process 'hscroll-filter)
	(process-kill-without-query hscroll-process)
	))
  (setq hscroll-mode (if onoff
			 (> (if (numberp onoff) onoff
			      (prefix-numeric-value onoff))
			    0)
		       (not hscroll-mode))
	))


(defun hscroll-shutdown ()
  "Disable HScroll mode in all buffers, and terminate the HScroll subprocess.
This command is an \"emergency switch\" for use if the subprocess starts
hogging up too many system resources."
  (interactive)
  (or (assq 'hscroll-mode minor-mode-alist)
      (setq minor-mode-alist
	    (cons '(hscroll-mode "")
		  minor-mode-alist)))
  (if (eq 'run (process-status hscroll-process))
      (kill-process hscroll-process))
  (setq hscroll-process nil)
  )


(defun hscroll-truncate-lines (&optional onoff)
  "Toggle the value of the Emacs variable truncate-lines in the current buffer.  
With arg, set to t if arg is positive, nil otherwise.  This is just a
convenience function and not really part of HScroll.  Without it, you'd
have to use set-variable to change the value of truncate-lines.

Say \\[describe-variable] truncate-lines and \\[describe-variable] \
truncate-partial-width-windows for details."
  (interactive "P")
  (setq truncate-lines (if onoff
			   (> (if (numberp onoff) onoff 
				(prefix-numeric-value onoff))
			      0)
			 (not truncate-lines))
	))


(defun hscroll-window-maybe ()
  "Scroll horizontally if point is off or nearly off the edge of the window.
This is called automatically when in HScroll mode, but it can be explicitly
invoked as well."
  (interactive)
  ;; Only consider scrolling if truncate-lines is true, 
  ;; the window is already scrolled or partial-widths is true and this is
  ;; a partial width window.  See display_text_line() in xdisp.c.
  (if (or truncate-lines
	  (not (zerop (window-hscroll)))
	  (and truncate-partial-width-windows
	       (< (window-width) (screen-width))))
      (let ((linelen (save-excursion (end-of-line) (current-column)))
	    (rightmost-char (+ (window-width) (window-hscroll)))
	    )
	(if (>= (current-column)
		(- rightmost-char hscroll-margin
		   ;; Off-by-one if the left edge is scrolled
		   (if (not (zerop (window-hscroll))) 1 0)
		   ;; Off by one if the right edge is scrolled
		   (if (> linelen rightmost-char) 1 0)))
	    ;; Scroll to the left a proportion of the window's width.
	    (set-window-hscroll 
	     (selected-window) 
	     (- (+ (current-column) 
		   (/ (* (window-width) hscroll-step) 100))
		(window-width)))
	  (if (< (current-column) (+ (window-hscroll) hscroll-margin))
	      ;; Scroll to the right a proportion of the window's width.
	      (set-window-hscroll
	       (selected-window)
	       (- (current-column) (/ (* (window-width) hscroll-step) 100)))
	    ))
	)))


;;; 
;;; PRIVATE FUNCTIONS
;;; 

(defun hscroll-filter (ignore ignore)
  ;; Don't even bother if we're not in the mode.
  (if hscroll-mode
      (hscroll-window-maybe)))


(defun hscroll-sentinel (ignore reason)
  (hscroll-shutdown)
  (error "Whoa: the HScroll process died unexpectedly: %s." reason))

(provide 'hscroll)
