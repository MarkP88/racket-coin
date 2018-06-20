#lang racket
(require (only-in sha sha256))
(require crypto)
(require crypto/libcrypto)
(require crypto/all)
(require "wallet.rkt")
(require "utils.rkt")
(require racket/serialize)

; We need to use all crypto factories for converting the key between hex<->pk-key
(use-all-factories!)

(serializable-struct transaction-input (signature hash index value from))
(serializable-struct transaction-output (to value))

(define (sign-transaction-input hash index value from)
  (let ([privkey (wallet-private-key from)]
        [pubkey (wallet-public-key from)])
    (digest/sign (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
                 'sha1
                 (bytes-append
                  (string->bytes/utf-8 hash)
                  (string->bytes/utf-8 (~a (serialize index)))
                  (string->bytes/utf-8 (number->string value))
                  (string->bytes/utf-8 (~a (serialize from)))))))

(define (make-transaction-input hash index value from)
  (transaction-input
   (sign-transaction-input hash index value from)
   hash
   index
   value
   from))

(define (valid-transaction-signature? transaction-in)
  (let ([pubkey (wallet-public-key (transaction-input-from transaction-in))])
    (digest/verify (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
                   'sha1
                   (bytes-append
                    (string->bytes/utf-8 (transaction-input-hash transaction-in))
                    (string->bytes/utf-8 (~a (serialize (transaction-input-index transaction-in))))
                    (string->bytes/utf-8 (number->string (transaction-input-value transaction-in)))
                    (string->bytes/utf-8 (~a (serialize (transaction-input-from transaction-in)))))
                   (transaction-input-signature transaction-in))))

(define (make-transaction-output to value) (transaction-output to value))

(provide (struct-out transaction-input) (struct-out transaction-output) make-transaction-input valid-transaction-signature? make-transaction-output)
