#lang racket
(require "block.rkt")
(require "transaction.rkt")
(require "utils.rkt")
(require "wallet.rkt")
(require "smart-contracts.rkt")

(struct blockchain
  (blocks utxo)
  #:prefab)

; Procedure for initialization of the blockchain
(define (init-blockchain t seed-hash utxo)
  (blockchain (cons (mine-block (process-transaction t) seed-hash) '())
              utxo))

; Start with 50 coins initially, and halve them on every 210000 blocks
(define (mining-reward-factor blocks)
  (/ 50 (expt 2 (floor (/ (length blocks) 210000)))))

; Add transaction to blockchain by processing the unspent transaction outputs
(define (add-transaction-to-blockchain b t)
  (letrec ([hashed-blockchain
            (mine-block t (block-hash (car (blockchain-blocks b))))]
           [processed-inputs (transaction-inputs t)]
           [processed-outputs (transaction-outputs t)]
           [utxo (set-union processed-outputs
                            (set-subtract (blockchain-utxo b)
                                          processed-inputs))]
           [new-blocks (cons hashed-blockchain (blockchain-blocks b))]
           [utxo-rewarded (cons
                           (make-transaction-io
                            (mining-reward-factor new-blocks)
                            (transaction-from t))
                           utxo)])
    (blockchain
     new-blocks
     utxo-rewarded)))

; Send money from one wallet to another by initiating transaction, and then adding it to the blockchain for processing
(define (send-money-blockchain b from to value c)
  (letrec ([my-ts
            (filter (lambda (t) (equal? from (transaction-io-owner t)))
                    (blockchain-utxo b))]
           [t (make-transaction from to value my-ts)])
    (if (transaction? t)
        (let ([processed-transaction (process-transaction t)])
          (if (and
               (>= (balance-wallet-blockchain b from) value)
               (valid-transaction-contract? processed-transaction c))
              (add-transaction-to-blockchain b processed-transaction)
              b))
        (add-transaction-to-blockchain b '()))))

; The balance of a wallet is determined by the sum of all unspent transactions for the matching owner
(define (balance-wallet-blockchain b w)
  (letrec ([utxo (blockchain-utxo b)]
           [my-ts (filter
                   (lambda (t) (equal? w (transaction-io-owner t)))
                   utxo)])
    (foldr + 0 (map (lambda (t) (transaction-io-value t)) my-ts))))

; A blockchain is valid if...
(define (valid-blockchain? b)
  (let ([blocks (blockchain-blocks b)])
    (and
     ; All blocks are valid
     (true-for-all? valid-block? blocks)
     ; Previous hashes are matching
     (equal? (drop-right (map block-previous-hash blocks) 1)
             (cdr (map block-hash blocks)))
     ; All transactions are valid
     (true-for-all?
      valid-transaction? (map
                          (lambda (block) (block-transaction block))
                          blocks))
     ; All blocks are mined
     (true-for-all?
      mined-block? (map block-hash blocks)))))

(provide (all-from-out "block.rkt")
         (all-from-out "transaction.rkt")
         (all-from-out "wallet.rkt")
         (struct-out blockchain)
         init-blockchain send-money-blockchain
         balance-wallet-blockchain valid-blockchain?)
