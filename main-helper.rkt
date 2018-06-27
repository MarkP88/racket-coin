#lang racket
(require "./src/blockchain.rkt")
(require "./src/utils.rkt")
(require (only-in sha bytes->hex-string))

(define (format-transaction t)
  (format "...~a... sends ...~a... an amount of ~a."
          (substring (wallet-public-key (transaction-from t)) 64 80)
          (substring (wallet-public-key (transaction-to t)) 64 80)
          (transaction-value t)))

(define (print-block block)
  (printf "Block information\n=================\nHash:\t~a\nHash_p:\t~a\nStamp:\t~a\nNonce:\t~a\nData:\t~a\n"
          (bytes->hex-string (block-hash block))
          (bytes->hex-string (block-previous-hash block))
          (block-timestamp block)
          (block-nonce block)
          (format-transaction (block-transaction block))))

(define (print-blockchain b)
  (for ([block (blockchain-blocks b)])
    (print-block block)
    (newline)))

(define (print-wallets blockchain wallet-a wallet-b)
  (printf "\nWallet A balance: ~a\nWallet B balance: ~a\n\n"
          (balance-wallet-blockchain blockchain wallet-a)
          (balance-wallet-blockchain blockchain wallet-b)))

(provide (all-from-out "./src/blockchain.rkt")
         (all-from-out "./src/utils.rkt")
         format-transaction print-block print-blockchain print-wallets)
