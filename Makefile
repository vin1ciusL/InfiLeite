CC=gcc
CFLAGS=-O2 -Wall

all: parser

parser: lexer.c parser.tab.c main.c
	$(CC) $(CFLAGS) -o parser lexer.c parser.tab.c main.c -lfl

lexer.c: lexer.l parser.tab.h
	flex -o lexer.c lexer.l

parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

clean:
	rm -f parser lexer.c parser.tab.* parser.output
