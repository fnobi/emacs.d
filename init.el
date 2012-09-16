;; key binds
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\M-i" 'indent-region)

(global-set-key "\C-s" 'isearch-forward-regexp)
(global-set-key "\C-q" 'query-replace-regexp)
(global-set-key "\M-l" 'lisp-interaction-mode)
(global-set-key "\M-I" 'align)

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

;; color setting
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
		      :family "Osaka"
		      :height 120)
  (set-fontset-font "fontset-default"
		    'japanese-jisx0208
		    '("Osaka" . "jisx0208-sjis"))

  ;; ウィンドウサイズの設定
  (setq initial-frame-alist
	(append
	 '((top . 20)   
	   (left . 20)  
	   (width . 45)  
	   (height . 30) 
	   ) initial-frame-alist))

  ))



;;ruby-mode
(add-to-list 'load-path "/usr/share/emacs/site-lisp/ruby")
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)
(setq auto-mode-alist (cons '("\\.rb$" . ruby-mode) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby" "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby-keys)))

(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)

;;css-mode
(autoload 'css-mode "css-mode")
(setq auto-mode-alist
      (cons '("\\.css\\'" . css-mode)
auto-mode-alist))

;;php-mode
(load-library "php-mode")
(require 'php-mode)

;;japanese
(set-language-environment "japanese")
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;;javascript
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.\\(js\\|json\\)$" . js2-mode))

(setq-default c-basic-offset 8)

(when (load "js2" t)
  (setq js2-cleanup-whitespace nil
        js2-mirror-mode nil
        js2-bounce-indent-flag nil)
  )

;; perl 
(defalias 'perl-mode 'cperl-mode)
(setq cperl-indent-level 8
      cperl-tab-always-indent t)
