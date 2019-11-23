Racket-Coin v1.0 by Boro Sitnikovski
====================================
To clone me: Write `git clone git@github.com:bor0/racket-coin.git`.

You can run [DrRacket](https://racket-lang.org/) with `main.rkt`. Otherwise, for command line, first install dependencies by writing `make deps` and then run `make` or `make run`.

Some reads related to the project:

- My book [Gentle Introduction to Blockchain with Lisp](https://leanpub.com/gibl)
- Logic is based on [this tutorial](https://medium.com/programmers-blockchain/create-simple-blockchain-java-tutorial-from-scratch-6eeed3cb03fa).
- Short theoretical tutorial [here](https://blockgeeks.com/guides/what-is-bitcoin/).
- Bitcoin paper [here](https://bitcoin.org/bitcoin.pdf).

Project structure:
- `main.rkt` contains an example code which uses the other files.
- `main-helper.rkt` contains printing and other helper procedures for `main.rkt`.
- `main-p2p.rkt` contains an example code which uses the other files, plus peer-to-peer support.
- `src/` contains all the files for the actual implementation:
  - `blockchain.rkt` contains the implementation of the blockchain.
  - `block.rkt` contains the implementation of a block.
  - `wallet.rkt` contains the implementation of a wallet.
  - `transaction.rkt` contains the implementation of transactions.
  - `transaction-io.rkt` contains the implementation for input and output transactions.
  - `utils.rkt` contains some generally useful procedures.
  - `peer-to-peer.rkt` contains procedures for syncing blockchains between peers, syncing valid peers, etc.

Note that this is just an example cryptocurrency implementation in Racket and is not intended to be run in production.

Example output:
```
Making genesis transaction...
Mining genesis block...

Wallet A balance: 100
Wallet B balance: 0

Mining second transaction...

Wallet A balance: 130
Wallet B balance: 20

Mining third transaction...

Wallet A balance: 140
Wallet B balance: 60

Attempting to mine fourth (not-valid) transaction...

Wallet A balance: 140
Wallet B balance: 60

Blockchain is valid: #t

Block information
=================
Hash:	e720bb198279a76057280bdf8eb667fe1883d0ae263c5d5d1be08697a2f534d1
Hash_p:	38200563c1f807be2a5d10ec42dd53acae1f6f804b4c93016b87c974817f065d
Stamp:	1529923610574
Nonce:	216
Data:	...bb6573e30a994990... sends ...896a71a68be970f6... an amount of 10.

Block information
=================
Hash:	38200563c1f807be2a5d10ec42dd53acae1f6f804b4c93016b87c974817f065d
Hash_p:	6a20fbe4038bb3b83090e7f767bb24af5164218bba5c751a1858262df2a2a847
Stamp:	1529923610405
Nonce:	752
Data:	...896a71a68be970f6... sends ...bb6573e30a994990... an amount of 20.

Block information
=================
Hash:	6a20fbe4038bb3b83090e7f767bb24af5164218bba5c751a1858262df2a2a847
Hash_p:	7365656467656e65736973
Stamp:	1529923610332
Nonce:	220
Data:	...58d498c68aefe93a... sends ...896a71a68be970f6... an amount of 100.

Exported blockchain to 'blockchain.data'...
```

Peer to peer example:
1. Run the first peer by doing `racket main-p2p.rkt test.data 7000 127.0.0.1:7001,127.0.0.1:7002`, and wait a few seconds so that it can populate the DB.
Now close the peer. You should get similar output to:
```
boro@bor0:~$ racket main-p2p.rkt test.data 7000 127.0.0.1:7001,127.0.0.1:7002
Making genesis transaction...
Mining genesis block...
Mined a block!
Mined a block!
Exported blockchain to 'test.data'...
Peer Test peer reports 2 valid peers.
Mined a block!
```
2. Run the second peer by doing `racket main-p2p.rkt test-2.data 7001 127.0.0.1:7000`, and wait a few seconds so that it can populate the DB. Should get similar output to above.
3. Now re-run the first peer, while keeping the second peer active. After a few mins, you should get:
```
Blockchain updated for peer Test peer
Mined a block!
Mined a block!
Exported blockchain to 'test.data'...
```
Depending on which of the peers has a bigger effort on the blockchain, both files should match it.

To double check, we compare the DB before:
```
boro@bor0:~/misc/sources/racket-coin$ ls -al test*.data
-rw-r--r--  1 boro  staff  5232 Jul 13 01:41 test-2.data
-rw-r--r--  1 boro  staff  3849 Jul 13 01:41 test.data
```

And after the peers have synced:
```
boro@bor0:~/misc/sources/racket-coin$ ls -al test*.data
-rw-r--r--  1 boro  staff  5232 Jul 13 01:41 test-2.data
-rw-r--r--  1 boro  staff  5232 Jul 13 01:41 test.data
```

Basic support for smart contracts is implemented. To use it in action, write this to `contract.script`:

```racket
(if (or (= value 100) (= value 20)) true false)
```

Next time you run `make run` it will only allow the example transactions in `main.rkt` of value 100 and 20.

Boro Sitnikovski

Licensed under GPL.  Read LICENSE for more information.

June, 2018
