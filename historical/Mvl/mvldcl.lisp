;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: USER; Base: 10 -*-

;;
;; MVL package, file-system, and system definitions.
;;
;; In order to load the system on a new machine, edit the default
;; pathname specified in the defsystem form, which can be found by
;; searching for the string `***'.

;; The first thing we do is decide whether we're using the ANSI
;; standard or Steele's 1984 version of Common Lisp.  The way this
;; is done is to see if in-package is a function (1984) or a macro
;; (ANSI).

(eval-when (compile load)
  (when (macro-function 'in-package) (pushnew :ANSI *features*)))

;; MVL package interface.

#+ANSI (defpackage "MVL" (:use "COMMON-LISP"))
#+ANSI (in-package "MVL")

#-ANSI (in-package "MVL" :use '(lisp))

;; Note: the names of modal operators are also exported.  The function
;; load-logic-1 performs the exporting when a bilattice defining modal
;; operators is loaded.

(export '(|=>|				;operators supposedly understood by MVL
	  |<=|
	  |<=>|
	  if
	  iff
	  ?
	  ?*

	  activate			;operators in the manual appendix
	  activate-best-first
	  activate-breadth-first
	  activate-depth-first
	  activate-theory-mechanism
	  *active-bilattice*
	  *active-theories*
	  add-dag
	  *always-succeeds*
	  answer
	  answer-binding
	  answer-value
	  anytime-trace
	  anytime-untrace
	  append-bilattice
	  append-binding-lists
	  *atms-bilattice*
	  bagof
	  bc
	  bc-trace
	  bc-untrace
	  bc-unwatch
	  bc-watch
	  bcs
	  bdg-to-truth-val
	  bilattice
	  bilattice-only
	  *bilattices*
	  binding-dag
	  binding-le
	  bottom
	  *break-node*
	  choose-task
	  circum
	  *circum-trace*
	  circums
	  *circumscription-bilattice*
	  cnf
	  *cnf-atms-bilattice*
	  combine-1
	  combine-fns
	  compile-mvl
	  *completed-database*
	  cont-analysis
	  cont-prover
	  contents
	  create-mvl-invocation
	  cutoffs-not
	  dag-accumulate-fn
	  dag-bilattice
	  dag-change-dag
	  dag-change-tv
	  dag-list-of-answers
	  dag-only
	  dag-prune
	  deactivate
	  *default-bilattice*
	  delete-bdg
	  denotes
	  dnf
	  done
	  dot-with-not
	  dot-with-star
	  empty
	  empty-theory
	  equal-answer
	  equal-binding
	  *equivalence-translation*
	  erase
	  erase-from-theory
	  existing-mvl-invocation
	  false
	  fc
	  fc-trace
	  fc-untrace
	  *final-limit*
	  *first-order-atms-bilattice*
	  *first-order-bilattice*
	  fn-and
	  fn-comp
	  fn-dot
	  fn-dws
	  fn-eq
	  fn-not
	  fn-or
	  fn-plus
	  get-bdg
	  get-mvl
	  get-val
	  *global*
	  groundp
	  hierarchy-bilattice
	  *hierarchy-bilattice*
	  *if-translation*
	  includes
	  indbp
	  index
	  init-analysis
	  init-prover
	  *initial-limit*
	  instp
	  invoke
	  k-ge
	  k-gt
	  k-le
	  k-lt
	  k-not-ge
	  k-not-gt
	  k-not-le
	  k-not-lt
	  known
	  lattice-to-bilattice
	  lattice-to-dag
	  lattice-to-dag-to-bilattice
	  *limit-delta*
	  lisp-defined
	  lisp-predicate
	  load-logic
	  load-mvl
	  lookup
	  lookup-call
	  lookups
	  lookups-call
	  make-answer
	  make-root
	  make-tv
	  matchp
	  mvl-and
	  mvl-dot
	  mvl-eq
	  mvl-file
	  *mvl-invocation*
	  mvl-load
	  mvl-not
	  mvl-or
	  mvl-plug
	  mvl-plus
	  mvl-print
	  mvl-save
	  mvl-simplicity
	  mvl-test-file
	  *mvl-timer*
	  mvl-unload
	  negate
	  *never-succeeds*
	  new-*var
	  new-?var
	  new-val
	  *node-evaluation-fn*
	  normal-form
	  plug
	  prfacts
	  *probability-bilattice*
	  product-bilattice
	  property
	  props
	  release-mvl
	  rem-mvl
	  safe-answer-binding
	  safe-answer-value
	  samep
	  *save-nodes*
	  set-search-parameters
	  simplify
	  splice-bilattice
	  standardize-operators
	  stash
	  stash-value
	  state
	  state-in-theory
	  std-cutoffs
	  std-success
	  *success-test*
	  t-ge
	  t-gt
	  t-le
	  t-lt
	  t-not-ge
	  t-not-gt
	  t-not-le
	  t-not-lt
	  test
	  test-mvl
	  theory-active-p
	  theory-contents
	  theory-dag
	  *time-bilattice*
	  true
	  true-at
	  true-in-theory
	  truth-value
	  unifyp
	  unincludes
	  unindex
	  unknown
	  unstash
	  unstash-facts-with-atom
	  unstash-value
	  unstate
	  unstate-from-theory
	  value
	  varp
	  varp*
	  varp?
	  vars-in
	  vartype
	  with-mvl-invocation
	  write-activate
	  *writing-theory*))

(defmacro read-time-case (first-case &rest other-cases)
  "Do the first case, where cases are specified with #+ or possibly #-
  conditionals.  The final, default case has no conditional."
  (declare (ignore other-cases))
  first-case)

#-ANSI
(defmacro with-compilation-unit (&body body)
  "Do the body, but delay warnings until the end."
  ;; That way, undefined function warnings that are really
  ;; just forward references will not be printed at all.
  `(,(read-time-case
       #+TI    'compiler:compiler-warnings-context-bind
               'progn)
    .,body))

