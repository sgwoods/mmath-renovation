echo 
echo PLANNER DIRECTORY

echo
echo PLANNER:  /u/sgwoods/Plan/Planner/
echo

cd /u/sgwoods/Plan/Planner

echo init
echo 
cat init.lsp     | grep \(def
echo

echo planner
echo
cat planner.lsp  | grep \(def
echo

echo driver
cat driver.lsp   | grep \(def
echo

echo branch
cat branch.lsp   | grep \(def
echo

echo
echo SEARCH: /u/sgwoods/Plan/Planner/Search
echo

cd /u/sgwoods/Plan/Planner/Search

echo graphsearch
echo
cat graphsearch.lsp | grep \(def
echo

echo interface
echo
cat interface.lsp | grep \(def
echo

echo list-access
echo
cat list-access.lsp | grep \(def
echo

echo node-access
echo
cat node-access.lsp | grep \(def
echo

echo search-load
echo
cat search-load.lsp | grep \(def
echo

echo search
echo
cat search.lsp | grep \(def
echo

echo state-expansion
echo
cat state-expansion.lsp | grep \(def
echo

echo
echo TWEAK: /u/sgwoods/Plan/Planner/Tweak2/
echo

cd /u/sgwoods/Plan/Tweak2

echo debug
echo
cat debug.lsp | grep \(def
echo

echo general
echo
cat general.lsp | grep \(def
echo

echo init
echo
cat init.lsp | grep \(def
echo

echo mtc
echo
cat mtc.lsp | grep \(def
echo

echo structs
echo
cat structs.lsp | grep \(def
echo

echo successors
echo
cat successors.lsp | grep \(def
echo

echo tree
echo
cat tree.lsp | grep \(def
echo

echo 
echo /u/sgwoods/Plan/Planner/Tweak2/Succ
echo

cd /u/sgwoods/Plan/Tweak2/Succ

echo find-exist-ests
echo
cat find-exist-ests.lsp | grep \(def
echo

echo find-nec-exist-ests
echo
cat find-nec-exist-ests.lsp | grep \(def
echo

echo find-new-ests
echo
cat find-new-ests.lsp | grep \(def
echo

echo find-pos-exist-ests
echo
cat find-pos-exist-ests.lsp | grep \(def
echo

echo select-ops
echo
cat select-ops.lsp | grep \(def
echo

echo 
echo /u/sgwoods/Plan/Planner/Tweak2/Conf-infer
echo

cd /u/sgwoods/Plan/Tweak2/Conf-infer

echo classify
echo
cat classify.lsp | grep \(def
echo

echo conflict-detection
echo
cat conflict-detection.lsp | grep \(def
echo

echo declob
echo
cat declob.lsp | grep \(def
echo

echo intermed-access
echo
cat intermed-access.lsp | grep \(def
echo

echo 
echo /u/sgwoods/Plan/Planner/Tweak2/Plan-infer
echo

cd /u/sgwoods/Plan/Tweak2/Plan-infer

echo cr-access
echo
cat cr-access.lsp | grep \(def
echo

echo plan-dependent
echo
cat plan-dependent.lsp | grep \(def
echo

echo plan-inference
echo
cat plan-inference.lsp | grep \(def
echo

echo plan-modification
echo
cat plan-modification.lsp | grep \(def
echo

echo show-plan
echo
cat show-plan.lsp | grep \(def
echo

echo
echo ABTWEAK: /u/sgwoods/Plan/Planner/AbTweak2/
echo

cd /u/sgwoods/Plan/AbTweak2

echo init
echo
cat init.lsp | grep \(def
echo

echo ab-causal
echo
cat ab-causal.lsp | grep \(def
echo

echo ab-mono
echo
cat ab-mono.lsp | grep \(def
echo

echo ab-msp
echo
cat ab-msp.lsp | grep \(def
echo

echo ab-mtc
echo
cat ab-mtc.lsp | grep \(def
echo

echo ab-succ
echo
cat ab-succ.lsp | grep \(def
echo

