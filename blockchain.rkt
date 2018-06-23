#lang racket
(require "block.rkt")
(require "transaction.rkt")
(require "utils.rkt")
(require "wallet.rkt")

(define (blockchain-init data seed-hash) (cons (mine-block data seed-hash) '()))

(define (blockchain-add blockchain data)
  (let ([blockchain-hashed (mine-block data (block-hash (car blockchain)))])
    (cons blockchain-hashed blockchain)))

(define (blockchain-valid? blockchain)
  (and
   ; Compare calculated hashes
   (true-for-all? valid-block? blockchain)
   ; Compare previous hashes
   (equal? (drop-right (map block-previous-hash blockchain) 1)
           (cdr (map block-hash blockchain)))
   ; Any data that is a transaction should be valid
   (true-for-all?
    (lambda (block)
      (if (transaction? (block-data block)) (valid-transaction? (block-data block)) #t)) blockchain)
   ; Check that block is mined
   (true-for-all? mined-block? (map block-hash blockchain))))

(provide (all-from-out "block.rkt")
         (all-from-out "transaction.rkt")
         (all-from-out "wallet.rkt")
         blockchain-init blockchain-add blockchain-valid?)
