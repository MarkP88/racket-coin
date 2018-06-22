#lang racket
(require crypto)
(require crypto/all)
(require racket/serialize)

(serializable-struct wallet (private-key public-key) #:transparent)

(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet (bytes->hex-string (pk-key->datum privkey 'PrivateKeyInfo))
            (bytes->hex-string (pk-key->datum pubkey 'SubjectPublicKeyInfo)))))

(provide (struct-out wallet) make-wallet)
