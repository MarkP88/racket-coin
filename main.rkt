#lang racket
(require "blockchain.rkt")
(require "utils.rkt")

; Wallet and transaction test
(define scheme-coin-base (make-wallet))
(define wallet-a (make-wallet))
(define wallet-b (make-wallet))

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

(printf "Wallet A balance: ~a\nWallet B balance: ~a\n"
        (balance-wallet-blockchain blockchain wallet-a)
        (balance-wallet-blockchain blockchain wallet-b))

(newline)

(printf "Mining transaction...\n")
(set! blockchain (send-money-blockchain blockchain wallet-a wallet-b 50))

(printf "Wallet A balance: ~a\nWallet B balance: ~a\n"
        (balance-wallet-blockchain blockchain wallet-a)
        (balance-wallet-blockchain blockchain wallet-b))

(newline)

(printf "Blockchain is valid: ~a\n" (valid-blockchain? blockchain))

(newline)

(for ([block (blockchain-blocks blockchain)])
  (print-block block)
  (newline))
