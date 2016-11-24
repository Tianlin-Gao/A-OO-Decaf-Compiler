total : lex.yy.c bison_decaf.tab.c
	gcc -g -Wall main.c bison_decaf.tab.c -lfl -ly -o phase2

bison_decaf.tab.h bison_decaf.tab.c : bison_decaf.y
	bison -d -v bison_decaf.y

lex.yy.c : bison_decaf.tab.h flex_decaf.l
	flex flex_decaf.l

clean :
	rm phase2 bison_decaf.tab.* lex.yy.c

test2 :
	./phase2 test/test_lab2_1
