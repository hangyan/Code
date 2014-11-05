
(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (imporove guess x)
                 x)))

(define (imporove guess x)
  (average guess (/ x guess)))

(define (average x y)
  (/ (+ x y) 2))

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))


(define (sqrt x)
  (sqrt-iter 1.0 x))

(sqrt 9)
