#lang racket
(require "utils.rkt")
(require (only-in sha sha256))
(require racket/serialize)

(serializable-struct transaction-io (hash value owner) #:transparent)

(define (calculate-transaction-io-hash value owner)
  (sha256 (bytes-append
           (string->bytes/utf-8 (number->string value))
           (string->bytes/utf-8 (~a (serialize owner))))))

(define (make-transaction-io value owner)
  (transaction-io
   (calculate-transaction-io-hash value owner)
   value
   owner))

(define (valid-transaction-io? t-in)
  (equal? (transaction-io-hash t-in)
          (calculate-transaction-io-hash (transaction-io-value t-in)
                                         (transaction-io-owner t-in))))

(provide (struct-out transaction-io) make-transaction-io valid-transaction-io?)
