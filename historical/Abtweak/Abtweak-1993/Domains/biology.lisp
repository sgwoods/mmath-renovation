;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; *** From Tony Borret in U. of Washington.***
;;;
;;; Ratinsulin problem (molecular genetics)
;;;   References: Stefik's AIJ paper
;;;               Science 196 (June 1977) pg 1313
;;;               Scientific American (April 1980) pg 74
;;;
;;;
;;;   Comments:   Note how the planning problem contains variables.  
;;;
;;;               The planner produces the appropriate plan, but the
;;;               representation of how molecules get cleaved and ligated
;;;               is simplistic.  The use of a "pure" predicate
;;;               to denote the purity of a culture is another simplification.
;;;               Finally, the number of domain facts (initial conditions)
;;;               is rather impoverished.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Note from Q. Yang:  This domain satisfies DRP.  So 
;;; no point in experimenting with different refinement probabilities.

(setq o1 
      (make-operator :cost 1
       :opid 'reverse-transcribe
       :name '(reverse-transcribe $x)    ; make cDNA
       :preconditions '((mRNA $x))
       :effects     '((cDNA $x) (connected-cDNA-mRNA $x))
       :primary-effects     '((cDNA $x) (connected-cDNA-mRNA $x))))


(setq o2
      (make-operator :cost 1
       :opid 'separate
       :name '(separate $x)              ; Separate cDNA from mRNA
       :preconditions '((cDNA $x)(connected-cDNA-mRNA $x))
       :effects     '((single-strand $x)
		      (not connected-cDNA-mRNA $x))
       :primary-effects     '((single-strand $x))))

(setq o3
  (make-operator :cost 1 
   :opid 'polymerize 
   :name '(polymerize $x)            ; Turn cDNA into a double strand
   :preconditions '((cDNA $x)(single-strand $x))
   :effects     '((hair-pin $x)
		  (not single-strand $x))
   :primary-effects     '((hair-pin $x))))

(setq o4
      (make-operator :cost 1 
       :opid 'digest
       :name '(digest $x)    ; make cDNA ; Get rid of the hairpin end
       :preconditions '((cDNA $x)(hair-pin $x))         ; This makes a gene
       :effects     '((double-strand $x)
		      (not hair-pin $x))
       :primary-effects     '((double-strand $x))))

(setq o5
      (make-operator :cost 1 
       :opid 'ligate
       :name '(ligate LINKER $x)         ; prep a gene for linking
       :preconditions '((cDNA $x) (double-strand $x))
       :effects     '((cleavable $x))
       :primary-effects     '((cleavable $x))))

(setq o6
      (make-operator :cost 1 
       :opid 'cleave
       :name '(cleave $x)                ; prep molecule $x for splicing
       :preconditions '((cleavable $x))
       :effects     '((cleaved $x) (not cleavable $x))
       :primary-effects     '((cleaved $x))))

(setq o7
  (make-operator :cost 1 
   :opid 'ligate2
   :name '(ligate $x $y)             ; put gene $x into DNA $y
   :preconditions '((cleaved $x) (cleaved $y))
   :effects     '((contains $x $y)(cleavable $y)
		  (not cleaved $x) (not cleaved $y))
   :primary-effects     '((contains $x $y))))

(setq o8
      (make-operator :cost 1 
       :opid 'screen
       :name '(screen $x $y $z)             ; purify germ $x antibiotic $z
       :preconditions '((contains $y $x)                ;   Dna strand $y confers
			(resists $z $y))                ;   resistence to $z
    :effects     '((pure $x))
    :primary-effects     '((pure $x))))
(setq o9
  (make-operator :cost 1 
   :opid 'transform
   :name '(transform $x $y) ; add DNA molecule $x to organism $y
   :preconditions '((accepts $x $y) ; Is molecule accepted$
		    (bacterium $y)  ; must be a bacterium
		    (cleavable $x)) ; molecule must be whole
    :effects     '((contains $x $y)
		   (not cleavable $x))   ; cannot cleave $x when in cell
    :primary-effects     '((contains $x $y))))

(setq *operators*
      (list o1 o2 o3 o4 o5 o6 o7 o8 o9))

;;; Code for experimenting with goal priorities (Knoblock predicate dropping
;;; abstraction techninques).
(setq *critical-list* 
      '(
	(4 (resists $ $) (accepts $ $) (bacterium $) (mRNA $))
	(3 (contains $ $) (pure $))
	(2 (cleaved $) (not cleaved $))
	(1 (cleavable $) (not cleavable $))
	(0 (cDNA $) 
	    (connected-cDNA-mRNA $) (not connected-cDNA-mRNA $)
	    (single-strand $) (not single-strand $)
	    (double-strand $) (not double-strand $)
	    (hair-pin $) (not hair-pin $))))


(setq initial 
      '((mRNA insulin-gene)
	(cleavable e-coli-exosome)
	(cleavable junk-exosome)
	(accepts junk-exosome junk)
	(accepts e-coli-exosome e-coli)
	(bacterium e-coli)
	(bacterium junk)
	(resists antibiotic-1 e-coli-exosome)))

(setq goal1 
      '((contains insulin-gene $x)))


(setq goal2 
      '(
	(contains $x $y)))


(setq goal3 
      '(
	(pure $y)))

(setq goal
      '((contains insulin-gene $x)
	(contains $x $y)
	(bacterium $y)
	(pure $y)))

(setq *left-wedge-list* '(0 1 2 3 4 5 6 7))


