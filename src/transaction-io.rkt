#lang racket
(require "utils.rkt")
(require (only-in sha sha256))
(require racket/serialize)

(serializable-struct transaction-io (hash value owner timestamp) #:transparent)

; Procedure for calculating the hash of a transaction-io object
(define (calculate-transaction-io-hash value owner timestamp)
  (sha256 (bytes-append
           (string->bytes/utf-8 (number->string value))
           (string->bytes/utf-8 (~a (serialize owner)))
           (string->bytes/utf-8 (number->string timestamp)))))

; Make a transaction-io object with calculated hash
(define (make-transaction-io value owner)
  (let ([timestamp (current-milliseconds)])
    (transaction-io
     (calculate-transaction-io-hash value owner timestamp)
     value
     owner
     timestamp)))

; A transaction-io is valid if...
(define (valid-transaction-io? t-in)
  ; the hash is correct
  (equal? (transaction-io-hash t-in)
          (calculate-transaction-io-hash (transaction-io-value t-in)
                                         (transaction-io-owner t-in)
                                         (transaction-io-timestamp t-in))))

(provide (struct-out transaction-io) make-transaction-io valid-transaction-io?)
