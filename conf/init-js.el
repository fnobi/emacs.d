;;javascript
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.\\(js\\|json\\)$" . js2-mode))

(setq-default c-basic-offset 4)

(when (load "js2" t)
  (setq js2-mirror-mode nil
        js2-cleanup-tab nil
        js2-bounce-indent-flag nil)
  )


(defadvice font-lock-mode (before my-font-lock-mode())
  (font-lock-add-keywords
   js2-mode
   '(
     ("[^ ]{" 0 my-face-u-1 append)
     ("}[(]" 0 my-face-u-1 append)
     (",[^ \n]" 0 my-face-u-1 append)
     ("[^ !=]=" 0 my-face-u-1 append)
     ("=[^ =>]" 0 my-face-u-1 append)
     ;; ("[^ ]\+" 0 my-face-u-1 append)
     ))
)
