; /planner/domains/load-functions.lsp

(defun load-nils ()
   "/planner/domains/load-functions.lsp
    load nilsson blocks world definition"
    (load "/u/sgwoods/Plan/Planner/Domains/nils-blocks.lsp")
    (show-dom) )

(defun load-hanoi2 ()
   "/planner/domains/load-functions.lsp
    load tower of hanoi - 2 rings"
    (load "/u/sgwoods/Plan/Planner/Domains/hanoi-2.lsp")
    (show-dom) )

(defun load-blocks ()
   "/planner/domains/load-functions.lsp
    load blocks world"
    (load "/u/sgwoods/Plan/Planner/Domains/blocks.lsp")
    (show-dom) )

(defun load-hanoi3 ()
   "/planner/domains/load-functions.lsp
    load tower of hanoi - 3 rings"
    (load "/u/sgwoods/Plan/Planner/Domains/hanoi-3.lsp")
    (show-dom) )

(defun load-hanoi4 ()
   "/planner/domains/load-functions.lsp
    load tower of hanoi - 4 rings"
    (load "/u/sgwoods/Plan/Planner/Domains/hanoi-4.lsp")
    (show-dom) )

(defun compile-dom ()
   "/planner/domains/load-functions.lsp
    compile domains included"
    (compile-file "/u/sgwoods/Plan/Planner/Domains/hanoi-2.lsp")
    (compile-file "/u/sgwoods/Plan/Planner/Domains/hanoi-3.lsp")
    (compile-file "/u/sgwoods/Plan/Planner/Domains/hanoi-4.lsp")
    (compile-file "/u/sgwoods/Plan/Planner/Domains/blocks.lsp")
    (compile-file "/u/sgwoods/Plan/Planner/Domains/nils-blocks.lsp") )

