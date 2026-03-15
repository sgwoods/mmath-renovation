; this plan is arrived at via explanation closure axioms and deduction - nov 23
;  talk by len schubert !
;
; what is the cost of arriving at this plan in this manner?
;

(setq sample
'#s(plan id |plan2200| cost 0 kval 0 cr nil tree (g)
        a
        (
         #s(operator opid i name (i) preconditions nil effects
               ((ispeg peg1) (ispeg peg2) (ispeg peg3) (onb peg1)
                (onm peg1) (ons peg1) (not onb peg2) (not onb peg3)
                (not onm peg2) (not onm peg3) (not ons peg2)
                (not ons peg3)))
        #s(operator opid op1 name (moves peg1 $1) preconditions
               ((ispeg peg1) (ispeg $1) (ons peg1)) effects
               ((not ons peg1) (ons $1)))
         #s(operator opid op2 name (movem peg1 $2) preconditions
               ((ispeg peg1) (ispeg $2) (not ons peg1) (not ons $2)
                (onm peg1))
               effects ((not onm peg1) (onm peg2)))
         #s(operator opid op3 name (moveb peg1 peg3) preconditions
               ((ispeg peg1) (ispeg peg3) (not ons peg1) (not onm peg1)
                (not ons peg3) (not onm peg3) (onb peg1))
               effects ((not onb peg1) (onb peg3)))
         #s(operator opid op4 name (movem $3 peg3) preconditions
               ((ispeg $3) (ispeg peg3) (not ons $3) (not ons peg3)
                (onm $3))
               effects ((not onm $3) (onm peg3)))
        #s(operator opid op5 name (moves $4 peg3) preconditions
               ((ispeg $4) (ispeg peg3) (ons $4)) effects
               ((not ons $4) (ons peg3)))
         #s(operator opid g name (g) preconditions
               ((onb peg3) (onm peg3) (ons peg3)) effects nil))
        b
        ( (i op1) (op1 op2) (op2 op3) (op3 op4) (op4 op5) (op5 g) )
        nc ( ($1 peg1) ($2 peg1) ($3 peg3) ($4 peg3) )
       var ($1 $2 $3 $4) conflicts nil op-count nil invalid nil)
)

