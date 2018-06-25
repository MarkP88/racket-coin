#lang racket
(require "transaction-io.rkt")
(require "utils.rkt")
(require "wallet.rkt")
(require crypto)
(require crypto/all)
(require racket/serialize)

(serializable-struct transaction (signature from to value inputs outputs) #:transparent)

(use-all-factories!)

(define (sign-transaction from to value)
  (let ([privkey (wallet-private-key from)]
        [pubkey (wallet-public-key from)])
    (digest/sign (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
                 'sha1
                 (bytes-append
                  (string->bytes/utf-8 (~a (serialize from)))
                  (string->bytes/utf-8 (~a (serialize to)))
                  (string->bytes/utf-8 (number->string value))))))

(define (make-transaction from to value inputs)
  (transaction
   (sign-transaction from to value)
   from
   to
   value
   inputs
   '()))

(define (valid-transaction-signature? t)
  (let ([pubkey (wallet-public-key (transaction-from t))])
    (digest/verify (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
                   'sha1
                   (bytes-append
                    (string->bytes/utf-8 (~a (serialize (transaction-from t))))
                    (string->bytes/utf-8 (~a (serialize (transaction-to t))))
                    (string->bytes/utf-8 (number->string (transaction-value t))))
                   (transaction-signature t))))

(define (valid-transaction? transaction)
  (let ([sum-inputs (foldr + 0 (map (lambda (t) (transaction-input-value t)) (transaction-inputs transaction)))]
        [sum-outputs (foldr + 0 (map (lambda (t) (transaction-output-value t)) (transaction-outputs transaction)))])
  (and
   (valid-transaction-signature? transaction)
   (true-for-all? valid-transaction-input? (transaction-inputs transaction))
   (>= sum-inputs sum-outputs))))

(provide (all-from-out "transaction-io.rkt")
         (struct-out transaction) make-transaction valid-transaction?)