;; MVL system definition.

;; Ensure a defsystem macro.  On a Symbolics, use the version provided.
;; Otherwise, use a simple parser to translate the defsystem into a
;; list of files in the correct dependency order.

#+Genera
(progn
  (import 'scl:defsystem)

  (defmacro system-default-pathname (name)
    `(sct:system-default-pathname (sct:find-system-named ,name)))

  )


#-Genera
(progn

  (defmacro system-source-files (name)
    `(get (canonicalize-system ,name) :system-source-files))

  (defmacro system-default-pathname (name)
    `(get (canonicalize-system ,name) :system-default-pathname))
   
  (defmacro defsystem (name options &body body)
    (let ((default-pathname (getf options :default-pathname))
	  (modules nil)
	  (definition nil))
      (dolist (clause (copy-list body))	;copy-list for safety ...
	(ecase (first clause)
	  ((:module :module-group)
	   (push (cons (second clause) (third clause)) modules))
	  ((:serial :parallel :definitions)
	   (setq definition (rest clause)))))
      (when (null definition)
	(setq definition (mapcar #'car (reverse modules))))
      (labels ((parse-system (list modules)
		 (etypecase (first list)
		   ;; Base case.
		   (null nil)
		   ;; A string is a file name.
		   (string (cons (first list)
				 (parse-system (rest list) modules)))
		   ;; A symbol is a module name.
		   (symbol (parse-system 
			    (append (cdr (assoc (first list) modules))
				    (rest list))
			    (remove (first list) modules :key #'car)))
		   ;; A cons is another definition.
		   (cons (parse-system (append (rest (first list)) (rest list))
				       modules)))))
	`(setf (system-source-files ',name)
	   (mapcar #'(lambda (file)
		       (merge-pathnames file ,default-pathname))
		   ',(parse-system definition modules))
	   (system-default-pathname ',name)
	   ,default-pathname))))

  (defun canonicalize-system (name)
    (values (intern (string-upcase (string name)) 'keyword)))

  )


;; Define the MVL system.
;;
;; *** Edit the value of :default-pathname to relect the location of
;; the source code on your machine.

;; Note: Allegro ANSI does not support logical pathnames; hence the 2nd line
;; below.

(defsystem mvl
    (:default-pathname #+(and ANSI (not Allegro)) "MVL:"
                       #+(and ANSI Allegro) "/proj/dspm/sgwoods/Mvl/"
     		       #-ANSI "/proj/dspm/sgwoods/Mvl/"
     :default-package 'mvl
     :pretty-name "Multivalued Logics")
  (:module basic ("symbols" "bindings" "match" "tags" "index" "agenda"))
  (:module invocations ("invocations"))
  (:module query ("query"))
  (:module load ("load"))
  (:module manipulate ("product" "function" "surgery" "hierarchy" "dag"
				 "lattice"))
  (:module bilattices ("fol" "atms" "atms-cnf" "def" "fo-atms" "circ"
			     "prob" "temporal"))
  (:module dags ("theory-dag" "binding-dag"))
  (:module logic ("logic"))
  (:module functions1 ("cnf" "rep" "lookup" "first-order"))
  (:module functions2 ("bc"))
  (:module functions3 ("first-order-user-interface"
		       "first-order-mvl-interface" "bc-user"
		       "bc-interface" "relevance" "fc" "attach" "test"))
  (:module editor #.(prog1 #+Genera  '("zweimvl" "clp")
			   #+Allegro '("fi")
			   nil))
  (:module tests ("mvl.test" "bc.test" "recursion.test" "atms.test"
			     "defaults.test" "circumscription.test"
			     "completed-db.test" "modal.test" "fc.test"
			     "temporal.test")
	   (:type :lisp-example))
  (:module test-data ("f1.mvl" "recursion.mvl" "def-test.mvl" "circ-test-1.mvl"
			       "circ-test-2.mvl" "circ-test-3.mvl"
			       "circ-test-4.mvl" "completed-db-1.mvl"
			       "completed-db-2.mvl" "actions.mvl"
			       "shooting.mvl")
	   (:type :lisp-example))
  (:module manual ("manual.tex") (:type :text))
  (:serial basic invocations query load manipulate bilattices dags
	   logic functions1 functions2 functions3 editor))

;; System manipulation functions.

;; Load MVL.  Also updates the *features* list and invokes (empty) to
;; clean out the deductive database, if there is one.

(defun load-mvl ()
  (when (fboundp 'empty) (funcall 'empty))
  (read-time-case
   #+Genera (sct:load-system :mvl :query nil :silent t :no-warn t)
   (mapc #'load (system-source-files :mvl)))
  (pushnew :mvl *features*)
  (values))

;; Compile MVL.  Should only be used when source code is changed.

(defun compile-mvl (&key reload recompile)
  (when (fboundp 'empty) (funcall 'empty))
  (read-time-case
   #+Genera
   (multiple-value-bind (returned-val err)
       (scl:ignore-errors
	(sct:compile-system :mvl :increment-version nil :query nil
			    :silent t :no-warn t :reload reload
			    :recompile recompile))
     (declare (ignore returned-val))
     (if err (sct:compile-system :mvl :increment-version t :query nil
				 :silent t :no-warn t :reload reload
				 :recompile recompile)))
   #+Allegro
   (progn
     reload				;prevent compiler warning 
     (if recompile 
	 (mapc #'(lambda (f) (progn (compile-file f) (load f)))
	       (system-source-files :mvl))
       (apply #'tpl::cload-command (system-source-files :mvl))))
   (progn
     reload recompile
     (mapc #'(lambda (f) (with-compilation-unit (load (compile-file f))))
	   (system-source-files :mvl))))
  (pushnew :mvl *features*)
  (values))

;; Release a new version of MVL.  Implemented only for the Symbolics.

(defun release-mvl (&key no-recompile)
  (read-time-case
   #+Genera
   (progn
     (unless no-recompile (sct:compile-system :mvl :query nil :silent t
					      :no-warn t))
     (sct:reap-protect-system :mvl :include-components nil :query nil :silent t
			      :reap-protect nil :version :released)
     (sct:reap-protect-system :mvl :include-components nil :query nil
			      :silent t)
     (sct:release-system :mvl (sct:get-system-version :mvl) :reap-protect nil))
   (progn
     no-recompile			;prevent compiler warning
     (warn "Version release is implemented for Symbolics operating ~
system only."))))

;; MVL file-system interface.

;; Return a pathname, merging with the system default pathname.

(defun mvl-file (file &optional (ext "mvl") &key no-error)
  (unless (pathname-type file)
    (setq file (make-pathname :type ext :defaults file)))
  (let ((pathname (merge-pathnames file (system-default-pathname :mvl))))
    (or (probe-file pathname)
	(and no-error pathname)
	(cerror "Prompt for replacement pathname"
		"MVL File not found for ~:@(~A~)." pathname)
	(progn
	  (format t "~%New pathname: ")
	  (mvl-file (read-line))))))

;; Steve Added these debug features

(defun sw-debug () 
   (setq *debug-print-level* 10)
   (setq *debug-print-length* 10) )

