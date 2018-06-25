#lang racket
(require "block.rkt")
(require "transaction.rkt")
(require "utils.rkt")
(require "wallet.rkt")
(require racket/serialize)

(serializable-struct blockchain (blocks utxo))

(define (init-blockchain t seed-hash utxo)
  (blockchain (cons (mine-block (process-transaction t) seed-hash) '())
              utxo))

(define (add-blockchain b t)
  (let ([hashed-blockchain (mine-block t (block-hash (car (blockchain-blocks b))))])
    (blockchain (cons hashed-blockchain (blockchain-blocks b)) (blockchain-utxo b))))

(define (valid-blockchain? b)
  (let ([blocks (blockchain-blocks b)])
    (and
     ; Compare calculated hashes
     (true-for-all? valid-block? blocks)
     ; Compare previous hashes
     (equal? (drop-right (map block-previous-hash blocks) 1)
             (cdr (map block-hash blocks)))
     ; Any data that is a transaction should be valid
     (true-for-all?
      (lambda (block)
        (if (transaction? (block-transaction block)) (valid-transaction? (block-transaction block)) #t)) blocks)
     ; Check that block is mined
     (true-for-all? mined-block? (map block-hash blocks)))))

(provide (all-from-out "block.rkt")
         (all-from-out "transaction.rkt")
         (all-from-out "wallet.rkt")
         (struct-out blockchain)
         init-blockchain add-blockchain valid-blockchain?)
