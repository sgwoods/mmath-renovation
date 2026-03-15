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
  *)
    echo "Unknown smoke test case: $CASE_NAME" >&2
    echo "Known cases: load, loop-tweak, hanoi3-tweak, hanoi3-abtweak, hanoi4-tweak, hanoi4-abtweak, registers-tweak, blocks-sussman-tweak, blocks-sussman-abtweak, macro-hanoi-tweak, macro-hanoi-abtweak, robot2-tweak, robot2-abtweak, robot2-abtweak-no-lw" >&2
    exit 2
    ;;
esac

cd "$WORKDIR"
exec "$SBCL_BIN" --noinform --disable-debugger --eval "$EVAL" --quit
