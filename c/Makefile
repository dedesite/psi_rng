CC = gcc
RM = rm -f
CFLAGS = -Wall -O
LDFLAGS = -lwebsockets
NAME = rng
SERVER = $(NAME)_server
OBJ = $(NAME).o \
	$(NAME)_server.o
PREFIX = /usr/local

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(SERVER).o -o $(SERVER) $(LDFLAGS)
	$(CC) $(CFLAGS) $(NAME).o -o $(NAME)

clean:
	$(RM) $(OBJ)

fclean: clean
	$(RM) $(NAME)
	$(RM) $(SERVER)

re: fclean all
    
install: $(NAME)
	install -m 0755 $(SERVER) $(PREFIX)/bin
	install -m 0755 $(NAME) $(PREFIX)/bin
	install -m 0755 $(NAME).sh /etc/init.d

.PHONY: all clean fclean re install