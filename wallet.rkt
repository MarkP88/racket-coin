#lang racket
(require crypto)
(require crypto/libcrypto)
(require crypto/all)
(require "utils.rkt")

(struct wallet (private-key public-key))

; We need to use all crypto factories for converting the key between hex<->pk-key
(use-all-factories!)

(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet (bytes->hex-string (pk-key->datum privkey 'PrivateKeyInfo))
            (bytes->hex-string (pk-key->datum pubkey 'SubjectPublicKeyInfo)))))

(define (generate-signature privkey sender recipient value)
  (digest/sign (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
               'sha1
               (string->bytes/latin-1 (string-append sender recipient value))))

(define (verify-signature pubkey sig sender recipient value)
  (digest/verify (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
                 'sha1
                 (string->bytes/latin-1 (string-append sender recipient value))
                 sig))

#|
(define test-wallet (make-wallet))

(define signature (generate-signature (wallet-private-key test-wallet) "test" "test" "test"))
(verify-signature (wallet-public-key test-wallet) signature "test" "test" "test")
|#

(provide (struct-out wallet) make-wallet generate-signature verify-signature)
