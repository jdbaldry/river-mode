;;; river-mode.el --- Emacs mode for River configuration language

;; TODO: add license.

;; Author: Jack Baldry <jack.baldry@grafana.com>
;; Version: 1.0
;; Package-Requires ((cl-lib "0.5"))
;; Keywords: river, grafana, agent
;; URL: https://github.com/jdbaldry/river-mode

;;; Commentary:

;;; Code:
(defvar river-mode-hook nil "Hook executed when river-mode is run.")

;; TODO: consider using `make-sparse-keymap` instead.
(defvar river-mode-map (make-keymap) "Keymap for River major mode.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.rvr\\'" . river-mode))
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.river\\'" . river-mode))

(defconst river-identifier-regexp "[A-Za-z_][0-9A-Za-z_]*")

(defconst river-block-header-regexp (concat "^\\(\\(" river-identifier-regexp "\\)\\(\\.\\(" river-identifier-regexp "\\)\\)*\\) "))

(defconst river-constant (regexp-opt '("true" "false" "null")))
(defconst river-float "NOTDONE")
(defconst river-int "NOTDONE")
;; TODO: This erroneously highlights TODO identifiers.
(defconst river-todo (regexp-opt '("TODO" "FIXME" "XXX" "BUG" "NOTE") "\\<\\(?:"))

;; TODO: introduce levels of font lock
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Levels-of-Font-Lock.html
(defconst river-font-lock-keywords
  (let (
        )
    (list
     `(,river-block-header-regexp . (1 font-lock-variable-name-face t))
     `(,river-constant . font-lock-constant-face)
     `(,river-todo . (0 font-lock-warning-face t))))
  "Syntax highlighting for 'river-mode'.")

(defvar river-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; From: https://www.emacswiki.org/emacs/ModeTutorial
    ;; > 1) That the character '/' is the start of a two-character comment sequence ('1'),
    ;; > that it may also be the second character of a two-character comment-start sequence ('2'),
    ;; > that it is the end of a two-character comment-start sequence ('4'),
    ;; > and that comment sequences that have this character as the second character in the sequence
    ;; > is a “b-style” comment ('b').
    ;; > It’s a rule that comments that begin with a “b-style” sequence must end with either the same
    ;; > or some other “b-style” sequence.
    ;; > 2) That the character '*' is the second character of a two-character comment-start sequence ('2')
    ;; > and that it is the start of a two-character comment-end sequence ('3').
    ;; > 3) That the character '\n' (which is the newline character) ends a “b-style” comment.
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "Syntax table for 'river-mode'.")

(define-derived-mode river-mode prog-mode "River"
  "Major mode for editing River configuration language files." ()
  (kill-all-local-variables)
  (set-syntax-table river-mode-syntax-table)
  (use-local-map river-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(river-font-lock-keywords))
  (setq major-mode 'river-mode)
  (setq mode-name "River")
  (setq indent-tabs-mode t)
  (run-hooks 'river-mode-hook))

(defun river-format()
  "Format buffer with 'flow agent fmt'."
  (interactive)
  (write-region (point-min) (point-max) (buffer-file-name))
  (with-environment-variables
      (("EXPERIMENTAL_ENABLE_FLOW" "true"))
    (shell-command (concat "agent fmt -w " (buffer-file-name))))
  (revert-buffer :ignore-auto :noconfirm))

(defun river-format-before-save ()
  "Add this to .emacs to run formatting on the current buffer when saving:
\(add-hook 'before-save-hook 'river-format-before-save)."
  (interactive)
  (when (eq major-mode 'river-mode) (river-format)))

(provide 'river-mode)
;;; river-mode.el ends here
