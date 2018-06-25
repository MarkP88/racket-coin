#lang racket
(require "blockchain.rkt")
(require "utils.rkt")

; Wallet and transaction test
(define scheme-coin-base (make-wallet))
(define wallet-a (make-wallet))
(define wallet-b (make-wallet))

(define tr (make-transaction wallet-a wallet-b 15 '()))

(printf "Transaction is valid: ~a\n" (valid-transaction? tr))

(define utxo (list
              (make-transaction-io 100 wallet-a)))

(printf "Making genesis transaction...\n")
(define genesis-t (make-transaction scheme-coin-base
                                    wallet-a
                                    100
                                    '()))


; Blockchain test
(printf "Mining genesis block...\n")
(define blockchain (init-blockchain genesis-t (string->bytes/utf-8 "seedgenesis") utxo))
(printf "Mining transaction...\n")
(set! blockchain (add-blockchain blockchain tr))

(printf "Blockchain is valid: ~a\n" (valid-blockchain? blockchain))

(newline)

(for ([block (blockchain-blocks blockchain)])
  (print-block block)
  (newline))
