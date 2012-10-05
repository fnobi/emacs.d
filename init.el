;;============================================================================;;
;; key binds                                                                  ;;
;;============================================================================;;
(define-key global-map (kbd "C-h") 'delete-backward-char)
(define-key global-map (kbd "C-t") 'other-window)
(define-key global-map [?¥] [?\\])  ;; ¥の代わりにバックスラッシュを入力する

(global-set-key "\M-i" 'indent-region)
(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-q" 'query-replace-regexp)
(global-set-key "\M-l" 'lisp-interaction-mode)

;;============================================================================;;
;; toggle truncate lines                                                      ;;
;;============================================================================;;
(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))

(global-set-key "\C-c\C-l" 'toggle-truncate-lines) ; 折り返し表示ON/OFF


;;============================================================================;;
;; load path                                                                  ;;
;;============================================================================;;
;; for Emacs <23
(when (< emacs-major-version 23)
  (defvar user-emacs directory "~/.emacs.d"))

;; add-to-load-path
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
            (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))


;; load path setting
(add-to-load-path "elisp" "conf" "public_repos")

;;============================================================================;;
;; japanese                                                                   ;;
;;============================================================================;;
(set-language-environment "japanese")
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq local-coding-system 'utf-8-hfs))


;;============================================================================;;
;; backups                                                                    ;;
;;============================================================================;;
;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" , (expand-file-name "~/.emacs.d/backups/") t)))


;;============================================================================;;
;; frame                                                                      ;;
;;============================================================================;;
(column-number-mode t)


;;============================================================================;;
;; color, font, window size                                                   ;;
;;============================================================================;;
(if window-system (progn
  ;; 文字の色を設定します。
  (add-to-list 'default-frame-alist '(foreground-color . "white"))
  ;; 背景色を設定します。
  (add-to-list 'default-frame-alist '(background-color . "gray10"))
  ;; カーソルの色を設定します。
  (add-to-list 'default-frame-alist '(cursor-color . "SlateBlue2"))
  ;; マウスポインタの色を設定します。
  (add-to-list 'default-frame-alist '(mouse-color . "SlateBlue2"))
  ;; モードラインの文字の色を設定します。
  (set-face-foreground 'modeline "white")
  ;; モードラインの背景色を設定します。
  (set-face-background 'modeline "MediumPurple2")
  ;; 選択中のリージョンの色を設定します。
  (set-face-background 'region "LightSteelBlue1")
  ;; モードライン（アクティブでないバッファ）の文字色を設定します。
  (set-face-foreground 'mode-line-inactive "gray30")
  ;; モードライン（アクティブでないバッファ）の背景色を設定します。
  (set-face-background 'mode-line-inactive "gray85")

  ;; フォントの設定
  (set-face-attribute 'default nil
                      :family "Monaco"
                      :height 120)
  (set-fontset-font
   nil 'japanese-jisx0208
   (font-spec :family "Hiragino Kaku Gothic Pro"))


  ;; ウィンドウサイズの設定
  (setq initial-frame-alist
        (append
         '((top . 30)
           (left . 30)
           (width . 90)
           (height . 30)
           ) initial-frame-alist))
  ))


;;============================================================================;;
;; tab, full-space alert                                                      ;;
;;============================================================================;;
(load "init-alert")

;;============================================================================;;
;; modules                                                                    ;;
;;============================================================================;;
;; flymake
(defun next-flymake-error ()
  (interactive)
  (flymake-goto-next-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err))))


;; egg
;; (when (executable-find "git")
;;  (require 'egg nil t))

;; magit
(require 'magit)

;; windows
;;(load "init-windows")

;; multi-term
;;(require 'multi-term)
;;(setq multi-term-program "/bin/bash")

;; howm
(load "init-howm")



;;============================================================================;;
;; mode                                                                       ;;
;;============================================================================;;
(load "init-js")
(load "init-css")
(load "init-php")
(load "init-perl")
(load "init-ruby")

;; markdown-mode
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))

;; jade-mode
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))
