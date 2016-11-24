phase1 : lex.yy.c bison_decaf.tab.c
	gcc -g -Wall main.c bison_decaf.tab.c -lfl -ly -o phase1

bison_decaf.tab.h bison_decaf.tab.c : bison_decaf.y
	bison -d -v bison_decaf.y

lex.yy.c : bison_decaf.tab.h flex_decaf.l
	flex flex_decaf.l

clean :
	rm phase1 bison_decaf.tab.* lex.yy.c

test1 :
	./phase1 test/test_lab1_1

test2 :
	./phase2 test/test_lab2
