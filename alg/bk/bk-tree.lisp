(in-package :bk-tree)

;; convenient helper utilites
(defun print-tree (tree &key (stream *standard-output*) (depth 0))
  "Prints supplied 'TREE' in a human-redable(?) format."
  ;;print current value first.
  (format stream "~&")
  (loop repeat depth do (write-char #\space stream))
  (format stream "-> (~D) ~A" (distant-of tree) (value-of tree))

  ;; Iterate across sub-trees,according to their distances from root node
  (mapc
   (lambda (tree) (print-tree tree :stream stream :depth (+ 4 depth)))
   (sort (copy-list (nodes-of tree)) #'< :key #'distance-of)))


(defun insert-value (value tree &key (metric #'levenshtein))
  "Insert given 'VALUE' into supplied 'TREE'."
  (if (null (value-of tree))
	  (setf (value-of tree) value)
	  (let ((distance (funcall metric value (value-of tree))))
		(if (zerop distance)
			(error 'duplicate-value :value value))
		(let ((sub-tree
			   (find distance (nodes-of tree) :test #'= :key #'distance-of)))
		  (if sub-tree
			  (insert-value value sub-tree :metric metric)
			  (push (make-instance 'bk-tree :distance distance :value value)
					(nodes-of tree)))))))
