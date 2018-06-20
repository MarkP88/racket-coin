all:
	raco exe main.rkt

clean:
	rm -rf compiled *.rkt~

run:
	racket main.rkt
