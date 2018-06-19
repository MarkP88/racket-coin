#lang racket
(require crypto)
(require crypto/libcrypto)

(struct wallet (private-key public-key))

(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet privkey pubkey)))

(define (generate-signature privkey sender recipient value)
  (digest/sign privkey
               'sha1
               (string->bytes/latin-1 (string-append sender recipient value))))

(define (verify-signature pubkey sig sender recipient value)
  (digest/verify pubkey
                 'sha1
                 (string->bytes/latin-1 (string-append sender recipient value))
                 sig))

(define (print-wallet wallet)
  (printf "private: ~a\npublic: ~a\n"
          (bytes->hex-string (pk-key->datum (wallet-private-key wallet) 'PrivateKeyInfo))
          (bytes->hex-string (pk-key->datum (wallet-public-key wallet) 'SubjectPublicKeyInfo))))

(define test-wallet (make-wallet))

(define signature (generate-signature (wallet-private-key test-wallet) "test" "test" "test"))
(verify-signature (wallet-public-key test-wallet) signature "test" "test" "test")

(provide (struct-out wallet) make-wallet print-wallet)
