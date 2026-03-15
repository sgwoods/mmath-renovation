(load-nils)

(load "/u/sgwoods/Plan/Planner/Domains/nils/crit6")

(driver initial goal 
:planner-mode 'abtweak
:determine-mode 'tree
:msp-mode 'weak
:msp-weak-mode 'nec
:output-file "/u/sgwoods/Plan/Planner/Batcher/nils/tree/crit6-3.1119")

(bye)

