all:
	raco exe main.rkt

clean:
	rm -rf main *.rkt~ src/*.rkt~ src/compiled blockchain.data

run:
	racket main.rkt
