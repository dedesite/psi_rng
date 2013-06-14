rng: rng_server.c rng.c
	gcc -Wall -O rng_server.c -o rng_server /usr/local/lib/libwebsockets.so
	gcc -Wall -O rng.c -o rng

prefix=/usr/local
    
install: rng_server rng
	install -m 0755 rng_server $(prefix)/bin
	install -m 0755 rng $(prefix)/bin
	install -m 0755 rng.sh /etc/init.d