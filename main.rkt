#lang racket
(require "blockchain.rkt")
(require "utils.rkt")

; Wallet and transaction test
(define wallet-a (make-wallet))
(define wallet-b (make-wallet))

(define tr (make-transaction 1
                             (list (make-transaction-input "hash" "1" 15 wallet-a))
                             (list (make-transaction-output wallet-b 15))))

(printf "Transaction is valid: ~a\n" (valid-transaction? tr))

; Blockchain test
(printf "Mining genesis block...\n")
(define blockchain (blockchain-init "Hello World" (string->bytes/utf-8 "seedgenesis")))
(printf "Mining transaction...\n")
(set! blockchain (blockchain-add blockchain tr))

(printf "Blockchain is valid: ~a\n" (blockchain-valid? blockchain))

(newline)

(for ([block blockchain])
  (print-block block)
  (newline))
