#lang racket

(require "transaction.rkt")

(define (valid-transaction-contract? t c)
  (and (eval-contract t c)
       (valid-transaction? t)))

(define (eval-contract t c)
  (match c
    [(? number? x) x]
    [(? string? x) x]
    [`() #t]
    [`true #t]
    [`false #f]
    [`(if ,co ,tr ,fa) (if (eval-contract t co)
                           (eval-contract t tr)
                           (eval-contract t fa))]
    [`(+ ,l ,r) (+ (eval-contract t l) (eval-contract t r))]
    [`from (transaction-from t)]
    [`to (transaction-to t)]
    [`value (transaction-value t)]
    [`(+ ,l ,r) (+ (eval-contract t l) (eval-contract t r))]
    [`(* ,l ,r) (* (eval-contract t l) (eval-contract t r))]
    [`(- ,l ,r) (- (eval-contract t l) (eval-contract t r))]
    [`(= ,l ,r) (= (eval-contract t l) (eval-contract t r))]
    [`(> ,l ,r) (> (eval-contract t l) (eval-contract t r))]
    [`(< ,l ,r) (< (eval-contract t l) (eval-contract t r))]
    [`(and ,l ,r) (and (eval-contract t l) (eval-contract t r))]
    [`(or ,l ,r) (or (eval-contract t l) (eval-contract t r))]
    [else #f]))

(provide valid-transaction-contract?)
