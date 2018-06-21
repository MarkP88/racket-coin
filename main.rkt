#lang racket
(require (only-in sha bytes->hex-string))
(require "utils.rkt")
(require "block.rkt")
(require "blockchain.rkt")
(require "wallet.rkt")
(require "transaction.rkt")
(require "transaction-io.rkt")

; Wallet and transaction test
(define wallet-a (make-wallet))
(define wallet-b (make-wallet))

(define tr (make-transaction 1
                             (list (make-transaction-input "hash" "1" 15 wallet-a))
                             (list (make-transaction-output wallet-b 15))))

(printf "Transaction is valid: ~a\n" (valid-transaction? tr))

; Blockchain test
(define seed-hash (string->bytes/utf-8 "seed"))
(define my-block (make-block (struct->string "Hello World") seed-hash))

(define blockchain (blockchain-init my-block))
(set! blockchain (blockchain-add blockchain (struct->string tr)))

(define (print-block block)
  (printf "Block information\n=================\nHash:\t~a\nHash_p:\t~a\nData:\t~a\nStamp:\t~a\nNonce:\t~a\n"
          (bytes->hex-string (block-hash block))
          (bytes->hex-string (block-previous-hash block))
          (bytes->hex-string (string->bytes/utf-8 (block-data block)))
          (block-timestamp block)
          (block-nonce block)))

(for ([block blockchain])
  (print-block block)
  (newline))

(printf "Blockchain is valid: ~a\n" (blockchain-valid? blockchain))
