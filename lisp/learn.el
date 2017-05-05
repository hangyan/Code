;; example code of "Programming in Emacs" "eintr"


;; basic

(+ 2 2)
'(fuck baidu)

(message "This message appears in the echo area!")
(message "The name of this buffer is: %s." (buffer-name))
(message "The value of fill-column is %d." fill-column)
(set 'flowers '(rose violet daisy buttercup))
(buffer-name)
(buffer-file-name)




(defun insert-buffer (buffer)
  "Insert after point the contents of BUFFER.Puts mark after the
inserted text.BUFFER may be a buffer or a buffer name."
  (interactive "*bInsert buffer:")
  (or (bufferp buffer)
	  (setq buffer (get-buffer buffer)))
  (let (start end newmark)
	(save-excursion
	  (save-excursion
		(set-buffer buffer)
		(setq start (point-min) end (point-max)))
	  (insert-buffer-substring buffer start end)
	  (setq newmark (point)))
	(push-mark newmark)))


(defun zap-to-char (arg char)
  "Kill up to and including ARG'th occurrence of CHAR.
Goes backward if ARG is negative;error if CHAR not found."
  (interactive "*p\ncZap to char: ")
  (kill-region (point)
			   (progn
				 (search-forward
				  (char-to-string char) nil nil arg)
				 (point))))
(zap-to-char 3 'z)




(defun kill-region (beg end)
  (interactive "r")
  (condition-case nil
      (let ((string (delete-and-extract-region beg end)))
        (when string
          (if (eq last-command 'kill-region)
              (kill-append string (< end beg))
            (kill-new string)
			)
          )

        (setq this-command 'kill-region))

    
	)
  )



										;recursion
(setq animals '(gazelle giraffe lion tiger))
(defun print-elements-recursively (list)
  "Print each element of LIST on a line of its own.Uses recursion."
  (if list
      (progn
        (print (car list))
        (print-elements-recursively
         (cdr list))
        )
	)
  )
(print-elements-recursively animals)

(defun triangle-recursively (number)
  "Return the sum of the numbers through NUMBER inclusive"
  (if (= number 1)
      1
    (+ number
       (triangle-recursively (1- number)))
	)
  )
(triangle-recursively 5)

(defun triangle-using-cond (number)
  (cond ((<= number 0) 0)
        ((= number 1) 1)
        ((> number 1)
         (+ number (triangle-using-cond (1- number)))
         )
		)
  )

(triangle-using-cond 5)

;; recursive pattern
(defun square-each (numbers-list)
  "Square each of a NUMBERS LIST,recursively."
  (if (not numbers-list)
      nil
    (cons
     (* (car numbers-list) (car numbers-list))
     (square-each (cdr numbers-list))
     )
    )
  )

(square-each '(1 2 3))


(defun add-elements (numbers-list)
  "Add the elements of NUMBER-LIST together"
  (if (not numbers-list)
      0
    (+ (car numbers-list) (add-elements (cdr numbers-list)))
    )
  )

(add-elements '(1 2 3 4 5))


(defun keep-three-letter-words (word-list)
  "Keep three letter words in WORD-LIST."
  (cond
   ((not word-list) nil)
   ((eq 3 (length (symbol-name (car word-list))))
    (cons (car word-list) (keep-three-letter-words (cdr word-list)))
    )
   (t (keep-three-letter-words (cdr word-list)))
   )
  )

(keep-three-letter-words '(one two three four five six))


;; No deferment solution
(defun triangle-initialization (number)
  "Return the sum of the numbers 1 thought number inclusive.This is
the 'initialization' component of a two function duo that use recursion."
  (triangle-recursive-helper 0 0 number)
  )

(defun triangle-recursive-helper (sum counter number)
  "Return SUM,using COUNTER,through NUMBER inclusive.This is the `helper` component
of a two function duo that uses recursion"
  (if (> counter number )
      sum
    (triangle-recursive-helper (+ sum counter)
                               (1+ counter)
                               number)
    )
  )
(triangle-initialization 5)


;; word count
(defun count-words-region (beginning end)
  "Print nuber of words in the region.Words are defined as at least one word-constituent
character followed by at least one character that is not a word-constituent.The buffer's
syntax table determines which characters these are."
  (interactive "r")
  (message "Counting words in region...")
  (save-excursion
    (goto-char beginning)
    (let ((count 0))
      (while (< (point) end)
        (re-search-forward "\\w+\\W*")
        (setq count (1+ count))
        )
      (cond ((zerop count)
             (message
              "The region does not have any words."))
            ((= 1 count )
             (message
              "The region has 1 word."))
            (t
             (message
              "The region has %d words." count))
            )
      )
    )
  )

										; count words recursively
