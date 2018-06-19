#lang racket
(require crypto)
(require crypto/libcrypto)

(struct wallet (private-key public-key))

(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet privkey pubkey)))

(define (print-wallet wallet)
  (printf "private: ~a\npublic: ~a\n"
          (bytes->hex-string (pk-key->datum (wallet-private-key wallet) 'PrivateKeyInfo))
          (bytes->hex-string (pk-key->datum (wallet-public-key wallet) 'SubjectPublicKeyInfo))))

(provide (struct-out wallet) make-wallet print-wallet)
