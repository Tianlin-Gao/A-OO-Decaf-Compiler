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

    void yyerror(const char *s, ...);
    extern int error_flag;
%}



letter [a-zA-Z_]
digit [0-9]
char [0-9a-zA-Z_]
hexdigit [0-9a-f]
COMMENT (\/\/.*)|(\/\*((\*[^\/]?)|[^\*]*)*\*\/)

typedef [int|float|bool|string|void]
%%
"+" {

    printf("(%s, PLUS)\n", yytext);
    return PLUS;
}


{COMMENT} {
    printf("find comments\n");

}

"-" {
    // printf("minus\n" );
    printf("(%s, MINUS)\n", yytext);
    return MINUS;
}

"*" {
    // printf("mutiply\n" );
    printf("(%s, TIMES)\n", yytext);
    return TIMES;
}
"/" {
    // printf("divide\n" );
    printf("(%s, DIVIDE)\n", yytext);
    return DIVIDE;
}
"%"  {
    // printf("mod\n" );
    printf("(%s, MOD)\n", yytext);
    return MOD;
}
"<"  {
    // printf("sma
    printf("(%s, LESS)\n", yytext);
    return LESS;
}
"<="  {
    // printf("mod\n
    printf("(%s, LESSEQ)\n", yytext);
    return LESSEQ;
}
">"  {
    // printf("mod\n
    printf("(%s, MORE)\n", yytext);
    return MORE;
}
">="  {
    // printf("mod\n"
    printf("(%s, MOREEQ)\n", yytext);
    return MOREEQ;
}
"=="  {
    // printf("mod\n
    printf("(%s, EQ)\n", yytext);
    return EQ;
}
"!="  {
    // printf("mod\n
    printf("(%s,NOTEQ)\n", yytext);
    return NOTEQ;
}
"&&"  {
    // printf("mod\n
    printf("(%s, AND)\n", yytext);
    return AND;
}
"||"  {
    // printf("||\n"
    printf("(%s, OR)\n", yytext);
    return OR;
}
"!"  {
    // printf("mod\n"
    printf("(%s, NOT)\n", yytext);
    return NOT;
}
","  {
    // printf("mod\n" );
    printf("(%s, COMMA)\n", yytext);
    return COMMA;
}
";"  {
    // printf("mod\n
    printf("(%s, SEMI)\n", yytext);
    return SEMI;
}
"."  {
    // printf("mod\n
    printf("(%s, PERIOD)\n", yytext);
    return PERIOD;
}
"static"  {
    // printf("mod\n"
    printf("(%s, STATIC)\n", yytext);
    return STATIC;
}
"int"  {
    // printf("mod\n"
    printf("(%s, INT)\n", yytext);
    return INT;
}
"bool"  {
    // printf("mod\n"
    printf("(%s, BOOL)\n", yytext);
    return BOOL;
}
"string"  {
    // printf("mod\n"
    printf("(%s, STRING)\n", yytext);
return STRING;
}
"void"  {
    // printf("mod\n"
    printf("(%s, VOID)\n", yytext);
    return VOID;
}
"null"  {
    // printf("mod\n"
    printf("(%s, NULL)\n", yytext);
    return NUL;
}
"print"  {
    // printf("mod\n"
    printf("(%s, PRINT)\n", yytext);
    return PRINT;
}
"ReadInteger"  {
    // printf("mod\n"
    printf("(%s, READINTEGER)\n", yytext);
    return READINTEGER;
}
"ReadLine"  {
    // printf("mod\n"
    printf("(%s, READLINE)\n", yytext);
    return READLINE;
}
"instanceof"  {
    // printf("mod\n"
    printf("(%s, INSTANCEOF)\n", yytext);
    return INSTANCEOF;
}
"["  {
    // printf("mod\n"
    printf("(%s, LB)\n", yytext);
    return LB;
}
"]"  {
    // printf("mod\n"
    printf("(%s, RB)\n", yytext);
    return RB;
}
"("  {
    // printf("mod\n"
    printf("(%s, LP)\n", yytext);
    return LP;
}
")"  {
    // printf("mod\n"
    printf("(%s, RP)\n", yytext);
    return RP;
}
"{"  {
    // printf("mod\n"
    printf("(%s, LC)\n", yytext);
    return LC;
}
"}"  {
    // printf("mod\n"
    printf("(%s, RC)\n", yytext);
    return RC;
}
"="  {
//不一定要在==之后 因为尽
    printf("(%s, ASSIGNOP)\n", yytext);
    // printf("mod\n" );
    return ASSIGNOP;
}
"extends"  {
    // printf("mod\n"
    printf("(%s, EXTENDS)\n", yytext);
    return EXTENDS;
}
"class"  {
    // printf("class\n"
    printf("(%s, CLASS)\n", yytext);
    return CLASS;
}
"this"  {
    // printf("mod\n"
    printf("(%s,THIS)\n", yytext);
    return THIS;
}
"new"  {
    // printf("mod\n"
    printf("(%s, NEW)\n", yytext);
    return NEW;
}
"if"  {
    // printf("mod\n"
    printf("(%s, IF)\n", yytext);
    return IF;
}
"else"  {
    // printf("mod\n"
    printf("(%s, ELSE)\n", yytext);
    return ELSE;
}
"while"  {
    // printf("mod\n"
    printf("(%s, WHILE)\n", yytext);
    return WHILE;
}
"for"  {
    // printf("for\n" );
    return FOR;
    printf("(%s, FOR)\n", yytext);
}
"return"  {
    // printf("mod\n
    printf("(%s, RETURN)\n", yytext);
    return RETURN;
}
"break"  {
    // printf("mod
    printf("(%s, BREAK)\n", yytext);

    return BREAK;
}

"true" {
    printf("(true, BOOLCONSTANT)\n");
    yylval.type_int = 1;
    return BOOLCONSTANT;
}

"false" {
    printf("(false, BOOLCONSTANT)\n");
    yylval.type_int = 0;
    return BOOLCONSTANT;
}

\"[^\"]*\" {
    if(yytext[yyleng - 2] == '\\'){
        yyless(yyleng - 1);
        yymore();
    }
    else{
        printf("(%s, STRINGCONSTANT)\n", yytext);
        yylval.type_str = strdup(yytext);
        return STRINGCONSTANT;
    }
}

0x{hexdigit}+ {
    char *temp;
    // printf("find hexdigit %lx\n", strtol(yytext+2,&temp, 16));
    yylval.type_int = strtol(yytext+2,&temp, 16);
    printf("(%s, INTCONSTANT)\n", yytext);
    return INTCONSTANT;
}
{digit}+{letter}+{char}* {
    // printf("syntax error illegal id : %s\n", yytext);
    yyerror("syntax error, illegal id");
    return ID;
}

{letter}{char}* {
    // printf("find ID %s\n", yytext);
    yylval.type_str = strdup(yytext);
    printf("(%s, ID)\n", yytext);
    return ID;
}
{digit}+ {
    // printf("find decimal %d\n", atoi(yytext));
    yylval.type_int = atoi(yytext);
    printf("(%s, INTCONSTANT)\n", yytext);
    return INTCONSTANT;
}



\n.* {
    strncpy(linebuf, yytext + 1, sizeof(linebuf));
    yycolumn = 1;
    yyless(1);
}

[ \t] {}  /* 忽略空白字符，否则会识别为.（ERROR）*/
. {
    yyerror("syntax error, illegal token");
    error_flag = 1;
    // printf("Error at line %d : %s\n", yylineno, yytext);
}

%%
