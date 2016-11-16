objects = flex_main.o lex.yy.o
exec = scanner
$(exec) : $(objects)
	gcc -g  $(objects) -lfl -o  $(exec)

flex_main.o : flex_main.c
	gcc -g -c -Wall flex_main.c
lex.yy.o : lex.yy.c
	gcc -g -c -Wall  lex.yy.c
lex.yy.c : flex_decaf.l
	flex flex_decaf.l

clean:
	rm $(objects) $(exec)

test:
	./scanner test_decaf
