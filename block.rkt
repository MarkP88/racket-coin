#lang racket
(require (only-in sha sha256))

(define difficulty 2)
(define target (make-bytes difficulty 32))

(struct block (hash previous-hash data timestamp nonce))

(define (calculate-block-hash previous-hash timestamp data nonce)
  (sha256 (bytes-append
           previous-hash
           (string->bytes/utf-8 (number->string timestamp))
           (string->bytes/utf-8 data)
           (string->bytes/utf-8 (number->string nonce)))))

(define (valid-block? block)
  (eq? (block-hash block)
       (calculate-block-hash (block-previous-hash block)
                             (block-timestamp block)
                             (block-data block)
                             (block-nonce block))))

(define (mined-block? hash)
  (equal? (subbytes hash 1 difficulty)
          (subbytes target 1 difficulty)))

(define (mine-block target previous-hash timestamp data nonce)
  (let ([hash (calculate-block-hash previous-hash timestamp data nonce)])
    (if (mined-block? hash)
        (block hash previous-hash data timestamp nonce)
        (mine-block target previous-hash timestamp data (+ nonce 1)))))

(define (make-block data previous-hash)
  (mine-block target previous-hash (current-milliseconds) data 1))

(provide (struct-out block) make-block valid-block? mined-block?)
