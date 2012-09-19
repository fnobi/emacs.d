;; howmメモ保存の場所
(setq howm-directory (concat user-emacs-directory "howm"))

;; howm-menuの言語を日本語に
;;(setq howm-menu-lang 'ja)

;;howmメモを1日1ファイルにする
; (setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")

;; howm-modeを読み込む
(when (require 'howm-mode nil t)
  ;; C-c,,でhowm-menuを起動
  (define-key global-map (kbd "C-c ,,") 'howm-menu))
