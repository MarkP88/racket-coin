#lang racket
(require "block.rkt")
(require "transaction.rkt")
(require "utils.rkt")
(require "wallet.rkt")

(define (init-blockchain data seed-hash) (cons (mine-block data seed-hash) '()))

(define (add-blockchain blockchain data)
  (let ([hashed-blockchain (mine-block data (block-hash (car blockchain)))])
    (cons hashed-blockchain blockchain)))

(define (valid-blockchain? blockchain)
  (and
   ; Compare calculated hashes
   (true-for-all? valid-block? blockchain)
   ; Compare previous hashes
   (equal? (drop-right (map block-previous-hash blockchain) 1)
           (cdr (map block-hash blockchain)))
   ; Any data that is a transaction should be valid
   (true-for-all?
    (lambda (block)
      (if (transaction? (block-transaction block)) (valid-transaction? (block-transaction block)) #t)) blockchain)
   ; Check that block is mined
   (true-for-all? mined-block? (map block-hash blockchain))))

(provide (all-from-out "block.rkt")
         (all-from-out "transaction.rkt")
         (all-from-out "wallet.rkt")
         init-blockchain add-blockchain valid-blockchain?)
