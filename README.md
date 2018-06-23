Scheme-Coin v1.0 by Boro Sitnikovski
====================================
To clone me: Write `git clone git@github.com:bor0/scheme-coin.git`.

You can run [DrRacket](https://racket-lang.org/) with `main.rkt`, or run `make` or `make run` from the command line.

Some readings related to the project:
- Logic is based on [this tutorial](https://medium.com/programmers-blockchain/create-simple-blockchain-java-tutorial-from-scratch-6eeed3cb03fa) (with over-simplified transactions logic (no UTXO and just checks logic for the current inputs/outputs)).
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
boro@bor0:~/Desktop/scheme-coin$ make run
racket main.rkt
Transaction is valid: #t
Mining genesis block...
Mining transaction...
Blockchain is valid: #t

Block information
=================
Hash:	9920fe6ca3738b399e2266567ef5aae2f82a9b748955aba6afbe93ce0945d307
Hash_p:	c22015e6fb1641d81c43a219f801b237bda6e899b09b5e4cb0f0e56e5a80984e
Stamp:	1529745156344
Nonce:	829
Data:	(transaction #"wD\322U\246\253h<l\205m8\27...

Block information
=================
Hash:	c22015e6fb1641d81c43a219f801b237bda6e899b09b5e4cb0f0e56e5a80984e
Hash_p:	7365656467656e65736973
Stamp:	1529745156343
Nonce:	49
Data:	"Hello World"
```

Boro Sitnikovski

Licensed under GPL.  Read LICENSE for more information.

June, 2018
