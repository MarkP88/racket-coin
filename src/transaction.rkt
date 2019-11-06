#lang racket
(require "transaction-io.rkt")
(require "utils.rkt")
(require "wallet.rkt")
(require crypto)
(require crypto/all)
(require racket/serialize)
(require (only-in file/sha1 hex-string->bytes))

(struct transaction (signature from to value inputs outputs) #:prefab)

; We need to use all crypto factories for converting the key between hex<->pk-key
(use-all-factories!)

; Return digested signature of a transaction data
(define (sign-transaction from to value)
  (let ([privkey (wallet-private-key from)]
        [pubkey (wallet-public-key from)])
    (bytes->hex-string (digest/sign (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
                 'sha1
                 (bytes-append
                  (string->bytes/utf-8 (~a (serialize from)))
                  (string->bytes/utf-8 (~a (serialize to)))
                  (string->bytes/utf-8 (number->string value)))))))

; Make an empty, unprocessed and unsigned transaction
(define (make-transaction from to value inputs)
  (transaction
   ""
   from
   to
   value
   inputs
   '()))

; Processing transaction procedure
(define (process-transaction t)
  (letrec ([inputs (transaction-inputs t)]
           [outputs (transaction-outputs t)]
           [value (transaction-value t)]
           ; Sum all the inputs
           [inputs-sum (foldr + 0 (map (lambda (i) (transaction-io-value i)) inputs))]
           ; To calculate leftover (inputs-val - value)
           [leftover (- inputs-sum value)]
           ; Generate new outputs to be used in the new signed and processed transaction
           [new-outputs (list
                         (make-transaction-io value (transaction-to t))
                         (make-transaction-io leftover (transaction-from t)))])
    (transaction
     (sign-transaction (transaction-from t)
                       (transaction-to t)
                       (transaction-value t))
     (transaction-from t)
     (transaction-to t)
     value
     inputs
     (remove-duplicates (append new-outputs outputs)))))

; Checks the signature validity of a transaction
(define (valid-transaction-signature? t)
  (let ([pubkey (wallet-public-key (transaction-from t))])
    (digest/verify (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
                   'sha1
                   (bytes-append
                    (string->bytes/utf-8 (~a (serialize (transaction-from t))))
                    (string->bytes/utf-8 (~a (serialize (transaction-to t))))
                    (string->bytes/utf-8 (number->string (transaction-value t))))
                   (hex-string->bytes (transaction-signature t)))))

; A transaction is valid if...
(define (valid-transaction? t)
  (let ([sum-inputs (foldr + 0 (map (lambda (t) (transaction-io-value t)) (transaction-inputs t)))]
        [sum-outputs (foldr + 0 (map (lambda (t) (transaction-io-value t)) (transaction-outputs t)))])
    (and
     ; Its signature is valid
     (valid-transaction-signature? t)
     ; All outputs are valid
     (true-for-all? valid-transaction-io? (transaction-outputs t))
     ; The sum of the inputs is gte the sum of the outputs
     (>= sum-inputs sum-outputs))))

(provide (all-from-out "transaction-io.rkt")
         (struct-out transaction) make-transaction process-transaction valid-transaction?)
