;; load environment value
(load-file (expand-file-name "~/.emacs.d/shellenv.el"))
(dolist (path (reverse (split-string (getenv "PATH") ":")))
  (add-to-list 'exec-path path))

;; multi-term
(require 'multi-term)
(setq multi-term-program "/bin/bash")
(add-hook 'term-mode-hook
  '(lambda ()
     ;; C-h を term 内文字削除にする
     (define-key term-raw-map (kbd "C-h") 'term-send-backspace)
     ;; C-y を term 内ペーストにする
     (define-key term-raw-map (kbd "C-y") 'term-paste)
     ))
(define-key global-map (kbd "C-x t") 'multi-term)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-off)
