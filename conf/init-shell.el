;; load environment value
(load-file (expand-file-name "~/.emacs.d/shellenv.el"))
(dolist (path (reverse (split-string (getenv "PATH") ":")))
  (add-to-list 'exec-path path))

;; ;; より下に記述した物が PATH の先頭に追加されます
;; (dolist (dir (list
;;       "/usr/local/mysql/bin"
;;       "/opt/local/bin"
;;       (expand-file-name "~/bin")
;;       (expand-file-name "~/.emacs.d/bin")
;;       "/usr/local/go/bin"
;;       "/usr/X11/bin"
;;       "/usr/local/bin"
;;       "/sbin"
;;       "/usr/sbin"
;;       "/bin"
;;       "/usr/bin"
;;       "/usr/local/mysql/bin"
;;       "/opt/local/sbin"
;;       "/opt/local/bin"
;;       "/usr/local/heroku/bin"
;;       (expand-file-name "~/bin")
;;       (expand-file-name "~/.rvm/bin")
;;       (expand-file-name "~/.nodebrew/current/bin")
;;       (expand-file-name "~/perl5/perlbrew/bin")
;;       "/opt/local/sbin"
;;       "/opt/local/bin"
;;       ))
;;  ;; PATH と exec-path に同じ物を追加します
;;  (when (and (file-exists-p dir) (not (member dir exec-path)))
;;    (setenv "PATH" (concat dir ":" (getenv "PATH")))
;;    (setq exec-path (append (list dir) exec-path))))

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
