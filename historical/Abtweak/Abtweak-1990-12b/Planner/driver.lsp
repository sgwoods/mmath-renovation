(defvar *ofile* nil)

(defun driver (initial goal &key 
                                 (planner-mode 'tweak)
                                 (msp-mode        nil) 
                                 (msp-weak-mode  'nec) 
                                 (abs-goal        nil)
                                 (td-mode         nil)
                                 (crit-depth-mode nil)
                                 (determine-mode  'first)
                                 (backwards-mode  nil)
                                 (k-learn-mode    nil)
                                 (debug-mode      nil)
                                 (search-type      '4)
                                 (heuristic        'd)
                                 (dfs-depth-limit  20)
                                 (verbose-p       nil)
                                 (print-opt-p       t)
                                 (output-file     "default-output"))

   (setq *ofile* (open output-file :direction :output))
   (setq *trace-output* *ofile*)

   (print-title *ofile*
                        *domain*
                        *operators*
                        initial
                        goal
                        *critical-list*
                        *critical-loaded*
                        *top-down-levels*
                        *k-list*)

    (time 
            (planner initial goal :planner-mode     planner-mode
                                  :msp-mode         msp-mode
                                  :msp-weak-mode    msp-weak-mode
                                  :abs-goal         abs-goal
                                  :td-mode          td-mode
                                  :crit-depth-mode  crit-depth-mode
                                  :determine-mode   determine-mode
                                  :backwards-mode   backwards-mode
                                  :k-learn-mode     k-learn-mode
                                  :debug-mode       debug-mode
                                  :search-type      search-type
                                  :heuristic        heuristic
                                  :dfs-depth-limit  dfs-depth-limit
                                  :verbose-p        verbose-p
                                  :print-opt-p      print-opt-p))

          (print-results *ofile* 
                                 *domain*
                                 *mode*
                                 *abs-goal*
                                 *search*
                                 *heuristic*
                                 *debug*
                                 *determine-mode*
                                 *backwards*
                                 *numexpanded*
                                 *numgenerated*
                                 *solution-depth*
                                 *confl-count*
                                 *count*
                                 (compute-all-br)
                                 (find-initial-k-val)
                                 *crit-depth-mode*
                                 *k-learn-mode*
                                 *td-mode*
                                 *top-down-num*
                                 *msp-mode*
                                 *msp-weak-mode*
                                 *w-msp-pruned*
                                 *s-msp-pruned*
                                 *ab-count*
                                 *goal*)

      (close *ofile*))  ; end of driver
   
(defun print-title (stream do op init go crl crlo tdl kl)
  "print-title"
  (format stream "~&planner driver output")
  (format stream "~&domain      : ~a" do)
  (format stream "~&operators   : ~a" op)
  (format stream "~&initial     : ~a" init)
  (format stream "~&goal        : ~a" go)
  (format stream "~&critical lst: ~a" crl)
  (format stream "~&critcal load: ~a" crlo)
  (format stream "~&top down lev: ~a" tdl)
  (format stream "~&crit dep lst: ~a" kl)
  (format stream "~& ~& ")
 )

(defun print-results (stream do mo abs se h de det bac ex ge sd cfc cc bra k kd kl td tdp ms mspw w s ab gp)
  (format stream "~& solution found ")
  (format stream "~& ")
  (format stream "~& (domain info)")
  (format stream "~& domain          : ~a" do)
  (format stream "~& ")
  (format stream "~& (planning info)")
  (format stream "~& planner mode    : ~a" mo)
  (format stream "~& search  type    : ~a" se)
  (format stream "~& heuristic       : ~a" h)
  (format stream "~& debug           : ~a" de)
  (format stream "~& determine mode  : ~a" det)
  (format stream "~& backwards mode  : ~a" bac)
  (format stream "~& nodes expanded  : ~a" ex)
  (format stream "~& nodes generated : ~a" ge)
  (format stream "~& solution depth  : ~a" sd)
  (format stream "~& max conflicts   : ~a" cfc)
  (format stream "~& max node succ   : ~a" cc)
  (format stream "~& branch factors  : ~a" bra)
  (format stream "~& ")   
  (format stream "~& a: criticality levels     : ~a" k)
  (format stream "~& a: critical depth mode    : ~a" kd)
  (format stream "~& a: k learning mode        : ~a" kl)
  (format stream "~& a: top down flag             : ~a" td)
  (format stream "~& a: top down pruned           : ~a" tdp)
  (format stream "~& a: abs goal mode             : ~a" abs)
  (format stream "~& a: monotonic sol property    : ~a" ms)
  (format stream "~& a: msp weak mode             : ~a" mspw)
  (format stream "~& a: weak msp   pruned         : ~a" w)
  (format stream "~& a: strong msp pruned         : ~a" s)
  (format stream "~& a: abstract nodes gen        : ~a" ab)
  (format stream "~& ")
  (format stream "~& ")
  (format stream "~& goal plan: ~a" gp)
  (format stream "~& ") )

