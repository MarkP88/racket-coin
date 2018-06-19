#lang racket
(require (only-in sha sha256))
(require crypto)
(require crypto/libcrypto)
(require crypto/all)
(require "utils.rkt")
(require "wallet.rkt")

; We need to use all crypto factories for converting the key between hex<->pk-key
(use-all-factories!)

(struct transaction (sequence from to value inputs))

(define (calculate-transaction-hash transaction)
  (sha256 (bytes-append
           (string->bytes/utf-8 (wallet-public-key (transaction-from transaction)))
           (string->bytes/utf-8 (wallet-public-key (transaction-to transaction)))
           (string->bytes/utf-8 (number->string (transaction-value transaction)))
           (string->bytes/utf-8 (number->string (transaction-sequence transaction))))))

(define (transaction-generate-signature transaction)
  (let ([privkey (wallet-private-key (transaction-from transaction))]
        [sender (wallet-public-key (transaction-from transaction))]
        [recipient (wallet-public-key (transaction-to transaction))]
        [value (number->string (transaction-value transaction))])
    (digest/sign (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
                 'sha1
                 (string->bytes/latin-1 (string-append sender recipient value)))))

(define (transaction-verify-signature? transaction sig)
  (let ([pubkey (wallet-public-key (transaction-from transaction))]
        [sender (wallet-public-key (transaction-from transaction))]
        [recipient (wallet-public-key (transaction-to transaction))]
        [value (number->string (transaction-value transaction))])
    (digest/verify (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
                   'sha1
                   (string->bytes/latin-1 (string-append sender recipient value))
                   sig)))

(provide (struct-out transaction) calculate-transaction-hash transaction-generate-signature transaction-verify-signature?)
