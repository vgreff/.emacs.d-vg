;; sccsId = "@(#)$Workfile$	$Revision$	$Modtime$"
(find-file "$JVTBRC/cpp/jvt/SampleLib/ModuleB.C")
(find-file "$JVTBRC/cpp/jvt/SampleLib/ModuleA.C")
(find-file "$JVTBRC/cpp/jvt/SampleLib/Makefile")
(setq tags-position-stack (list 
(set-marker (make-marker) 1 (get-buffer "ModuleB.C"))
(set-marker (make-marker) 1 (get-buffer "ModuleA.C"))
(set-marker (make-marker) 1 (get-buffer "Makefile"))
))
(setq tags-position-index 2)
(tags-goto-nth-marker tags-position-index)
