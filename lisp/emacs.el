;;; emacs.el --- learn                               -*- lexical-binding: t; -*-

;; Copyright (C) 2017  yayu

;; Author: yayu <yayu@bogon>
;; Keywords: lisp, languages, unix, abbrev,



(other-buffer)
;;(switch-to-buffer (other-buffer))
(mark-whole-buffer)




(defun multiply-by-seven (number)
  "Multiply NUMBER by sven"
  (interactive "p")
  (message "The result is %d" (* 7 number))
  )
