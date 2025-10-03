CC=gcc
LEX=flex
CFLAGS=-O2 -Wall

all: lab01_lex

lab01_lex: lexer.l
	$(LEX) -o lexer.c lexer.l
	$(CC) $(CFLAGS) -o lab01_lex lexer.c -lfl

clean:
	rm -f lab01_lex lexer.c
