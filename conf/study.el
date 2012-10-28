(defun multiply-by-seven (number)
  "Multiply NUMBER by seven."
  (interactive "p")
  (message "The result is %d" (* 7 number)))

(point)

(multiply-by-seven 3)

;; 現在のカーソルの位置と、バッファー終端の位置を教えてくれる
(defun posit (start end)
  "print point"
  (interactive "r")
  (message "%s -> %s" start end)
)

;; イマココ http://www.bookshelf.jp/texi/emacs-lisp-intro-jp/eintro_5.html#SEC48
