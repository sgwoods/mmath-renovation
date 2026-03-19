; Mail header preserved from the historical 1992 source snapshot.
; From nbenhass Wed Mar 18 17:56:07 1992
; Received: by logos.waterloo.edu id <168719>; Wed, 18 Mar 1992 17:56:01 -0500
; From: Nadia BenHassine <nbenhass>
; To: qyang
; Subject: stylistics domain
; Return-Receipt-To: nbenhass
; Message-Id: <92Mar18.175601est.168719@logos.waterloo.edu>
; Date: Wed, 18 Mar 1992 17:55:55 -0500
; Status: RO
;
;***************************************************************************
; stylistics domain definition
;***************************************************************************
(setq *domain* 'stylistics)

; operators

;stylistic goals
    
(setq g1 (make-operator
          :opid 'clarity2
          :name '(clarity2 $z)
          :cost 1
          :preconditions '((resolution2 $z))
          :effects '((clarity2 $z))))


(setq g2 (make-operator
          :opid 'clarity1
          :name '(clarity1 $z)
          :cost 1
          :preconditions '((resolution1 $z))
          :effects '((clarity1 $z))))

(setq g3 (make-operator
          :opid 'clarity0
          :name '(clarity0 $z)
          :cost 1
          :preconditions '((resolution0 $z))
          :effects '((clarity0 $z))))

(setq g4 (make-operator
          :opid 'obscurity2
          :name '(obscurity2 $z)
          :cost 1
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord2 $x)
                           (discord2 $y))
          :effects '((obscurity2 $z))))


;(setq g5 (make-operator
;          :opid 'obscurity2
;          :name '(obscurity2 $z)
;          :cost 1
;          :preconditions '((polyschematic2 $z))
;          :effects '((obscurity2 $z))))


(setq g6 (make-operator
          :opid 'obscurity1
          :name '(obscurity1 $z)
          :cost 1
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord1 $x)
                           (discord2 $y))
          :effects '((obscurity1 $z))))

(setq g7 (make-operator
          :opid 'obscurity1
          :name '(obscurity1 $z)
          :cost 2 
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord2 $x)
                           (discord1 $y))
          :effects '((obscurity1 $z))))


(setq g8 (make-operator
          :opid 'obscurity1
          :name '(obscurity1 $z)
          :cost 3 
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord1 $x)
                           (discord1 $y))
          :effects '((obscurity1 $z))))


;(setq g9 (make-operator
;          :opid 'obscurity1
;          :name '(obscurity1 $z)
;          :cost 4 
;          :preconditions '((polyschematic1 $z))
;          :effects '((obscurity1 $z))))


(setq g10 (make-operator
          :opid 'obscurity0
          :name '(obscurity0 $z)
          :cost 1
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord0 $x)
                           (discord1 $y))
          :effects '((obscurity0 $z))))

(setq g11 (make-operator
          :opid 'obscurity0
          :name '(obscurity0 $z)
          :cost 2
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord1 $x)
                           (discord0 $y))
          :effects '((obscurity0 $z))))


(setq g12 (make-operator
          :opid 'obscurity0
          :name '(obscurity0 $z)
          :cost 3
          :preconditions '((initial-pos $x)
                           (final-pos $y)
                           (discord0 $x)
                           (discord0 $y))
          :effects '((obscurity0 $z))))


;(setq g13 (make-operator
;          :opid 'obscurity0
;          :name '(obscurity0 $z)
;          :cost 4
;          :preconditions '((polyschematic0 $z))
;          :effects '((obscurity0 $z))))

(setq g14 (make-operator
           :opid 'concreteness2
           :name '(concreteness2 $z)
           :cost 1
           :preconditions '((dissolution2 $z))
           :effects '((concreteness2 $z))))

(setq g15 (make-operator
           :opid 'concreteness2
           :name '(concreteness2 $z)
           :cost 2 
           :preconditions '((final-pos $y)
                            (discord2 $y))
           :effects '((concreteness2 $z))))

(setq g16 (make-operator
           :opid 'concreteness2
           :name '(concreteness2 $z)
           :cost 3 
           :preconditions '((initial-pos $x)
                            (discord2 $x))
           :effects '((concreteness2 $z))))

(setq g17 (make-operator
           :opid 'concreteness1
           :name '(concreteness1 $z)
           :cost 1
           :preconditions '((dissolution1 $z))
           :effects '((concreteness1 $z))))

(setq g18 (make-operator
           :opid 'concreteness1
           :name '(concreteness1 $z)
           :cost 2
           :preconditions '((final-pos $y)
                            (discord1 $y))
           :effects '((concreteness1 $z))))

(setq g19 (make-operator
           :opid 'concreteness1
           :name '(concreteness1 $z)
           :cost 3
           :preconditions '((initial-pos $x)
                            (discord1 $x))
           :effects '((concreteness1 $z))))


(setq g20 (make-operator
           :opid 'concreteness0
           :name '(concreteness0 $z)
           :cost 1
           :preconditions '((dissolution0 $z))
           :effects '((concreteness0 $z))))

(setq g21 (make-operator
           :opid 'concreteness0
           :name '(concreteness0 $z)
           :cost 2
           :preconditions '((final-pos $y)
                            (discord0 $y))
           :effects '((concreteness0 $z))))

(setq g22 (make-operator
           :opid 'concreteness0
           :name '(concreteness0 $z)
           :cost 3
           :preconditions '((initial-pos $x)
                            (discord0 $x))
           :effects '((concreteness0 $z))))

(setq g23 (make-operator
           :opid 'dynamism2
           :name '(dynamism2 $z)
           :cost 1
           :preconditions '((dissolution2 $z))
           :effects '((dynamism2 $z))))

(setq g24 (make-operator
           :opid 'dynamism2
           :name '(dynamism2 $z)
           :cost 2
           :preconditions '((final-pos $y)
                            (discord2 $y))
           :effects '((dynamism2 $z))))

(setq g25 (make-operator
           :opid 'dynamism2
           :name '(dynamism2 $z)
           :cost 3
           :preconditions '((initial-pos $x)
                            (discord2 $x))
           :effects '((dynamism2 $z))))

(setq g26 (make-operator
           :opid 'dynamism1
           :name '(dynamism1 $z)
           :cost 1
           :preconditions '((dissolution1 $z))
           :effects '((dynamism1 $z))))

(setq g27 (make-operator
           :opid 'dynamism1
           :name '(dynamism1 $z)
           :cost 2
           :preconditions '((final-pos $y)
                            (discord1 $y))
           :effects '((dynamism1 $z))))

(setq g28 (make-operator
           :opid 'dynamism1
           :name '(dynamism1 $z)
           :cost 3
           :preconditions '((initial-pos $x)
                            (discord1 $x))
           :effects '((dynamism1 $z))))


(setq g29 (make-operator
           :opid 'dynamism0
           :name '(dynamism0 $z)
           :cost 1
           :preconditions '((dissolution0 $z))
           :effects '((dynamism0 $z))))

(setq g30 (make-operator
           :opid 'dynamism0
           :name '(dynamism0 $z)
           :cost 2
           :preconditions '((final-pos $y)
                            (discord0 $y))
           :effects '((dynamism0 $z))))

(setq g31 (make-operator
           :opid 'dynamism0
           :name '(dynamism0 $z)
           :cost 3
           :preconditions '((initial-pos $x)
                            (discord0 $x))
           :effects '((dynamism0 $z))))


;abstract elements

(setq a (make-operator
	 :opid 'resolution2
	 :name '(resolution2 $z)
	 :cost 1
	 :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (discord2 $x)
			  (concord $y))
	 :effects '((resolution2 $z))))


(setq b (make-operator
         :opid 'resolution1
         :name '(resolution1 $z)
         :cost 1
         :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (discord1 $x)
                          (concord $y))
         :effects '((resolution1 $z))))

(setq c (make-operator
         :opid 'resolution0
         :name '(resolution0 $z)
         :cost 1
         :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (discord0 $x)
                          (concord $y))
         :effects '((resolution0 $z))))



(setq d (make-operator
         :opid 'dissolution2
         :name '(dissolution2 $z)
         :cost 1
         :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (concord $x)
                          (discord2 $y))
         :effects '((dissolution2 $z))))


(setq e (make-operator
         :opid 'dissolution1
         :name '(dissolution1 $z)
         :cost 1
         :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (concord $x)
                          (discord1 $y))
         :effects '((dissolution1 $z))))

(setq f (make-operator
         :opid 'dissolution0
         :name '(dissolution0 $z)
         :cost 1
         :preconditions '((initial-pos $x)
                          (final-pos $y)
                          (concord $x)
                          (discord0 $y))
         :effects '((dissolution0 $z))))

;primitive elements

(setq g (make-operator
         :opid 'discord2a 
         :name '(discord2a $x $y)
         :cost 1
         :preconditions '((inverted-clause $x))
         :effects '((discord2 $x)
                    (initial-pos $y)
                    (final-pos $x)
                    (not initial-pos $x)
                    (not final-pos $y))))


(setq h (make-operator
         :opid 'discord2b
         :name '(discord2b $x)
         :cost 2 
         :preconditions '((excessive-clauses $x))
         :effects '((discord2 $x))))


(setq i (make-operator
         :opid 'discord2c
         :name '(discord2c $x)
         :cost 3 
         :preconditions '((excessive-postmod $x))
         :effects '((discord2 $x))))


(setq j (make-operator
         :opid 'discord1a
         :name '(discord1a $x)
         :cost 1
         :preconditions '((excessive-pp $x))
         :effects '((discord1 $x))))



(setq k (make-operator
         :opid 'discord1b
         :name '(discord1b $x)
         :cost 2 
         :preconditions '((postmod-adj $x))
         :effects '((discord1 $x))))



(setq l (make-operator
         :opid 'discord1c
         :name '(discord1c $x)
         :cost 3
         :preconditions '((excessive-premod $x))
         :effects '((discord1 $x))))


(setq m (make-operator
         :opid 'discord0a
         :name '(discord0a $x)
         :cost 1
         :preconditions '((dependant-clause $x))
         :effects '((discord0 $x))))


(setq n (make-operator
         :opid 'discord0b
         :name '(discord0b $x)
         :cost 2 
         :preconditions '((prep-phrase $x))
         :effects '((discord0 $x))))



(setq o (make-operator
         :opid 'concorda
         :name '(concorda $x)
         :cost 1
         :preconditions '()
;                          (not discord2 $x)
;                          (not discord1 $x)
;                          (not discord0 $x))

         :effects '((concord $x))))




(setq *operators* (list g1 g2 g3 g4 g6 g7 g8 g10 g11 g12 g14 g15 
                   g16 g17 g18 g19 g20 g21 g22 g23 g24 g25 g26 g27
                   g28 g29 g30 g31
                   a b c d e f g h i j k l m n o))

; historical sample task
;
;(setq initial '((initial-pos a) (final-pos b)
;                (excessive-pp a) (excessive-postmod a) ))
;                (excessive-premod b) ))


;goal state
;
;(setq goal '((clarity1 c) ))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************


(setq *critical-list* '(
   (2  (clarity2 $) (not clarity2 $)
       (clarity1 $) (not clarity1 $)
       (clarity0 $) (not clarity0 $)
       (obscurity2 $) (not obscurity2 $)
       (obscurity1 $) (not obscurity1 $)
       (obscurity0 $) (not obscurity0 $)
       (concreteness2 $) (not concreteness2 $)
       (concreteness1 $) (not concreteness1 $)
       (concreteness0 $) (not concreteness0 $)
       (dynamism2 $) (not dynamism2 $)
       (dynamism1 $) (not dynamism1 $)
       (dynamism0 $) (not dynamism0 $)
       (initial-pos $) (not initial-pos $)
       (final-pos $) (not final-pos $))
   (1  (resolution2 $) (not resolution2 $)
       (resolution1 $) (not resolution1 $)
       (resolution0 $) (not resolution0 $)
       (dissolution2 $) (not dissolution2 $)
       (dissolution1 $) (not dissolution1 $)
       (dissolution0 $) (not dissolution0 $))
   (0  (discord2 $) (not discord2 $)
       (discord1 $) (not discord1 $)
       (discord0 $) (not discord0 $)
       (concord $) (not concord $)
       (excessive-premod $) (not excessive-premod $)
       (excessive-clauses $) (not excessive-clauses $)
       (excessive-postmod $) (not excessive-postmod $)
       (excessive-pp $) (not excessive-pp $)
       (excessive-postmod-adj $) (not excessive-postmod-adj $)
       (inverted-clause $) (not inverted-clause $) 
       (dependant-clause $) (not dependant-clause $)
       (prep-phrase $) (not prep-phrase $)
       (postmod-adj $) (not postmod-adj $))
      
 ))


(setq *critical-loaded* 'style-default)

(setq *left-wedge-list* '(0 1 5))
