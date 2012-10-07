;;; buster-mode.el --- minor mode for working with Buster.JS test files

;; (The BSD License)
;;
;; Copyright (c) 2011, Christian Johansen, christian@cjohansen.no and
;; August Lilleaas, august.lilleaas@gmail.com. All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without modification,
;; are permitted provided that the following conditions are met:
;;
;;     * Redistributions of source code must retain the above copyright notice,
;;       this list of conditions and the following disclaimer.
;;     * Redistributions in binary form must reproduce the above copyright notice,
;;       this list of conditions and the following disclaimer in the documentation
;;       and/or other materials provided with the distribution.
;;     * Neither the name of Christian Johansen nor the names of his contributors
;;       may be used to endorse or promote products derived from this software
;;       without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
;; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;;; Usage:
;;
;;   (autoload 'buster-mode "buster-mode" nil t)
;;   (add-hook 'javascript-mode-hook
;;             (lambda ()
;;               (let* ((file (buffer-file-name))
;;                      (len (length file)))
;;                 (if (eq (substring file (- len 8) len) "test.js")) (buster-mode))))
;;

(require 'ansi-color)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public interactive commands ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun buster-goto-next-test (&optional num)
  "Move point to the beginning of the next xUnit style test or
BDD style example. Numeric prefix argument decides how many tests
to jump. Negative prefix argument NUM moves backwards."
  (interactive "p")
  (buster--interactive-multiplier
   num buster--goto-next-test buster-goto-previous-test))

(defun buster-goto-previous-test (&optional num)
  "Move point to the beginning of the previous xUnit style test or
BDD style example. Numeric prefix argument decides how many tests
to jump. Negative prefix argument NUM moves forwards."
  (interactive "p")
  (buster--interactive-multiplier
   num buster--goto-previous-test buster-goto-next-test))

(defun buster-goto-beginning-of-test ()
  "Move point to the beginning of the current xUnit style test or
BDD style example."
  (interactive)
  (cond
   ((buster-curr-line-box-p) (buster--goto-beginning-of-xunit-test))
   ((buster-curr-line-boe-p) (buster--goto-beginning-of-example))
   (t (buster--goto-previous-test))))

(defun buster-disable-test ()
  "Disables a single test by using the 'comment out' feature of
Buster.JS xUnit style tests or converting 'should' calls to
'shouldEventually'. Finds test to disable using
buster-goto-beginning-of-test"
  (interactive)
  (save-excursion
    (buster-goto-beginning-of-test)
    (cond
     ((buster-curr-line-box-p) (buster-disable-xunit-test))
     ((buster-curr-line-boe-p) (buster-disable-example)))))

(defun buster-enable-test ()
  "Enables a single test by removing the 'comment' inserted by
buster-disable-test (or converting shouldEventually back to
should)"
  (interactive)
  (save-excursion
    (buster-goto-beginning-of-test)
    (cond
     ((buster-curr-line-box-p) (buster-enable-xunit-test))
     ((buster-curr-line-boe-p) (buster-enable-example)))))

(defun buster-disable-all-tests (&optional start end)
  "Disables all test functions in the region or buffer. If
the mark is not active, the provided arguments are ignored,
and the entire buffer is considered instead."
  (interactive "r")
  (buster-each-test start end (buster-disable-test)))

(defun buster-disable-all-tests-but-current ()
  "Disables all test functions in the buffer except the
currently active test"
  (interactive)
  (buster-disable-all-tests)
  (buster-enable-test))

(defun buster-enable-all-tests (&optional start end)
  "Enables all test functions in the region or buffer. If
the mark is not active, the provided arguments are ignored,
and the entire buffer is considered instead."
  (interactive "r")
  (buster-each-test start end (buster-enable-test)))

(defun buster-asyncify-test ()
  "Makes the current test asynchronous by adding the done callback
to the test function."
  (interactive)
  (save-excursion
    (buster-goto-beginning-of-test)
    (if (search-forward-regexp "function *()" (point-at-eol) t)
        (progn
          (goto-char (1- (point)))
          (insert "done")))))

(defun buster-sync-test ()
  "Makes the current test synchronous by removing the done callback
to the test function."
  (interactive)
  (save-excursion
    (buster-goto-beginning-of-test)
    (if (search-forward-regexp "function *(done)" (point-at-eol) t)
        (progn
          (goto-char (- (point) 5))
          (delete-char 4)))))

(defun buster-asyncify-all-tests (&optional start end)
  "Makes all test functions in the region or buffer asynchronous.
If the mark is not active, the provided arguments are ignored,
and the entire buffer is considered instead."
  (interactive "r")
  (buster-each-test start end (buster-asyncify-test)))

(defun buster-sync-all-tests (&optional start end)
  "Makes all test functions in the region or buffer synchronous.
If the mark is not active, the provided arguments are ignored,
and the entire buffer is considered instead."
  (interactive "r")
  (buster-each-test start end (buster-sync-test)))

(defun buster-toggle-sync-async ()
  "Toggle if test is sychronous or asynchronous."
  (interactive)
  (if (buster-test-is-async) (buster-sync-test) (buster-asyncify-test)))

(defun buster-run-buffer-file ()
  "Run all tests in the current buffer"
  (interactive)
  (let ((file (buffer-file-name))
        (window (selected-window)))
    (switch-to-buffer-other-window "*Buster*")
    (delete-region (point-min) (point-max))
    (buster-results-mode)
    (call-process buster-node-executable nil t t file)
    (insert "\n")
    (buster--sgr-to-faces (point-min) (point))
    (select-window window)))

(defun buster-next-stack-entry (&optional n)
  "Place point at the beginning of the next path name in a
stack trace."
  (interactive "p")
  (if (< n 0) (buster-prev-stack-entry (- n))
    (if (search-forward-regexp buster-stack-entry-regexp nil t)
        (progn
          (search-backward-regexp buster-stack-entry-regexp)
          (skip-chars-forward " (")
          (if (> n 1) (buster-goto-next-stack-entry (1- n))))
      (let ((curr-pos (point)))
        (beginning-of-buffer)
        (if (equal (point) curr-pos) nil
          (buster-goto-next-stack-entry n))))))

(defun buster-prev-stack-entry (&optional n)
  "Place point at the beginning of the previous path name in
a stack trace."
  (interactive "p")
  (if (< n 0) (buster-next-stack-entry (- n))
    (if (search-backward-regexp buster-stack-entry-regexp nil t)
        (progn
          (skip-chars-forward " (")
          (if (> n 1) (buster-goto-prev-stack-entry (1- n))))
      (let ((curr-pos (point)))
        (end-of-buffer)
        (if (equal (point) curr-pos) nil (buster-goto-prev-stack-entry n))))))

(defun buster-visit-stack-entry-buffer ()
  "Try to load the path at point into a buffer."
  (interactive)
  (save-excursion
    (let* ((path (buster--forward-extract (point) "^:"))
           (line (string-to-number (buster--forward-extract (1+ (point)) "^:")))
           (col (string-to-number (buster--forward-extract (1+ (point)) "^)"))))
      (find-file-other-window path)
      (goto-line line)
      (goto-char (+ (point) col)))))

(defun buster-juxtapose-tests ()
  "If in a source file, open the related tests in a buffer in
another window. If no tests are found, does nothing."
  (interactive)
  (let ((tests (buster-buffer-tests)))
    (if (eq (current-buffer) tests)
        (buster--juxtapose (buster-buffer-source))
      (buster--juxtapose tests))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-command public functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun buster-curr-line-box-p ()
  "Returns t if the current line contains the beginning of a
xUnit style test method."
  (buster--regexp-match-on-curr-line buster--test-regexp))

(defun buster-curr-line-boe-p ()
  "Returns t if the current line contains the beginning of a
BDD style example."
  (buster--regexp-match-on-curr-line buster--example-regexp))

(defun buster-disable-xunit-test ()
  (forward-char)
  (if (not (search-forward "//" (+ (point) 2) t))
      (insert "//")))

(defun buster-disable-example ()
  (if (not (search-forward "shouldEventually" (+ (point) 16) t))
      (progn
        (forward-char 6)
        (insert "Eventually"))))

(defun buster-enable-xunit-test ()
  (if (search-forward "\"//" (+ (point) 3) t)
      (delete-region (- (point) 2) (point))))

(defun buster-enable-example ()
  (if (search-forward "shouldEventually" (+ (point) 16) t)
      (delete-region (- (point) 10) (point))))

(defun buster-test-async-p ()
  "Returns t if the current tests accepts the done callback,
thus, is asynchronous."
  (save-excursion
    (buster-goto-beginning-of-test)
    (if (search-forward-regexp "function *(done)" (point-at-eol) t) t)))

(defmacro buster-each-test (start end &rest body-forms)
  "Loops each test in the region bounded by START and END.
If the mark is not active, the START and END arguments are
ignored. Instead the entire (possibly narrowed) buffer will be
used. Applies the body forms to each test in turn."
  `(let ((start (or (and mark-active start) (point-min)))
         (end (or (and mark-active end) (point-max)))
         (previous 0))
     (save-excursion
       (goto-char start)
       (while (and (< (point) end)
                   (> (point) previous))
         (setq previous (point))
         (if (and (buster--goto-next-test) (< (point) end))
             (progn ,@body-forms))))))

(defun buster-insert-current-time ()
  "Inserts the current time, formatted with `buster-time-format'."
  (insert
   (concat
    (format-time-string buster-time-format (current-time)) "\n")))

(defun buster-buffer-tests ()
  "Find the buffer that holds the tests for the current buffer,
or return the buffer itself if it is visiting a test file."
  (if (buster--buffer-holds-tests-p (current-buffer))
      (current-buffer)
    (buster--find-buffer-matching
     (buster--possible-test-file-names buster-test-file-name-patterns))))

(defun buster-buffer-source ()
  "Find the buffer that holds the source being teted by the
current buffer, or return the buffer itself if it is
visiting a source file."
  (buster--find-buffer-matching
   (buster--possible-source-file-names buster-test-file-name-patterns)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables used by buster-mode. Customize at will. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar buster-node-executable
  "node" "The node executable.")

(defvar buster-mode-autorun-tests
  t "Set to nil if you don't want tests run automatically on save.")

(defvar buster-time-format "%a %H:%M:%S"
  "Time format for time inserted with `buster-insert-current-time'.")

;;;;;;;;;;;;;;;;;;;;;;
;; Mode definitions ;;
;;;;;;;;;;;;;;;;;;;;;;

(define-derived-mode buster-results-mode text-mode "Test run"
  "Major mode for interacting with Buster.JS test runs.
Key bindings:

\\{buster-results-mode-map}")

(substitute-key-definition 'forward-paragraph 'buster-next-stack-entry
                           buster-results-mode-map (current-global-map))
(substitute-key-definition 'backward-paragraph 'buster-previous-stack-entry
                           buster-results-mode-map (current-global-map))
(define-key buster-results-mode-map (kbd "<C-return>") 'buster-visit-stack-entry-buffer)

(defvar buster-mode-map nil
  "Keymap for Buster mode.")

(if buster-mode-map nil
  (setq buster-mode-map (make-keymap))
  (define-key buster-mode-map (kbd "C-c C-n") 'buster-goto-next-test)
  (define-key buster-mode-map (kbd "C-c C-p") 'buster-goto-previous-test)
  (define-key buster-mode-map (kbd "C-c C-d") 'buster-disable-test)
  (define-key buster-mode-map (kbd "C-c C-e") 'buster-enable-test)
  (define-key buster-mode-map (kbd "C-c M-d") 'buster-disable-all-tests-but-current)
  (define-key buster-mode-map (kbd "C-c M-e") 'buster-enable-all-tests)
  (define-key buster-mode-map (kbd "C-c t") 'buster-goto-beginning-of-test)
  (define-key buster-mode-map (kbd "C-c C-a") 'buster-toggle-sync-async)
  (define-key buster-mode-map (kbd "C-c C-r") 'buster-run-buffer-file)
  (define-key buster-mode-map (kbd "C-c C-t") 'buster-juxtapose-tests))

(define-minor-mode buster-mode
  "Buster minor mode, for awesome JavaScript unit tests. Key bindings:

\\{buster-mode-map}"
  nil " Buster" buster-mode-map
  (make-local-hook 'after-save-hook)
  (if buster-mode-autorun-tests
      (if buster-mode
          (add-hook 'after-save-hook 'buster-run-buffer-file nil t)
        (remove-hook 'after-save-hook 'buster-run-buffer-file t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables used internally in buster-mode. Change at your own risk. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar buster--test-regexp
  "^\[\[:blank:\]\]+\[\"'\]\.+ \.+\[\"'\]\[\[:blank:\]\]?:\.*function"
  "Regular expression that finds the beginning of a xUnit test function")

(defvar buster--example-regexp
  "^ +should\\(Eventually\\)\?(\[\"'\]"
  "Regular expression that finds the beginning of a BDD example")

(defvar buster-stack-entry-regexp
  " (?\\.?/.*:[0-9]+:[0-9]+"
  "Regular expression that finds a stack trace entry")

(defvar buster-test-file-name-patterns
  '((nil . "-test.js")
    (nil . "-spec.js"))
  "A list of patterns for matching file names to test file names.
The default list contains one pattern that assumes that a file
my-lib.js will have tests in a file named my-lib-test.js. Location
is unspecified. Each pattern is a dotted pair of prefix and suffix
for the base name. The file my-lib.js will result in a list of
possible test file names that look like <prefix>my-lib<suffix>.
The default entry is:
    (nil . \"-test.js\")

Note that you must include the file suffix.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private helper methods. Not intended for outside use, will ;;
;; change without notice.                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Various general purpose utilities

(defmacro buster--interactive-multiplier (num forward-fun &optional backward-fun)
  "Moves forwards by calling FORWARD-FUN for positive values of NUM,
backward by calling BACKWARD-FUN for negative values of NUM.
The forward walker is always called without an argument, while the
backward walker will be passed the absolute value of NUM. When not
passing BACKWARD-FUN, you should make sure the function takes an
optional argument."
  (if (null backward-fun) (setq backward-fun forward-fun))
  `(let ((num (or ,num 1)))
     (if (< num 0) (,backward-fun (- num))
       (while (> num 0)
         (,forward-fun)
         (setq num (1- ,num))))))

(defun buster--next-pos (regexp)
  "Returns the position of point at the next occurrence of REGEXP"
  (save-excursion
    (search-forward-regexp regexp nil t)))

(defun buster--previous-pos (regexp)
  "Returns the position of point at the previous occurrence of REGEXP"
  (save-excursion
    (search-backward-regexp regexp nil t)))

(defun buster--current-quote-char ()
  "Returns the quoting character of the enclosing string, if any.
Otherwise, returns nil."
  (nth 3 (syntax-ppss)))

(defun buster--beginning-of-string (&optional quote-is-beginning)
  "Moves point to the beginning of the current string. If
QUOTE-IS-BEGINNING is non-nil, moves point to the opening quote."
  (while (buster--current-quote-char) (backward-char))
  (if quote-is-beginning (point) (goto-char (1+ (point)))))

(defun buster--regexp-match-on-curr-line (regexp)
  "Return t if a match for REGEXP is found on the current line."
  (save-excursion
    (beginning-of-line)
    (let ((line-num (line-number-at-pos)))
      (if (search-forward-regexp regexp nil t)
          (eq line-num (line-number-at-pos))
        nil))))

(defun buster--sgr-to-faces (start end)
  "Convert ANSI escape characters (Select Graphic Rendition) to
faces, using ansi-color-apply."
  (save-excursion
    (goto-char start)
    (let ((colored-output (buffer-substring start end)))
      (delete-region start end)
      (insert (ansi-color-apply colored-output)))
    (buster--replace-ansi-del-char)))

(defun buster--replace-ansi-del-char ()
  "Replaces ANSI escape sequences for deleting characters
with actual backspaces. Currently only suppors ESC 1D, but should
eventually take on ESC nD, i.e. variable number of characters
backwards"
  (save-excursion
    (beginning-of-buffer)
    (while (search-forward "[1D" nil t)
      (let ((end (point)))
        (goto-char (- end 5))
        (delete-region (point) end)))))

(defun buster--forward-extract (start chars)
  "Starts a START and skips forward to CHARS,
returning the string in between. Moves point."
  (goto-char start)
  (buffer-substring start (+ start (skip-chars-forward chars))))

(defun buster--possible-test-file-names (templates)
  "Returns a list of possible names of test files for the file
visited by the current buffer. Accepts a list of dotted pairs
as templates for building possible test file names. See also
the variable buster-test-file-name-patterns"
  (let ((base (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))
        (patterns ())
        (pair nil))
    (while templates
      (setq pair (car templates))
      (setq patterns (cons (concat (car pair) base (cdr pair)) patterns))
      (setq templates (cdr templates)))
    patterns))

(defun buster--possible-source-file-names (templates)
  "Returns a list of possible names of source files for the file
visited by the current buffer. Accepts a list of dotted pairs
as templates for building possible source file names. See also
the variable buster-test-file-name-patterns"
  (let ((file-name (file-name-nondirectory (buffer-file-name)))
        (names ())
        (pair nil)
        (suggestio nil))
    (while templates
      (setq pair (car templates))
      (setq suggestion (buster--rsub
                        (buster--lsub file-name (car pair))
                        (cdr pair) ".js"))
      (unless (equal suggestion file-name)
        (setq names (cons suggestion names)))
      (setq templates (cdr templates)))
    names))

(defun buster--juxtapose (buffer)
  "Switch to buffer in other window unless BUFFER is nil or
same as the current buffer"
  (unless (or (null buffer)
              (eq buffer (current-buffer)))
    (switch-to-buffer-other-window buffer)))

;; TODO: Find some proper string manipulation functions
(defun buster--begins-with (haystack needle)
  (equal (substring haystack 0 (length needle)) needle))

(defun buster--ends-with (haystack needle)
  (let ((end-pos (- (length haystack) (length needle))))
    (equal (substring haystack end-pos) needle)))

(defun buster--lsub (str prefix &optional replacement)
  (if (buster--begins-with str prefix)
      (concat (or replacement "") (substring str (length prefix)))
    str))

(defun buster--rsub (str suffix &optional replacement)
  (if (buster--ends-with str suffix)
      (concat (substring str 0 (- (length str) (length suffix))) (or replacement ""))
    str))

;; buster-mode specific helpers. Commands usually call functions from
;; the following block, but handles prefix arguments and so on.

(defun buster--goto-beginning-of-xunit-test ()
  "Assumes the current line holds a xUnit test and moves point
to it's starting position."
  (beginning-of-line)
  (search-forward-regexp "\[\"'\]")
  (buster--beginning-of-string t))

(defun buster--goto-beginning-of-example ()
  (beginning-of-line)
  (search-forward-regexp "\\b"))

(defun buster--goto-next-xunit-test ()
  (if (search-forward-regexp buster--test-regexp nil t)
      (buster--goto-beginning-of-xunit-test)
    nil))

(defun buster--goto-previous-xunit-test ()
  (if (search-backward-regexp buster--test-regexp nil t)
      (buster--goto-beginning-of-xunit-test)
    nil))

(defun buster--goto-next-example ()
  (if (search-forward-regexp buster--example-regexp nil t)
      (buster--goto-beginning-of-example)
    nil))

(defun buster--goto-previous-example ()
  (beginning-of-line)
  (if (search-backward-regexp buster--example-regexp nil t)
      (search-forward-regexp "\\b"))
  nil)

(defun buster--goto-next-test ()
  (let ((closest-test (buster--next-pos buster--test-regexp))
        (closest-example (buster--next-pos buster--example-regexp)))
    (cond
     ((and (null closest-test) (null closest-example)) (message "No more tests") nil)
     ((null closest-test) (buster--goto-next-example))
     ((null closest-example) (buster--goto-next-xunit-test))
     ((< closest-test closest-example) (buster--goto-next-xunit-test))
     (t (buster--goto-next-example)))))

(defun buster--goto-previous-test ()
  (let ((closest-test (buster--previous-pos buster--test-regexp))
        (closest-example (buster--previous-pos buster--example-regexp)))
    (cond
     ((and (null closest-test) (null closest-example)) (message "No more tests") nil)
     ((null closest-test) (buster--goto-previous-example))
     ((null closest-example) (buster--goto-previous-xunit-test))
     ((> closest-test closest-example) (buster--goto-previous-xunit-test))
     (t (buster--goto-previous-example)))))

(defun buster--buffer-holds-tests-p (buffer)
  (let ((result nil)
        (pattern nil)
        (patterns buster-test-file-name-patterns))
    (while (and (null result) patterns)
      (setq pattern (car patterns))
      (if (buster--buffer-file-name-matches buffer pattern)
          (setq result buffer))
      (setq patterns (cdr patterns)))
    result))

(defun buster--find-buffer-matching (names)
  (let ((buffers nil)
        (result nil))
    (while (and (null result) names)
      (setq buffers (buffer-list))
      (while (and (null result) buffers)
        (if (buster--buffer-file-name-matches (car buffers) (list (car names)))
            (setq result (car buffers)))
        (setq buffers (cdr buffers)))
      (setq names (cdr names)))
    result))

(defun buster--buffer-file-name-matches (buffer pattern)
  (if (buffer-file-name buffer)
      (let ((base (file-name-nondirectory (buffer-file-name buffer)))
            (pre (car pattern))
            (suf (cdr pattern)))
        (and (or (null pre) (buster--begins-with base pre))
             (or (null suf) (buster--ends-with base suf))))))

(provide 'buster-mode)
;; buster-mode.el ends here
