#lang racket
(require "utils.rkt")
(require (only-in sha sha256))
(require racket/serialize)

(serializable-struct transaction-input (signature hash index value from) #:transparent)
(serializable-struct transaction-output (to value) #:transparent)

(define (calculate-transaction-input-hash value owner)
  (sha256 (bytes-append
           (string->bytes/utf-8 (number->string value))
           (string->bytes/utf-8 (~a (serialize owner))))))

(define (make-transaction-input hash index value from)
  (transaction-input
   (calculate-transaction-input-hash hash index value from)
   hash
   index
   value
   from))

(define (valid-transaction-input? transaction-in)
  (equal? (transaction-input-hash transaction-in)
          (calculate-transaction-input-hash (transaction-input-value transaction-in)
                                            (transaction-input-from transaction-in))))

(define (make-transaction-output to value) (transaction-output to value))

(provide (struct-out transaction-input) (struct-out transaction-output) make-transaction-input valid-transaction-input? make-transaction-output)
