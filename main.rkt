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

(define (print-wallets wallet-a wallet-b)
  (printf "\nWallet A balance: ~a\nWallet B balance: ~a\n\n"
          (balance-wallet-blockchain blockchain wallet-a)
          (balance-wallet-blockchain blockchain wallet-b)))

(when (file-exists? "blockchain.data")
  (begin
    (printf "Found 'blockchain.data', reading...\n")
    (print-blockchain (file->struct "blockchain.data"))
    (exit)))

; Initialize wallets
(define scheme-coin-base (make-wallet))
(define wallet-a (make-wallet))
(define wallet-b (make-wallet))

; Transactions
(printf "Making genesis transaction...\n")
(define genesis-t (make-transaction scheme-coin-base wallet-a 100 '()))

; Unspent transactions (store our genesis transaction)
(define utxo (list
              (make-transaction-io 100 wallet-a)))

; Blockchain initiation
(printf "Mining genesis block...\n")
(define blockchain (init-blockchain genesis-t (string->bytes/utf-8 "seedgenesis") utxo))
(print-wallets wallet-a wallet-b)

; Make a second transaction
(printf "Mining second transaction...\n")
(set! blockchain (send-money-blockchain blockchain wallet-a wallet-b 20))
(print-wallets wallet-a wallet-b)

; Make a third transaction
(printf "Mining third transaction...\n")
(set! blockchain (send-money-blockchain blockchain wallet-b wallet-a 10))
(print-wallets wallet-a wallet-b)

; Attempt to make a fourth transaction
(printf "Attempting to mine fourth (not-valid) transaction...\n")
(set! blockchain (send-money-blockchain blockchain wallet-b wallet-a 200))
(print-wallets wallet-a wallet-b)

(printf "Blockchain is valid: ~a\n\n" (valid-blockchain? blockchain))

(for ([block (blockchain-blocks blockchain)])
  (print-block block)
  (newline))

(struct->file blockchain "blockchain.data")
(printf "Exported blockchain to 'blockchain.data'...\n")
