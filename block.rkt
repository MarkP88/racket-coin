#lang racket
(require (only-in sha sha256))
(require racket/serialize)

(define difficulty 2)
(define target (make-bytes difficulty 32))

(serializable-struct block (hash previous-hash transaction timestamp nonce) #:transparent)

(define (calculate-block-hash previous-hash timestamp transaction nonce)
  (sha256 (bytes-append
           previous-hash
           (string->bytes/utf-8 (number->string timestamp))
           (string->bytes/utf-8 (~a (serialize transaction)))
           (string->bytes/utf-8 (number->string nonce)))))

(define (valid-block? block)
  (equal? (block-hash block)
          (calculate-block-hash (block-previous-hash block)
                                (block-timestamp block)
                                (block-transaction block)
                                (block-nonce block))))

(define (mined-block? hash)
  (equal? (subbytes hash 1 difficulty)
          (subbytes target 1 difficulty)))

(define (make-and-mine-block target previous-hash timestamp transaction nonce)
  (let ([hash (calculate-block-hash previous-hash timestamp transaction nonce)])
    (if (mined-block? hash)
        (block hash previous-hash transaction timestamp nonce)
        (make-and-mine-block target previous-hash timestamp transaction (+ nonce 1)))))

(define (mine-block transaction previous-hash)
  (make-and-mine-block target previous-hash (current-milliseconds) transaction 1))

(provide (struct-out block) mine-block valid-block? mined-block?)
