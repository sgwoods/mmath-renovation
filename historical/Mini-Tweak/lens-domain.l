;;;; Define some operators for a machine shop that
;;;; specializes in making lenses.  Because variables
;;;; cannot be used, these rules implictly assume some
;;;; object is under consideration.

;; The GRIND-CONCAVITY operator requires a solid object
;; and produces a concavity in it.  However, this concavity
;; is rough and dirty.
(build-operator grind-concavity
	( solid ) 
	( concave (NOT smooth) (NOT clean) ))
;; The POLISH operator requires a clean object
;; and smooths it.
(build-operator polish
	( clean ) 
	( smooth ))
;; The ALUMINIZE operator requires a clean, solid object
;; and makes it reflective, but leaves a mess.
(build-operator aluminize
	( clean solid ) 
	( reflective (NOT clean) ))
;; The VACUUM operator cleans up anything solid.
(build-operator vacuum
	( solid ) 
	( clean ))
;; The MAKE-GLASS operator converts hot sand into glass.
(build-operator make-glass
	( sand object-is-hot)
	( (NOT sand) glass ))
;; The COOL operator removes heat.
(build-operator cool
	( )
	( (NOT object-is-hot) ))
;; The HEAT operator makes things hot, but requires fuel.
(build-operator heat
	( have-fuel )
	( (NOT have-fuel) object-is-hot ))
;; The FILL-TANK operator gets fuel.
(build-operator fill-tank
	( )
	( have-fuel ))

;;;; The "operators" below are actually inferences.

;; Glass is solid, but sand is not.
(build-operator classify-glass
	( glass )
	( solid ))
(build-operator classify-sand
	( sand )
	( (NOT solid) ))
;; The definition of a reflective lens.
(build-operator recognize-reflective-lens
	( smooth reflective clean concave)
	( reflective-lens )) 

