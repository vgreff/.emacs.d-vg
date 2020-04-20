(defun sql-make-alternate-buffer-name ()
  "Return a string that can be used to rename a SQLi buffer.

This is used to set `sql-alternate-buffer-name' within
`sql-interactive-mode'."
  (concat (if (string= "" sql-user)
	      (if (string= "" (user-login-name))
		  ()
		(concat (user-login-name) "/"))
	    (concat sql-user "/"))
	  (if (string= "" sql-database)
	      (if (string= "" sql-server)
		  (system-name)
		sql-server)
	    sql-database)
  (concat "/" sql-server )))



(provide 'sql-hook-vg)

