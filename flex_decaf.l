%option yylineno

%{
    #include <stdio.h>
    #include <stdlib.h>
%}

letter [a-zA-Z_]
digit [0-9]
char [0-9a-zA-Z_]
hexdigit [0-9a-f]
typedef [int|float|bool|string|void]
%%
"+" {printf("plus\n");}
"-" {printf("minus\n" );}
"*" {printf("mutiply\n" );}
"/" {printf("divide\n" );}
"%"  {printf("mod\n" );}
"//" {
    printf("find comments\n" );
    char c;
    while((c = input()) != '\n');
}
\/\*[^\*\/]*\*\/ {
    printf("find mutiple comments\n");
}
{digit}+ {printf("find decimal %d\n", atoi(yytext));}
0x{hexdigit}+ {
    char *temp;
    printf("find hexdigit %lx\n", strtol(yytext+2,&temp, 16));
}
{letter}{char}* {printf("find ID %s\n", yytext);}
\n {}
[ \t] {}  /* 忽略空白字符，否则会识别为.（ERROR）*/
. printf("Error at line %d : %s\n", yylineno, yytext);

%%
