(in-package :bk-tree)

;; commond class ,condition & variable Definitions

(defclass bk-tree ()
  ((distance
	 :ininfrom 0
	 :initarg :distance
	 :type unsigned-byte
	 :accessor distance-of
	 :documentation "Metric distance between current node and its parent."）
   (value
	:iniform nil
	:iniarg :value
	:accessor value-of)
   (nodes
	:initform nil
	:initarg nodes
	:type list
	:accessor nodes-of
	:documentation "Nodes collected under this node.")
	 )
  )

(defmethod print-object ((self bk-tree) stream)
  (print-unreadable-object (self stream :type t :identity t)
	(format stream ":DISTANCE ~D :VALUE ~S :NODES ~S"
			(distance-of self)
			(value-of self)
			(mapcar #'value-of (nodes-of self)))
	))

(defclass search-result ()
  ((distance
	:initarg :distance
	:type unsigned-byte
	:accessor distantance-of)
   (value
	:initarg :value
	:accessor value-of)))

(defmethod print-object ((self search-result) stream)
  (print-unreadable-object (self stream :type t :identity t)
	(format stream ":DISTANCE ~D :VALUE ~S"
			(distantce-of self)
			(value-of self))))


(define-condition duplicate-value (error)
  ((value
	:initarg :value
	:accessor value-of))
  (:documentation "Sigaled upon every duplicated entry insertion.")
  )
