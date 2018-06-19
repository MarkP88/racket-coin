#lang racket
(require "block.rkt")

(define (blockchain-init blockchain) (cons blockchain '()))

(define (blockchain-add blockchain data)
  (let ([blockchain-hashed (make-block data (block-hash (car blockchain)))])
    (cons blockchain-hashed blockchain)))

(define (true-for-all? pred list)
  (cond
    [(empty? list) #t]
    [(pred (first list)) (true-for-all? pred (rest list))]
    [else #f]))

(define (blockchain-valid? blockchain)
  ; Compare calculated hashes
  (true-for-all? valid-block? blockchain)
  ; Compare previous hashes
  (equal? (drop-right (map block-previous-hash blockchain) 1)
          (cdr (map block-hash blockchain)))
  ; Check that block is mined
  (true-for-all? mined-block? (map block-hash blockchain)))

(provide blockchain-init blockchain-add blockchain-valid?)
