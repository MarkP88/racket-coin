#lang racket
(require sha)

(require "block.rkt")
(require "blockchain.rkt")

(define seed-hash (string->bytes/utf-8 "seed"))
(define my-block (make-block "Hello world 1" seed-hash))

(define blockchain (blockchain-init my-block))
(set! blockchain (blockchain-add blockchain "Hello world 2"))
(set! blockchain (blockchain-add blockchain "Hello world 3"))

(define (print-block block)
  (printf "Block information\n=================\nHash:\t~a\nHash_p:\t~a\nData:\t~a\nStamp:\t~a\nNonce:\t~a\n"
          (bytes->hex-string (block-hash block))
          (bytes->hex-string (block-previous-hash block))
          (block-data block)
          (block-timestamp block)
          (block-nonce block)))

(for ([block blockchain])
  (print-block block)
  (newline))

(printf "Blockchain is valid: ~a\n" (blockchain-valid? blockchain))