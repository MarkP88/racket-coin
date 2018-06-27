all:
	raco exe main.rkt

clean:
	rm -rf main *.rkt~ src/*.rkt~ compiled src/compiled blockchain.data

deps:
	raco pkg install sha crypto-lib

run:
	racket main.rkt
