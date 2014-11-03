(defpackage :bk-tree-test (:use :cl :bk-tree))

(in-package :bk-tree-test)
(defvar *words* nil)
(defvar *tree* (make-instance 'bk-tree))

;; build *words* list
(with-open-file (in "english.5000.words.txt")
  (loop for line = (read-line in nil nil)
	   while line
	   do (push
		   (string-trim '(#\space #\tab #\cr #\lf) line)
		   *words)))

(if (endp *words*)
	(error "*WORDS* is empty!")
	)

(mapc (lambda (word)
		(handler-case (insert-value word *tree*)
		  (duplicate-value (ctx)
			(format t "Duplicated: ~a~%" (value-of ctx)))))
	  *words*)

(print-tree *tree*)
