#lang racket

(require "transaction.rkt")

(define (valid-transaction-with-contract? t contract)
  (and (eval-contract t contract)
       (valid-transaction? t)))

(define (eval-contract t c)
  (let ([eval-binary
         (lambda (op l r)
           (op (eval-contract t l)
               (eval-contract t r)))])
    (match c
      [(? number? x) x]
      [(? string? x) x]
      [`() #t]
      [`true #t]
      [`false #f]
      [`(if ,co ,tr ,fa) (if (eval-contract t co) (eval-contract t tr) (eval-contract t fa))]
      [`from (transaction-from t)]
      [`to (transaction-to t)]
      [`value (transaction-value t)]
      [`(* ,l ,r) (eval-binary * l r)]
      [`(+ ,l ,r) (eval-binary + l r)]
      [`(- ,l ,r) (eval-binary - l r)]
      [`(= ,l ,r) (eval-binary equal? l r)]
      [`(> ,l ,r) (eval-binary > l r)]
      [`(< ,l ,r) (eval-binary < l r)]
      [`(and ,l ,r) (eval-binary (lambda (l r) (and l r)) l r)] ; convert this to procedure since and is syntax
      [`(or ,l ,r) (eval-binary (lambda (l r) (or l r)) l r)]
      [else #f])))

(provide valid-transaction-with-contract?)
