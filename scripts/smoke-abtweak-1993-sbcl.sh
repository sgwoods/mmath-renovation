#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
CASE_NAME=${1:-blocks-sussman-tweak}

case "$CASE_NAME" in
  load)
    EVAL='(progn (load "init-sbcl.lisp") (format t "SBCL init load succeeded.~%"))'
    ;;
  loop-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/loop.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 50
                          :generate-bound 100
                          :open-bound 100
                          :cpu-sec-limit 10)))
        (format t "CASE: loop-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*))))))'
    ;;
  hanoi3-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: hanoi3-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  hanoi3-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: hanoi3-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  hanoi4-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/hanoi-4.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 20000
                          :generate-bound 80000
                          :open-bound 80000
                          :cpu-sec-limit 30)))
        (format t "CASE: hanoi4-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  hanoi4-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/hanoi-4.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 20000
                          :generate-bound 80000
                          :open-bound 80000
                          :cpu-sec-limit 30)))
        (format t "CASE: hanoi4-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  registers-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/registers.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 2000
                          :cpu-sec-limit 10)))
        (format t "CASE: registers-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  registers-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/registers.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: registers-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-sussman-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 2000
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-sussman-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 2000
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-interchange-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (interchange)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: blocks-interchange-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-interchange-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (interchange)
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: blocks-interchange-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-flatten-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (flatten)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: blocks-flatten-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-flatten-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (flatten)
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: blocks-flatten-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-sussman-tweak-dfs)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :control-strategy (quote dfs)
                          :solution-limit 6
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 8000
                          :open-bound 8000
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-tweak-dfs~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-sussman-abtweak-dfs)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :control-strategy (quote dfs)
                          :solution-limit 6
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 8000
                          :open-bound 8000
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-abtweak-dfs~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  blocks-sussman-generate-bound)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 5
                          :open-bound 2000
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-generate-bound~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)) )'
    ;;
  blocks-sussman-open-bound)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/blocks.lisp")
      (sussman)
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 3
                          :cpu-sec-limit 10)))
        (format t "CASE: blocks-sussman-open-bound~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)) )'
    ;;
  nils-blocks-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/nils-blocks.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 8000
                          :open-bound 8000
                          :cpu-sec-limit 10)))
        (format t "CASE: nils-blocks-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (format t "MP-PRUNED: ~S~%" *mp-pruned*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  nils-blocks-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/nils-blocks.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 8000
                          :open-bound 8000
                          :cpu-sec-limit 10)))
        (format t "CASE: nils-blocks-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (format t "MP-PRUNED: ~S~%" *mp-pruned*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  nils-blocks-abtweak-no-mp)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/nils-blocks.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :mp-mode nil
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 10)))
        (format t "CASE: nils-blocks-abtweak-no-mp~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (format t "MP-PRUNED: ~S~%" *mp-pruned*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  macro-hanoi-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/macro-hanoi.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 20000
                          :generate-bound 80000
                          :open-bound 80000
                          :cpu-sec-limit 30)))
        (format t "CASE: macro-hanoi-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  macro-hanoi-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/macro-hanoi.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 20000
                          :generate-bound 80000
                          :open-bound 80000
                          :cpu-sec-limit 30)))
        (format t "CASE: macro-hanoi-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  macro-hanoi4-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/macro-hanoi.lisp")
      (let ((result (plan initial-4 goal-4
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 20)))
        (format t "CASE: macro-hanoi4-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  macro-hanoi4-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/macro-hanoi.lisp")
      (let ((result (plan initial-4 goal-4
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 20)))
        (format t "CASE: macro-hanoi4-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot2-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-2.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: robot2-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot2-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-2.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: robot2-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot2-abtweak-no-lw)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-2.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :left-wedge-mode nil
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: robot2-abtweak-no-lw~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot1-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-1.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 12000
                          :generate-bound 50000
                          :open-bound 50000
                          :cpu-sec-limit 60)))
        (format t "CASE: robot1-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot1-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-1.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: robot1-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  robot1-abtweak-no-lw)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/robot-heuristic.lisp")
      (load "Domains/simple-robot-1.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :heuristic-mode (quote user-defined)
                          :use-primary-effect-p t
                          :left-wedge-mode nil
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 20000
                          :open-bound 20000
                          :cpu-sec-limit 30)))
        (format t "CASE: robot1-abtweak-no-lw~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  computer-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/computer.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: computer-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  computer-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/computer.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: computer-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  stylistics-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/stylistics.lisp")
      (setq initial (quote ((initial-pos a) (final-pos b)
                            (excessive-pp a) (excessive-postmod a))))
      (setq goal (quote ((clarity1 c))))
      (let ((result (plan initial goal
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 2000
                          :cpu-sec-limit 15)))
        (format t "CASE: stylistics-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  stylistics-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/stylistics.lisp")
      (setq initial (quote ((initial-pos a) (final-pos b)
                            (excessive-pp a) (excessive-postmod a))))
      (setq goal (quote ((clarity1 c))))
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 500
                          :generate-bound 2000
                          :open-bound 2000
                          :cpu-sec-limit 15)))
        (format t "CASE: stylistics-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
        (format t "NUM-GENERATED: ~S~%" *num-generated*)
        (format t "MP-PRUNED: ~S~%" *mp-pruned*)
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  biology-goal1-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/biology.lisp")
      (let ((result (plan initial goal1
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: biology-goal1-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  biology-goal1-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/biology.lisp")
      (let ((result (plan initial goal1
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 20)))
        (format t "CASE: biology-goal1-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  biology-goal2-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/biology.lisp")
      (let ((result (plan initial goal2
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: biology-goal2-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  biology-goal3-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/biology.lisp")
      (let ((result (plan initial goal3
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: biology-goal3-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  biology-full-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/biology.lisp")
      (let ((result (plan initial goal
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: biology-full-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  fly-sf-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/fly.lisp")
      (let ((result (plan initial goal-sf
                          :planner-mode (quote tweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 15)))
        (format t "CASE: fly-sf-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  fly-sf-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/fly.lisp")
      (let ((result (plan initial goal-sf
                          :planner-mode (quote abtweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 15)))
        (format t "CASE: fly-sf-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  fly-dc-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/fly.lisp")
      (let ((result (plan initial goal-dc
                          :planner-mode (quote tweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 5000
                          :open-bound 5000
                          :cpu-sec-limit 15)))
        (format t "CASE: fly-dc-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  fly-dc-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/fly.lisp")
      (let ((result (plan initial goal-dc
                          :planner-mode (quote abtweak)
                          :use-primary-effect-p t
                          :output-file (quote no-output)
                          :expand-bound 1000
                          :generate-bound 4000
                          :open-bound 4000
                          :cpu-sec-limit 20)))
        (format t "CASE: fly-dc-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal0-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init0 goal0
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 8000
                          :open-bound 8000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal0-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal1-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init1 goal1
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal1-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal1-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init1 goal1
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 2000
                          :generate-bound 10000
                          :open-bound 10000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal1-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal2-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init2 goal2
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal2-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal2-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init2 goal2
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal2-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal3-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init3 goal3
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal3-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal3-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init3 goal3
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal3-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal4-tweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init4 goal4
                          :planner-mode (quote tweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal4-tweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  database-goal4-abtweak)
    EVAL='(progn
      (load "init-sbcl.lisp")
      (load "Domains/database.lisp")
      (let ((result (plan init4 goal4
                          :planner-mode (quote abtweak)
                          :output-file (quote no-output)
                          :expand-bound 5000
                          :generate-bound 30000
                          :open-bound 30000
                          :cpu-sec-limit 20)))
        (format t "CASE: database-goal4-abtweak~%")
        (format t "PLAN-RESULT: ~S~%" result)
        (format t "SOLUTION-VALUE: ~S~%" *solution*)
        (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
        (when (typep *solution* (quote plan))
          (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
          (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
          (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))) )'
    ;;
  *)
    echo "Unknown smoke test case: $CASE_NAME" >&2
    echo "Known cases: load, loop-tweak, hanoi3-tweak, hanoi3-abtweak, hanoi4-tweak, hanoi4-abtweak, registers-tweak, registers-abtweak, blocks-sussman-tweak, blocks-sussman-abtweak, blocks-interchange-tweak, blocks-interchange-abtweak, blocks-flatten-tweak, blocks-flatten-abtweak, blocks-sussman-tweak-dfs, blocks-sussman-abtweak-dfs, blocks-sussman-generate-bound, blocks-sussman-open-bound, nils-blocks-tweak, nils-blocks-abtweak, nils-blocks-abtweak-no-mp, macro-hanoi-tweak, macro-hanoi-abtweak, macro-hanoi4-tweak, macro-hanoi4-abtweak, robot1-tweak, robot1-abtweak, robot1-abtweak-no-lw, robot2-tweak, robot2-abtweak, robot2-abtweak-no-lw, computer-tweak, computer-abtweak, stylistics-tweak, stylistics-abtweak, biology-goal1-tweak, biology-goal1-abtweak, biology-goal2-abtweak, biology-goal3-abtweak, biology-full-abtweak, fly-sf-tweak, fly-sf-abtweak, fly-dc-tweak, fly-dc-abtweak, database-goal0-tweak, database-goal1-tweak, database-goal1-abtweak, database-goal2-tweak, database-goal2-abtweak, database-goal3-tweak, database-goal3-abtweak, database-goal4-tweak, database-goal4-abtweak" >&2
    exit 2
    ;;
esac

cd "$WORKDIR"
exec "$SBCL_BIN" --noinform --disable-debugger --eval "$EVAL" --quit
