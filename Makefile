total : total_main.c lex.yy.c bison_decaf.tab.c
	gcc -g -Wall total_main.c bison_decaf.tab.c -lfl -ly -o total

bison_decaf.tab.h bison_decaf.tab.c : bison_decaf.y
	bison -d -v bison_decaf.y

lex.yy.c : bison_decaf.tab.h flex_decaf.l
	flex flex_decaf.l

clean :
	rm total bison_decaf.tab.* lex.yy.c

test :
	./total test_bison
