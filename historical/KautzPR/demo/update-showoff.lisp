;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz

;;; Demonstrates UPDATE


;; Clear the database.
(clear-all-mappings)

;;;; Hunt-rob-test : demonstrates upward inference and matching, without parameters.
;; Load the hierarchy.
(load (merge-pathnames "hunt-rob-test" test-dir))
;;
;; INCREMENTAL Solution
;;
(setq *update-type* 'i)
(init-hypoths)
;; First observation:  get-gun
(update '(get-gun))
;; There are two alternatives, with c1 as component of rob-bank or of hunt.
(display-hypoths)
;; Second observation: go-to-bank
(update '( go-to-bank))
;; Hypoths after second observation
(display-hypoths)
;;
;; NON-DICHRONIC Solution
;;
(setq *update-type* 'n)
(init-hypoths)
;; First observation:  get-gun
(update '(get-gun))
;; There are two alternatives, with c1 as component of rob-bank or of hunt.
(display-hypoths)
;; Second observation: go-to-bank
(update '( go-to-bank))
;; Hypoths after second observation
(display-hypoths)
;;
;; STICKY Solution
;;
(setq *update-type* 'n)
(init-hypoths)
;; First observation:  get-gun
(update '(get-gun))
;; There are two alternatives, with c1 as component of rob-bank or of hunt.
(display-hypoths)
;; Second observation: go-to-bank
(update '( go-to-bank))
;; Hypoths after second observation
(display-hypoths)


exit

