(load-file  "~/Emacs/dev/http/request.el")

(request
 "http://httpbin.org/get"
 :params '(("key" . "value") ("key2" . "value2"))
 :parser 'json-read
 :success (function*
           (lambda (&key data &allow-other-keys)
             (message "I sent: %S" (assoc-default 'args data)))))



(request
 "https://getpocket.com/v3/oauth/request"
 :type "POST"
 :data '(("consumer_key" . "31547-629fbec67e06e4af52cf970b"))
 :parser 'json-read
 :success (function*
           (lambda (&key data &allow-other-keys)
             (message "I sent: %S" (assoc-default 'form data)))))

