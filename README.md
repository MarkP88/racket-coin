Scheme-Coin v1.0 by Boro Sitnikovski
====================================
To clone me: Write `git clone git@github.com:bor0/scheme-coin.git`.

You can run [DrRacket](https://racket-lang.org/) with `main.rkt`, or run `make` or `make run` from the command line.

Some readings related to the project:
- Logic is based on [this tutorial](https://medium.com/programmers-blockchain/create-simple-blockchain-java-tutorial-from-scratch-6eeed3cb03fa) (with over-simplified transactions logic).
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

Boro Sitnikovski

Licensed under GPL.  Read LICENSE for more information.

June, 2018
