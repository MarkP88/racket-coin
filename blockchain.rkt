#lang racket
(require "block.rkt")
(require "utils.rkt")

(define (blockchain-init blockchain) (cons blockchain '()))

(define (blockchain-add blockchain data)
  (let ([blockchain-hashed (make-block data (block-hash (car blockchain)))])
    (cons blockchain-hashed blockchain)))

(define (blockchain-valid? blockchain)
  (and
   ; Compare calculated hashes
   (true-for-all? valid-block? blockchain)
   ; Compare previous hashes
   (equal? (drop-right (map block-previous-hash blockchain) 1)
           (cdr (map block-hash blockchain)))
   ; Check that block is mined
   (true-for-all? mined-block? (map block-hash blockchain))))

(provide blockchain-init blockchain-add blockchain-valid?)
