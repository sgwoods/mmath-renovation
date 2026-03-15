(defun compile-all ()

(compile-file "../Planner/Search/graphsearch.lsp")
(compile-file "../Planner/Search/interface.lsp")
(compile-file "../Planner/Search/list-access.lsp")
(compile-file "../Planner/Search/node-access.lsp")
(compile-file "../Planner/Search/search.lsp")
(compile-file "../Planner/Search/state-expansion.lsp")

(compile-file "../Planner/planner.lsp")
(compile-file "../Planner/branch.lsp")
(compile-file "../Planner/driver.lsp")

(compile-file "../Tweak2/general.lsp")
(compile-file "../Tweak2/structs.lsp")
(compile-file "../Tweak2/mtc.lsp")
(compile-file "../Tweak2/successors.lsp")
(compile-file "../Tweak2/tree.lsp")

(compile-file "../Tweak2/Succ/find-new-ests.lsp")
(compile-file "../Tweak2/Succ/select-ops.lsp")
(compile-file "../Tweak2/Succ/find-exist-ests.lsp")
(compile-file "../Tweak2/Succ/find-pos-exist-ests.lsp")
(compile-file "../Tweak2/Succ/find-nec-exist-ests.lsp")

(compile-file "../Tweak2/Conf-infer/classify.lsp")
(compile-file "../Tweak2/Conf-infer/declob.lsp")
(compile-file "../Tweak2/Conf-infer/conflict-detection.lsp")
(compile-file "../Tweak2/Conf-infer/intermed-access.lsp")

(compile-file "../Tweak2/Plan-infer/plan-dependent.lsp")
(compile-file "../Tweak2/Plan-infer/plan-inference.lsp")
(compile-file "../Tweak2/Plan-infer/cr-access.lsp")
(compile-file "../Tweak2/Plan-infer/plan-modification.lsp")
(compile-file "../Tweak2/Plan-infer/show-plan.lsp")

(compile-file "../Tweak2/debug.lsp")

(compile-file "../AbTweak2/ab-mtc.lsp")
(compile-file "../AbTweak2/ab-succ.lsp")
(compile-file "../AbTweak2/ab-causal.lsp")
(compile-file "../AbTweak2/ab-msp.lsp")
(compile-file "../AbTweak2/ab-mono.lsp")

(compile-file  "../Planner/init.lsp")
(compile-file  "../Tweak2/init.lsp")
(compile-file  "../AbTweak2/init.lsp")
(compile-file  "../Planner/Search/search-load.lsp")
(compile-file  "../Planner/compile.lsp")

(compile-file  "../Planner/Domains/robot.lsp")
(compile-file  "../Planner/Domains/blocks.lsp")
(compile-file  "../Planner/Domains/nils-blocks.lsp")
(compile-file  "../Planner/Domains/hanoi-2.lsp")
(compile-file  "../Planner/Domains/hanoi-3.lsp")
(compile-file  "../Planner/Domains/hanoi-4.lsp")

(load "../Planner/init")

)
