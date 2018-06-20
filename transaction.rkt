#lang racket
(require (only-in sha sha256))
(require "utils.rkt")
(require "transaction-io.rkt")
(require racket/serialize)

(serializable-struct transaction (hash id inputs outputs))

(define (calculate-transaction-hash id inputs outputs)
  (sha256 (bytes-append
           (string->bytes/utf-8 (number->string id))
           (string->bytes/utf-8 (~a (serialize inputs)))
           (string->bytes/utf-8 (~a (serialize outputs))))))

(define (make-transaction id inputs outputs)
  (transaction (calculate-transaction-hash id inputs outputs)
               id
               inputs
               outputs))

(define (valid-transaction? transaction)
  (let ([sum-inputs (foldr + 0 (map (lambda (t) (transaction-input-value t)) (transaction-inputs transaction)))]
        [sum-outputs (foldr + 0 (map (lambda (t) (transaction-output-value t)) (transaction-outputs transaction)))])
  (and
   (equal? (transaction-hash transaction) (calculate-transaction-hash (transaction-id transaction) (transaction-inputs transaction) (transaction-outputs transaction)))
   (true-for-all? valid-transaction-signature? (transaction-inputs transaction))
   (>= sum-inputs sum-outputs))))

(provide (struct-out transaction) make-transaction valid-transaction?)
