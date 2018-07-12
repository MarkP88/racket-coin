#lang racket
(require "utils.rkt")
(require (only-in sha sha256))
(require (only-in sha bytes->hex-string))
(require racket/serialize)

(define difficulty 2)
(define target (bytes->hex-string (make-bytes difficulty 32)))

(struct block (hash previous-hash transaction timestamp nonce) #:prefab)

; Procedure for calculating block hash
(define (calculate-block-hash previous-hash timestamp transaction nonce)
  (bytes->hex-string (sha256 (bytes-append
           (string->bytes/utf-8 previous-hash)
           (string->bytes/utf-8 (number->string timestamp))
           (string->bytes/utf-8 (~a (serialize transaction)))
           (string->bytes/utf-8 (number->string nonce))))))

; A block is valid if...
(define (valid-block? bl)
  ; the hash is correct
  (equal? (block-hash bl)
          (calculate-block-hash (block-previous-hash bl)
                                (block-timestamp bl)
                                (block-transaction bl)
                                (block-nonce bl))))

; A block is mined if
(define (mined-block? hash)
  ; the hash matches the target, given the difficulty
  (equal? (subbytes (hex-string->bytes hash) 1 difficulty)
          (subbytes (hex-string->bytes target) 1 difficulty)))

; Hashcash implementation
(define (make-and-mine-block target previous-hash timestamp transaction nonce)
  (let ([hash (calculate-block-hash previous-hash timestamp transaction nonce)])
    (if (mined-block? hash)
        (block hash previous-hash transaction timestamp nonce)
        (make-and-mine-block target previous-hash timestamp transaction (+ nonce 1)))))

; Wrapper around make-and-mine-block
(define (mine-block transaction previous-hash)
  (make-and-mine-block target previous-hash (current-milliseconds) transaction 1))

(provide (struct-out block) mine-block valid-block? mined-block?)
