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

(define (add-transaction-to-blockchain b t)
  (letrec ([hashed-blockchain (mine-block t (block-hash (car (blockchain-blocks b))))]
           [processed-inputs (transaction-inputs t)]
           [processed-outputs (transaction-outputs t)]
           [utxo (set-union processed-outputs (set-subtract (blockchain-utxo b) processed-inputs))])
    (blockchain
     (cons hashed-blockchain (blockchain-blocks b))
     utxo)))

(define (add-blockchain b t)
  (let ([processed-transaction (process-transaction t)])
    (if (valid-transaction? processed-transaction)
        (add-transaction-to-blockchain b processed-transaction)
        b)))

(define (send-money-blockchain b from to value)
  (letrec ([my-ts (filter (lambda (t) (equal? from (transaction-io-owner t))) (blockchain-utxo b))]
           [t (make-transaction from to value my-ts)])
    (add-blockchain b t)))

(define (balance-wallet-blockchain b w)
  (letrec ([utxo (blockchain-utxo b)]
           [my-ts (filter (lambda (t) (equal? w (transaction-io-owner t))) utxo)])
    (foldr + 0 (map (lambda (t) (transaction-io-value t)) my-ts))))

(define (valid-blockchain? b)
  (let ([blocks (blockchain-blocks b)])
    (and
     ; Compare calculated hashes
     (true-for-all? valid-block? blocks)
     ; Compare previous hashes
     (equal? (drop-right (map block-previous-hash blocks) 1)
             (cdr (map block-hash blocks)))
     ; All transactions are valid
     (true-for-all? valid-transaction? (map (lambda (block) (block-transaction block)) blocks))
     ; Check that block is mined
     (true-for-all? mined-block? (map block-hash blocks)))))

(provide (all-from-out "block.rkt")
         (all-from-out "transaction.rkt")
         (all-from-out "wallet.rkt")
         (struct-out blockchain)
         init-blockchain send-money-blockchain balance-wallet-blockchain valid-blockchain?)
