;; Sample .emacs file for use with MVL and Allegro EMACS interface
;;

(defvar fi:mvl-mode-map nil
  "Major mode map used when editing MVL code.")

(defun mvl-mode ()
  "Major mode for editing MVL code.
The bindings are taken from the variable `fi:common-lisp-mode-map'.
Entry to this mode calls the value of `fi:mvl-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'fi:common-lisp-mode)
  (setq mode-name "MVL")
  (set-syntax-table fi:lisp-mode-syntax-table)
  (fi::lisp-edit-mode-setup)
  (fi:parse-mode-line-and-package)
  (if (null fi:mvl-mode-map)
      (progn
	(setq fi:mvl-mode-map (make-keymap))
	(fi::lisp-mode-commands fi:mvl-mode-map nil nil)))
  (use-local-map fi:mvl-mode-map)
  (setq fi::process-name fi::common-lisp-backdoor-main-process-name)
  (setq fi:lisp-indent-hook-property 'fi:common-lisp-indent-hook)
  (run-hooks 'fi:lisp-mode-hook 'fi:common-lisp-mode-hook 'fi:mvl-mode-hook))

(defun fi:mvl-state-region ()
  "STATE the current region"
  (interactive)
  (fi::mvl-region "state-hook"))

(defun fi:mvl-state-defun ()
  "STATE the current defun"
  (interactive)
  (fi::mvl-defun "state-hook"))

(defun fi:mvl-unstate-region ()
  "UNSTATE the current region"
  (interactive)
  (fi::mvl-region "unstate-hook"))

(defun fi:mvl-unstate-defun ()
  "UNSTATE the current defun"
  (interactive)
  (fi::mvl-defun "unstate-hook"))
 
(defun fi::mvl-region (prefix)
  (fi::eval-send-with-prefix prefix
			     (min (point) (mark))
			     (max (point) (mark))))

(defun fi::mvl-defun (prefix)
  (save-excursion
    (beginning-of-defun)
    (let ((start (point)))
      (end-of-defun)
      (fi::eval-send-with-prefix prefix start (point)))))

(defun fi::eval-send-with-prefix (prefix start end)
  (fi:eval-in-lisp (concat "(" prefix (buffer-substring start end) ")")
		    nil))

(defun fi:mvl-apropos (predicate)
  (interactive (mlg:get-fn "Display facts containing atom"))
  (send-string (get-buffer-process (current-buffer))
	       (format "(prfacts '%s)\n" predicate)))

(defun mlg:get-fn (prompt)
  (save-excursion
    (backward-up-list 1)
    (forward-word 1)
    (fi::get-default-symbol prompt)))

(setq fi:mvl-mode-hook
  '(lambda ()
    (define-key (current-local-map) "\M-S" 'fi:mvl-state-region)
    (define-key (current-local-map) "\M-s" 'fi:mvl-state-defun)
    (define-key (current-local-map) "\M-U" 'fi:mvl-unstate-region)
    (define-key (current-local-map) "\M-u" 'fi:mvl-unstate-defun)))

(global-set-key "\M-*" 'fi:mvl-apropos)
