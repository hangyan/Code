;; example code of "Programming in Emacs"


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
  (interactive "*p\nZap to char: ")
  (kill-region (point)
			   (progn
				 (search-forward
				  (char-to-string char) nil nil arg)
				 (point))))
(zap-to-char 3 'z)
