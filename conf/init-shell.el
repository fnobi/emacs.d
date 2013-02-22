;; load environment value
(load-file (expand-file-name "~/.emacs.d/shellenv.el"))
(dolist (path (reverse (split-string (getenv "PATH") ":")))
  (add-to-list 'exec-path path))

;; aliases setting
(setq eshell-command-aliases-list
      (append
       (list
        (list "desk" "cd ~/Desktop")
        (list "swipl" "/opt/local/bin/swipl")
        (list "settings" "open -a 'system preferences'")
        (list "activity" "open -a 'activity monitor'")

        (list "qt" "open -a 'quicktime player'")
        (list "pd" "open /applications/Pd-0.43-2.app")

        (list "desk" "cd ~/desktop")

        (list "psd" "open /Applications/Adobe\ Photoshop\ CS6/Adobe\ Photoshop\ CS6.app")
        (list "ai" "open -a 'Adobe Illustrator'")
        (list "bridge" "open -a 'Adobe Bridge CS5'")

        (list "octave" "/Applications/Octave.app/Contents/Resources/bin/octave")
        (list "gnuplot" "/Applications/Gnuplot.app/Contents/Resources/bin/gnuplot")

        (list "knownhosts" "cut -d ' ' -f 1 < ~/.ssh/known_hosts")

        (list "astah" "open -a astah\ community")
        )
       eshell-command-aliases-list))

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
;; (define-key global-map (kbd "C-x t") 'multi-term)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-off)
