(define (sum-integers a b)
  (if (> a b)
	  0
 	  (+ a (sum-integers (+a 1) b))))


;; let

(define (square x) (* x x))
(define (f g)
  (g 2))

(f square)

(f (lambda (z) (* z (+ z 1))))
