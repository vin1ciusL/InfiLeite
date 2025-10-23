CC=gcc
CFLAGS=-O2 -Wall

parser: parser.tab.c lexer.c exec.o runtime.o main.o
	$(CC) $(CFLAGS) -o parser parser.tab.c lexer.c exec.o runtime.o main.o -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d -v parser.y

lexer.c: lexer.l parser.tab.h
	flex -o lexer.c lexer.l

exec.o: exec.c ast.h
	$(CC) $(CFLAGS) -c exec.c

runtime.o: runtime.c ast.h
	$(CC) $(CFLAGS) -c runtime.c

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

clean:
	rm -f parser lexer.c parser.tab.* parser.output *.o