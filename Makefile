all:
	raco exe main.rkt

clean:
	rm -rf main compiled *.rkt~ blockchain.data

run:
	racket main.rkt
