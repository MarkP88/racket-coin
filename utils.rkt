#lang racket
(require "block.rkt")
(require racket/serialize)

(define ASCII-ZERO (char->integer #\0))

;; [0-9A-Fa-f] -> Number from 0 to 15
(define (hex-char->number c)
  (if (char-numeric? c)
      (- (char->integer c) ASCII-ZERO)
      (match c
        [(or #\a #\A) 10]
        [(or #\b #\B) 11]
        [(or #\c #\C) 12]
        [(or #\d #\D) 13]
        [(or #\e #\E) 14]
        [(or #\f #\F) 15]
        [_ (error 'hex-char->number "invalid hex char: ~a\n" c)])))

(define (hex-string->bytes str) (list->bytes (hex-string->bytelist str)))
(define (hex-string->bytelist str)
  (with-input-from-string
      str
    (thunk
     (let loop ()
       (define c1 (read-char))
       (define c2 (read-char))
       (cond [(eof-object? c1) null]
             [(eof-object? c2) (list (hex-char->number c1))]
             [else (cons (+ (* (hex-char->number c1) 16)
                            (hex-char->number c2))
                         (loop))])))))

(define (true-for-all? pred list)
  (cond
    [(empty? list) #t]
    [(pred (first list)) (true-for-all? pred (rest list))]
    [else #f]))

; Export a struct to a file
(define (struct->file object file)
  (let ([out (open-output-file file #:exists 'replace)])
    (write (serialize object) out)
    (close-output-port out)))

; Import struct contents from a file
(define (file->struct file)
  (letrec ([in (open-input-file file)]
           [result (read in)])
    (close-input-port in)
    (deserialize result)))

(provide hex-string->bytes true-for-all? struct->file file->struct)
