(defun img-size (width height)
  "insert img width & height"
  (interactive "swidth: \nsheight: ")
  (insert (concat "width=\"" width "\" height=\"" height "\" ")))
