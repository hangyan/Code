(define (square x) (* x x))

(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))



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

;-------------------------------------------------------------------------------

(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))

 (define (factorial n)
   (fact-iter 1 1 n))

 (define (fact-iter product counter max-count)
   (if (> counter max-count)
       product
       (fact-iter (* counter product)
                  (+ counter 1)
                  max-count)))

(factorial 10)

;-------------------------------------------------------------------------------

(define (inc x)
  (+ 1 x))

(define (dec x)
  (- x 1))

(define (plus a b)
  (if (= a 0)
	  b
	  (inc (plus (dec a) b))))

(define (plus2 a b)
  (if (= a 0)
	  b
	  (plus2 (dec a) (inc b))))
;-------------------------------------------------------------------------------

; Ackermann
(define (A x y)
  (cond ((= y 0) 0)
		((= x 0) (* 2 y))
		((= y 1) 2)
		(else (A (- x 1)
				 (A x (- y 1))))))

(define (f n) (A 0 n))
;-------------------------------------------------------------------------------

; fib
(define (fib n)
  (cond ((= n 0) 0)
		((= n 1) 1)
		(else (+ (fib (- n 1))
				 (fib (- n 2))))))

(define (fib n)
  (fib-iter 1 0 n))

(define (fib-iter a b count)
  (if (= count 0)
	  b
	  (fib-iter (+ a b) a (- count 1))))

;-------------------------------------------------------------------------------

(define (count-change amount)
  (cc amount 5))
(define (cc amount kinds-of-coins)
  (cond ((= amount 0) 1)
		((or (< amount 0) (= kinds-of-coins 0)) 0)
		(else (+ (cc amount
					 (- kinds-of-coins 1))
				 (cc (- amount
						(first-denomination kinds-of-coins))
					 kinds-of-coins)))))


(define (first-denomination kinds-of-coins)
  (cond ((= kinds-of-coins 1) 1)
		((= kinds-of-coins 2) 5)
		((= kinds-of-coins 3) 10)
		((= kinds-of-coins 4) 25)
		((= kinds-of-coins 5) 50)))

;-------------------------------------------------------------------------------
(define (f n)
  (if (< n 3)
	  n
	  (+ (f (- n 1))
		 (* 2 (f (- n 2)))
		 (* 3 (f (- n 3))))))




(define f n
  (f-iter 2 1 0 0 n))

(define (f-iter a b c i n)
  (if (= i n)
	  c
	  (f-iter (+ a (*2 b) (* 3 c)) ; new a
			  a          ; new b 
			  b          ; new c
			  (+i 1)
			  n)))


;-------------------------------------------------------------------------------
(define (pascal row col)
  (cond ((> col row)
		 (error "unvalid col value"))
		((or (= col 0) (= row col))
		 1)
		(else (+ (pascal (- row 1) (- col 1))
				 (pascal (- row 1) col)))))

