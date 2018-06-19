#lang racket
(require "block.rkt")
(require "blockchain.rkt")

(define seed-hash (string->bytes/utf-8 "seed"))
(define my-block (make-block "Hello world 1" seed-hash))

(define blockchain (blockchain-init my-block))
(set! blockchain (blockchain-add blockchain "Hello world 2"))
(set! blockchain (blockchain-add blockchain "Hello world 3"))

#|
(block-hash (car blockchain))
(block-previous-hash (car blockchain))
(block-data (car blockchain))
(block-timestamp (car blockchain))
(block-nonce (car blockchain))

(block-hash (cadr blockchain))
(block-previous-hash (cadr blockchain))
(block-data (cadr blockchain))
(block-timestamp (cadr blockchain))
(block-nonce (cadr blockchain))

(block-hash (caddr blockchain))
(block-previous-hash (caddr blockchain))
(block-data (caddr blockchain))
(block-timestamp (caddr blockchain))
(block-nonce (caddr blockchain))
|#

(blockchain-valid? blockchain)