;;; el.el --- books exmple                           -*- lexical-binding: t; -*-

;; Copyright (C) 2017  闫航

;; Author: 闫航 <yayu@s-MacBook-Pro.lan>
;; Keywords: 


(let ((zebra 'stripes)
      (tiger 'fierce))
  (message "One kind of animal has %s and another is %s." zebra tiger))


(let (pile
      (a 3))
  (message "hehe %s %d" pile a))

(mess )

(if (> 4 3)
    (message "4 > 3"))

(defun type-of-food (food)
  "Test function with docstring"
  (if (equal food "heh")
      (message "it's hehe")
      )
  )

(type-of-food "hehe")
(type-of-food "heh")


(defun simple-begining-of-buffer ()
  "Move point to the begiing of buffer"
  (interactive)
  (push-mark)
  (goto-char (point-min)))

()



(defun go-get ()
  (interactive)
  (shell-command (format "go get %s" (buffer-substring (mark) (point))))
  )


(defun my-append-to-buffer (buffer start end)
  "Append to specified buffer the text of the region.It is inserted
into that buffer before its point"
  (interactive
   (list (read-buffer "Append to buffer: "
                      (other-buffer (current-buffer) t ))
         (region-beginning)
         (region-end))))



(defun insert-buffer-1 (buffer)
  "Insert after point the contents of BUFFER."
  (interactive "*bInsert buffer: ")
  (or (bufferp buffer)
      (setq buffer (get-buffer buffer)))
  (let (start end newmark)
    (save-excursion
      (save-excursion
        (set-buffer buffer)
        (setq start (point-min) end (point-max)))
      (insert-buffer-substring buffer start end)
      (setq newmark (point)))
    (push-mark newmark)
    
    )
  )




(point)


(defun my-what-line ()
  "Print the current line number(in the buffer) of point"
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)
      (message "Line %d" (1+ (count-lines 1 (point))))
      )
    )
  )




