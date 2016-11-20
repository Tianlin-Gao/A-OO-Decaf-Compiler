%option yylineno
%{
        char linebuf[500];
    #include <stdio.h>
    #include <stdlib.h>
    #include "bison_decaf.tab.h"

    #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;\
    yylloc.first_column = yycolumn;\
    yylloc.last_column = yycolumn + yyleng - 1;\
    yycolumn += yyleng;

    int yycolumn = 1;
%}



letter [a-zA-Z_]
digit [0-9]
char [0-9a-zA-Z_]
hexdigit [0-9a-f]
typedef [int|float|bool|string|void]
%%
"+" {
    // printf("plus\n");
    return PLUS;
}
"-" {
    // printf("minus\n" );
    return MINUS;
}

"*" {
    // printf("mutiply\n" );
    return TIMES;
}
"/" {
    // printf("divide\n" );
    return DIVIDE;
}
"%"  {
    // printf("mod\n" );
    return MOD;
}
"<"  {
    // printf("smaller\n" );
    return LESS;
}
"<="  {
    // printf("mod\n" );
    return LESSEQ;
}
">"  {
    // printf("mod\n" );
    return MORE;
}
">="  {
    // printf("mod\n" );
    return MOREEQ;
}
"=="  {
    // printf("mod\n" );
    return EQ;
}
"!="  {
    // printf("mod\n" );
    return NOTEQ;
}
"&&"  {
    // printf("mod\n" );
    return AND;
}
"||"  {
    // printf("||\n" );
    return OR;
}
"!"  {
    // printf("mod\n" );
    return NOT;
}
","  {
    // printf("mod\n" );
    return COMMA;
}
";"  {
    // printf("mod\n" );
    return SEMI;
}
"."  {
    // printf("mod\n" );
    return PERIOD;
}
"static"  {
    // printf("mod\n" );
    return STATIC;
}
"int"  {
    // printf("mod\n" );
    return INT;
}
"bool"  {
    // printf("mod\n" );
    return BOOL;
}
"string"  {
    // printf("mod\n" );
    return STRING;
}
"void"  {
    // printf("mod\n" );
    return VOID;
}
"null"  {
    // printf("mod\n" );
    return NUL;
}
"print"  {
    // printf("mod\n" );
    return PRINT;
}
"ReadInteger"  {
    // printf("mod\n" );
    return READINTEGER;
}
"ReadLine"  {
    // printf("mod\n" );
    return READLINE;
}
"instanceof"  {
    // printf("mod\n" );
    return INSTANCEOF;
}
"["  {
    // printf("mod\n" );
    return LB;
}
"]"  {
    // printf("mod\n" );
    return RB;
}
"("  {
    // printf("mod\n" );
    return LP;
}
")"  {
    // printf("mod\n" );
    return RP;
}
"{"  {
    // printf("mod\n" );
    return LC;
}
"}"  {
    // printf("mod\n" );
    return RC;
}
"="  {
//不一定要在==之后 因为尽可能匹配长的
    // printf("mod\n" );
    return ASSIGNOP;
}
"extends"  {
    // printf("mod\n" );
    return EXTENDS;
}
"class"  {
    // printf("class\n" );
    return CLASS;
}
"this"  {
    // printf("mod\n" );
    return THIS;
}
"new"  {
    // printf("mod\n" );
    return NEW;
}
"if"  {
    // printf("mod\n" );
    return IF;
}
"else"  {
    // printf("mod\n" );
    return ELSE;
}
"while"  {
    // printf("mod\n" );
    return WHILE;
}
"for"  {
    // printf("for\n" );
    return FOR;
}
"return"  {
    // printf("mod\n" );
    return RETURN;
}
"break"  {
    // printf("mod\n" );
    return BREAK;
}
"//" {
    // printf("find comments\n" );
    char c;
    while((c = input()) != '\n');
}

\"[^\"]*\" {
    if(yytext[yyleng = 2] == '\\'){
        yyless(yyleng - 1);
        yymore();
    }
    else{
        // printf("%s", yytext);
        return STRINGCONSTANT;
    }
}

\/\*[^\*\/]*\*\/ {
    // printf("find mutiple comments\n");
}
{letter}{char}* {
    // printf("find ID %s\n", yytext);
    yylval.type_str = strdup(yytext);
    return ID;
}
{digit}+ {
    // printf("find decimal %d\n", atoi(yytext));
    yylval.type_int = atoi(yytext);
    return INTCONSTANT;
}
0x{hexdigit}+ {
    char *temp;
    // printf("find hexdigit %lx\n", strtol(yytext+2,&temp, 16));
    yylval.type_int = strtol(yytext+2,&temp, 16);
    return INTCONSTANT;
}
\n.* {
    strncpy(linebuf, yytext + 1, sizeof(linebuf));
    yycolumn = 1;
    yyless(1);
}

[ \t] {}  /* 忽略空白字符，否则会识别为.（ERROR）*/
. printf("Error at line %d : %s\n", yylineno, yytext);

%%
