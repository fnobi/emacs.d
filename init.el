;;============================================================================;;
;; key binds                                                                  ;;
;;============================================================================;;
(define-key global-map (kbd "C-h") 'delete-backward-char)
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
(add-to-load-path "elisp" "conf" "public_repos" "auto-install")

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
;; anything                                                                   ;;
;;============================================================================;;
(require 'anything)
(require 'anything-config)
(add-to-list 'anything-sources 'anything-c-source-emacs-commands)

(define-key global-map (kbd "C-;") 'anything)


;;============================================================================;;
;; modules                                                                    ;;
;;============================================================================;;
;; auto-install
(require 'auto-install)
(setq auto-install-directory "~/.emacs.d/auto-install/")
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)             ; 互換性確保

;; flymake
(defun next-flymake-error ()
  (interactive)
  (flymake-goto-next-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err))))

;; magit
(require 'magit)
(define-key global-map (kbd "C-x g") 'magit-status)

;; windows
;;(load "init-windows")

;; howm
;; (load "init-howm")


;;============================================================================;;
;; terminal                                                                   ;;
;;============================================================================;;
;; より下に記述した物が PATH の先頭に追加されます
(dolist (dir (list
              "/usr/local/mysql/bin"
              "/sbin"
              "/usr/sbin"
              "/bin"
              "/usr/bin"
              "/opt/local/bin"
              "/sw/bin"
              "/usr/local/bin"
              (expand-file-name "~/bin")
              (expand-file-name "~/.emacs.d/bin")
              ))
 ;; PATH と exec-path に同じ物を追加します
 (when (and (file-exists-p dir) (not (member dir exec-path)))
   (setenv "PATH" (concat dir ":" (getenv "PATH")))
   (setq exec-path (append (list dir) exec-path))))

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

;;============================================================================;;
;; auto-complete                                                              ;;
;;============================================================================;;
(add-to-list 'load-path "~/.emacs.d/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)


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
(setq auto-mode-alist
      (append
       (list
        '("\\.md" . markdown-mode)
        '("\\.markdown" . markdown-mode))
       auto-mode-alist))

(add-hook
 'markdown-mode-hook
 '(lambda()
    (setq markdown-command "mdown")))

;; jade-mode
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))

;; scss-mode
(autoload 'scss-mode "scss-mode")
(add-to-list 'auto-mode-alist '("\\.scss$" . scss-mode))

;; buster-mode
(autoload 'buster-mode "buster-mode" nil t)
(add-hook 'javascript-mode-hook
	(lambda ()
	(let* ((file (buffer-file-name))
		(len (length file)))
	(If (eq (substring file (- len 8) len) "test.js")) (buster-mode))))

;; sudden-death
(load "sudden-death")

;; twttering-mode
(load "init-twittering")

;;============================================================================;;
;; n3 mode                                                                    ;;
;;============================================================================;;
;; (add-to-list 'load-path "{path}/n3-mode.el")
(autoload 'n3-mode "n3-mode" "Major mode for OWL or N3 files" t)

;; Turn on font lock when in n3 mode
(add-hook 'n3-mode-hook
          'turn-on-font-lock)

(setq auto-mode-alist
      (append
       (list
        '("\\.n3" . n3-mode)
        '("\\.ttl" . n3-mode)
        '("\\.owl" . n3-mode))
       auto-mode-alist))

;; Replace {path} with the full path to n3-mode.el on your system.

;; If you want to make it load just a little faster;
;; C-x f n3-mode.el
;; M-x byte-compile-file n3-mode.el

;;============================================================================;;
;; study                                                                      ;;
;;============================================================================;;
(load "study")

;;============================================================================;;
;; mail                                                                       ;;
;;============================================================================;;
(load "init-mail")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(gud-gdb-command-name "gdb --annotate=1")
 '(large-file-warning-threshold nil)
 '(send-mail-function (quote mailclient-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
