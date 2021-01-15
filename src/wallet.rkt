#lang racket

(struct wallet
  (private-key public-key)
  #:prefab)

; Make wallet by generating random public and private keys.
(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet (bytes->hex-string
             (pk-key->datum privkey 'PrivateKeyInfo))
            (bytes->hex-string
             (pk-key->datum pubkey 'SubjectPublicKeyInfo)))))

(require crypto)
(require crypto/all)

(provide (struct-out wallet) make-wallet)
