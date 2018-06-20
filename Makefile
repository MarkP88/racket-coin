clean:
	rm -rf compiled *.rkt~

run:
	racket main.rkt

all:
	raco exe main.rkt
