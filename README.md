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
Block information
=================
Hash:	fb2090676653b0bcda23e4db3dd6d6f1513307a27d06424dd174f6218560158f
Hash_p:	5b203db03d917d7e3ab770cbbce199a3240f30f272ace040edb9be2c320b9cd2
Data:	2828332920342028282f55736572732f626f726f2f4465736b746f702f736368...
Stamp:	1529578072652
Nonce:	507

Block information
=================
Hash:	5b203db03d917d7e3ab770cbbce199a3240f30f272ace040edb9be2c320b9cd2
Hash_p:	73656564
Data:	28283329203020282920302028292028292048656c6c6f20576f726c6429
Stamp:	1529578072650
Nonce:	792

Blockchain is valid: #t
```

Boro Sitnikovski

Licensed under GPL.  Read LICENSE for more information.

June, 2018
