Scheme-Coin v1.0 by Boro Sitnikovski
====================================
To clone me: Write `git clone git@github.com:bor0/scheme-coin.git`.

You can run [DrRacket](https://racket-lang.org/) with `main.rkt`. Otherwise, for command line, first install dependencies by writing `raco pkg install sha crypto-lib` and then run `make` or `make run`.

Some readings related to the project:
- Logic is based on [this tutorial](https://medium.com/programmers-blockchain/create-simple-blockchain-java-tutorial-from-scratch-6eeed3cb03fa).
- Short theoretical tutorial [here](https://blockgeeks.com/guides/what-is-bitcoin/).
- Bitcoin paper [here](https://bitcoin.org/bitcoin.pdf).

Project structure:
- `main.rkt` contains an example code which uses the other files.
- `blockchain.rkt` contains the implementation of the blockchain.
- `block.rkt` contains the implementation of a block.
- `wallet.rkt` contains the implementation of a wallet.
- `transaction.rkt` contains the implementation of transactions.
- `transaction-io.rkt` contains the implementation for input and output transactions.
- `utils.rkt` contains some generally useful procedures.

Note that this is just an example cryptocurrency implementation in Scheme and is not intended to be run in production.

Example output:
```
Making genesis transaction...
Mining genesis block...

Wallet A balance: 100
Wallet B balance: 0

Mining second transaction...

Wallet A balance: 80
Wallet B balance: 20

Mining third transaction...

Wallet A balance: 90
Wallet B balance: 10

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
```

Boro Sitnikovski

Licensed under GPL.  Read LICENSE for more information.

June, 2018
