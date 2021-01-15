#lang racket
(require "blockchain.rkt")
(require "block.rkt")
(require racket/serialize)

; Peer info structure contains an ip and a port
(struct peer-info
  (ip port)
  #:prefab)

; Peer info IO structure additionally contains IO ports
(struct peer-info-io
  (pi input-port output-port)
  #:prefab)

; Peer context data contains all information needed for a single peer.
(struct peer-context-data
  (name
   port
   [valid-peers #:mutable]
   [connected-peers #:mutable]
   [blockchain #:mutable])
  #:prefab)

; Generic handler
(define (handler peer-context in out)
  (flush-output out)
  (define line (read-line in))
  (when (string? line) ; it can be eof
    (cond [(string-prefix? line "get-valid-peers")
           (fprintf out "valid-peers:~a\n"
                    (serialize
                     (set->list
                      (peer-context-data-valid-peers peer-context))))
           (handler peer-context in out)]
          [(string-prefix? line "get-latest-blockchain")
           (fprintf out "latest-blockchain:")
           (write
            (serialize (peer-context-data-blockchain peer-context)) out)
           (handler peer-context in out)]
          [(string-prefix? line "latest-blockchain:")
           (begin (maybe-update-blockchain peer-context line)
                  (handler peer-context in out))]
          [(string-prefix? line "valid-peers:")
           (begin (maybe-update-valid-peers peer-context line)
                  (handler peer-context in out))]
          [(string-prefix? line "exit")
           (fprintf out "bye\n")]
          [else (handler peer-context in out)])))

; Handler for updating latest blockchain
(define (maybe-update-blockchain peer-context line)
  (let ([latest-blockchain
         (trim-helper line #rx"(latest-blockchain:|[\r\n]+)")]
        [current-blockchain
         (peer-context-data-blockchain peer-context)])
    (when (and (valid-blockchain? latest-blockchain)
               (> (get-blockchain-effort latest-blockchain)
                  (get-blockchain-effort current-blockchain)))
      (printf "Blockchain updated for peer ~a\n"
              (peer-context-data-name peer-context))
      (set-peer-context-data-blockchain! peer-context
                                         latest-blockchain))))

; Procedure for getting the sum of nonces of a blockchain.
; Highest one has most effort and will win to get updated throughout the peers.
(define (get-blockchain-effort b)
  (foldl + 0 (map block-nonce (blockchain-blocks b))))

; Handler for updating valid peers
(define (maybe-update-valid-peers peer-context line)
  (let ([valid-peers (list->set
                      (trim-helper line #rx"(valid-peers:|[\r\n]+)"))]
        [current-valid-peers (peer-context-data-valid-peers
                              peer-context)])
    (set-peer-context-data-valid-peers!
     peer-context
     (set-union current-valid-peers valid-peers))))

(define (trim-helper line x)
  (deserialize
   (read
    (open-input-string
     (string-replace line x "")))))

; Helper to launch handler thread (incoming connections)
(define (accept-and-handle listener peer-context)
  (define-values (in out) (tcp-accept listener))
  (thread
   (lambda ()
     (handler peer-context in out)
     (close-input-port in)
     (close-output-port out))))

; Procedure for serving peers
(define (peers/serve peer-context)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define listener
      (tcp-listen (peer-context-data-port peer-context) 5 #t))
    (define (loop)
      (accept-and-handle listener peer-context)
      (loop))
    (thread loop))
  (lambda ()
    (custodian-shutdown-all main-cust)))

; Helper to launch handler thread (outgoing connections)
(define (connect-and-handle peer-context peer)
  (begin
    (define-values (in out)
      (tcp-connect (peer-info-ip peer)
                   (peer-info-port peer)))

    (define current-peer-io (peer-info-io peer in out))

    (set-peer-context-data-connected-peers!
     peer-context
     (cons current-peer-io
           (peer-context-data-connected-peers peer-context)))

    (thread
     (lambda ()
       (handler peer-context in out)
       (close-input-port in)
       (close-output-port out)

       (set-peer-context-data-connected-peers!
        peer-context
        (set-remove
         (peer-context-data-connected-peers peer-context)
         current-peer-io))))))

; Handler for connecting to peers
(define (peers/connect peer-context)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define (loop)
      (let ([potential-peers (get-potential-peers peer-context)])
        (for ([peer potential-peers])
          (with-handlers ([exn:fail? (lambda (x) #t)])
            (connect-and-handle peer-context peer))))
      (sleep 10)
      (loop))
    (thread loop))
  (lambda ()
    (custodian-shutdown-all main-cust)))

; Get the potential peers from the peer context (subtract connected peers)
(define (get-potential-peers peer-context)
  (let ([current-connected-peers
         (list->set
          (map peer-info-io-pi
               (peer-context-data-connected-peers peer-context)))]
        [valid-peers (peer-context-data-valid-peers peer-context)])
    (set-subtract valid-peers current-connected-peers)))

; Procedure for syncing data between peers
(define (peers/sync-data peer-context)
  (define (loop)
    (sleep 10)
    (for [(p (peer-context-data-connected-peers peer-context))]
      (let ([in (peer-info-io-input-port p)]
            [out (peer-info-io-output-port p)])
        (fprintf out "get-latest-blockchain\nget-valid-peers\n")
        (flush-output out)))
    (printf "Peer ~a reports ~a valid and ~a connected peers.\n"
            (peer-context-data-name peer-context)
            (set-count
             (peer-context-data-valid-peers peer-context))
            (set-count
             (peer-context-data-connected-peers peer-context)))
    (loop))
  (define t (thread loop))
  (lambda ()
    (kill-thread t)))

; Helper procedure for running a peer-to-peer connection.
(define (run-peer peer-context)
  (begin
    (peers/serve peer-context)
    (peers/connect peer-context)
    (peers/sync-data peer-context)))

(provide (struct-out peer-context-data)
         (struct-out peer-info)
         run-peer)
