%{
    #include <stdio.h>
    #include "lex.yy.c"
    #include <stdarg.h>
    #include <string.h>

#define PPOINTER(x) printf("%s\n", x)

    typedef struct node_ {
        // char nodetype[10];
        char left_name[20];
        int ivalue;
        char *str;
        struct node_ *firstson;
        struct node_ *nextbro;
    }NODE;

NODE * new_node(const char *left_name, int ivalue, char *str, int right_num, ...);
void PrintNodeInfo(NODE *p, int depth);
void PreOrderTraverse(NODE *p, int depth);


NODE *new_int(int num);
NODE *new_str(char *str);
NODE *new_bool(int bool_var);
NODE *new_null();
NODE *new_ter(char *name);
NODE *new_id(char *str);
NODE *new_LP();
NODE *new_RP();
NODE *new_LB();
NODE *new_RB();
NODE *new_LC();
NODE *new_RC();
NODE *new_SEMI();
NODE *new_COMMA();
%}

%union{
    int type_int;
    char * type_str;
    struct node_ * type_node;
}
// declare tokes
%token <type_int> INT BOOL
%token <type_str> STRING
%token VOID NUL
%token STATIC
%token PRINT READINTEGER READLINE INSTANCEOF
%token SEMI COMMA PERIOD
%token LP RP LB RB LC RC // () [] {}
%token ASSIGNOP  // =
%token EXTENDS CLASS THIS NEW
%token <type_int> INTCONSTANT
%token <type_str> STRINGCONSTANT
%token <type_int> BOOLCONSTANT
%token <type_str> ID

//flow control
%token IF ELSE WHILE FOR RETURN BREAK

%token PLUS MINUS TIMES DIVIDE MOD LESS LESSEQ MORE MOREEQ EQ NOTEQ AND OR NOT

// association and priority
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%right ASSIGNOP
%left OR
%left AND
%left EQ NOTEQ
%left LESS LESSEQ MORE MOREEQ INSTANCEOF
%left PLUS MINUS
%left TIMES DIVIDE MOD
%nonassoc UNARYMINUS UNARYNOT
%left LP RP LB RB PERIOD

%type <type_node> Program
%type <type_node> ClassDefs
%type <type_node> ClassDef
%type <type_node> Fields
%type <type_node> ExtendDef
%type <type_node> Field
%type <type_node> FuncDef

%type <type_node> Formals
%type <type_node> FormalTail
%type <type_node> StmtBlock
%type <type_node> StmtList
%type <type_node> Stmt
%type <type_node> SimpleStmt
%type <type_node> LValue
%type <type_node> Call
%type <type_node> Actuals
%type <type_node> IfStmt
%type <type_node> WhileStmt
%type <type_node> BoolExpr
%type <type_node> ForStmt
%type <type_node> BreakStmt
%type <type_node> ReturnStmt
%type <type_node> PrintStmt
%type <type_node> ExprList
%type <type_node> ExprTail
%type <type_node> Var
%type <type_node> VarDef
%type <type_node> Type
%type <type_node> Constant
%type <type_node> Expr

%%
Program :
    ClassDefs {
        $$ = new_node("Program", 0, NULL, 1, $1);
        printf("\n\n\nFinish tree\n\n");
        PreOrderTraverse($$, 0);
    }
    ;

ClassDefs :
    ClassDef  {
        $$ = new_node("ClassDefs", 0, NULL, 1, $1);
        // printf("1 of classdefs\n"  );
    }
    |  ClassDef ClassDefs  {
        $$ = new_node("ClassDefs", 0, NULL, 2, $1, $2);
        // printf("2 of classdefs\n"  );
    }
    ;

ClassDef :
    CLASS ID ExtendDef LC Fields RC {
        $$ = new_node("ClassDef", 0, NULL, 6, new_ter("CLASS"), new_ter("ID"), $3, new_LC(), $5, new_RC() );
        // $$ = new_node("ClassDef", 0, NULL, 6, new_ter("CLASS"), new_id($2), $3, new_LC(), $5, new_RC() );
    }
    ;

Fields :
    {
        $$ = new_node("Fields", 0, NULL, 0);
    }
    | Field Fields {
        $$ = new_node("Fields", 0, NULL, 2, $1, $2);
    }
    ;

ExtendDef :
    {
        $$ = new_node("ExtendDef", 0, NULL, 0);
    }
    | EXTENDS ID
    {
        // printf("%p\n",  $2);
        $$ = new_node("ExtendDef", 0, NULL, 2, new_ter("EXTENDS"), new_id($2) );
    }
    ;

Field :
    VarDef {
        $$ = new_node("VarDef", 0, NULL, 1, $1);
    }
    | FuncDef {
        $$ = new_node("FuncDef", 0, NULL, 1, $1);
    }
    ;

FuncDef :
    STATIC Type ID LP Formals RP StmtBlock {
        $$ = new_node("FuncDef", 0, NULL, 7, new_ter("STATIC"), $2, new_id($3), new_LP(), $5, new_RP(), $7);

    }
    | Type ID LP Formals RP StmtBlock
    ;

//变量列表
Formals :
{
        $$ = new_node("Formals", 0, NULL, 0);
    }
    | Var FormalTail  {
        $$ = new_node("Formals", 0, NULL, 2, $1, $2);
    }
    ;

FormalTail :
{
        $$ = new_node("FormalTail", 0, NULL, 0);
    }
    | COMMA Var FormalTail  {
        $$ = new_node("FormalTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

StmtBlock :
    LC StmtList RC {
        $$ = new_node("StmtBlock", 0, NULL, 3, new_LC(), $2, new_RC());

    }
    ;

StmtList : {
        $$ = new_node("StmtList", 0, NULL, 0);
    }
    | Stmt StmtList{
        $$ = new_node("StmtList", 0, NULL, 2, $1, $2);
    }
    ;

Stmt :
    VarDef {
        $$ = new_node("Stmt", 0, NULL, 1, $1);

    }
    | SimpleStmt SEMI {
        $$ = new_node("Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | IfStmt {
        $$ = new_node("Stmt", 0, NULL, 1, $1);
    }
    | WhileStmt {
        $$ = new_node("Stmt", 0, NULL, 1, $1);
    }
    | ForStmt{
        $$ = new_node("Stmt", 0, NULL, 1, $1);
    }
    | BreakStmt SEMI {
        $$ = new_node("Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | ReturnStmt SEMI {
        $$ = new_node("Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | PrintStmt SEMI {
        $$ = new_node("Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | StmtBlock {
        $$ = new_node("Stmt", 0, NULL, 1, $1);
    }

SimpleStmt :
    LValue ASSIGNOP Expr {
        $$ = new_node("SimpleStmt", 0, NULL, 3, $1, new_ter("ASSIGNOP"), $3);

    }
    | Call {
        $$ = new_node("SimpleStmt", 0, NULL, 1, $1);
    }
    | {
        $$ = new_node("SimpleStmt", 0, NULL, 0);
    }
    ;

LValue :
    Expr PERIOD ID {
        $$ = new_node("LValue", 0, NULL, 3, $1, new_ter("PEROID"), new_id($3));
    }
    | ID {
        $$ = new_node("LValue", 0, NULL, 1, new_id($1));
    }
    | Expr LB Expr RB {
        $$ = new_node("LValue", 0, NULL, 4, $1,new_LB(), $3, new_RB());
    }
    ;


Call :
    Expr PERIOD ID LP Actuals RP{
        $$ = new_node("Call", 0, NULL, 6, $1, new_ter("PERIOD"), new_id($3), new_LP(), $5, new_RP());
    }
    | ID LP Actuals RP
    {
        $$ = new_node("Call", 0, NULL, 4, new_id($1), new_LP(), $3, new_RP());
    }
    ;

//调用时的传参
Actuals :
    {
        $$ = new_node("Actuals", 0, NULL, 0);
    }
    | ExprList{
        $$ = new_node("Actuals", 0, NULL, 1, $1);
    }
    ;

IfStmt :
    IF LP BoolExpr RP Stmt ELSE Stmt {
        $$ = new_node("IfStmt", 0, NULL, 7, new_ter("IF"), new_LP(), $3, new_RP(), $5, new_ter("ELSE"), $7);
    }
    | IF LP BoolExpr RP Stmt %prec LOWER_THAN_ELSE{
        $$ = new_node("IfStmt", 0, NULL, 5, new_ter("IF"), new_LP(), $3, new_RP(), $5);
    }
    ;

WhileStmt :
    WHILE LP BoolExpr RP Stmt{
        $$ = new_node("WhileStmt", 0, NULL, 5, new_ter("WHILE"), new_LP(), $3, new_RP(), $5);
    }
    ;

BoolExpr :
    Expr {
        $$ = new_node( "BoolExpr", 0, NULL, 1, $1);
    }
    ;

ForStmt :
    FOR LP SimpleStmt SEMI BoolExpr SEMI SimpleStmt RP Stmt {
        $$ = new_node("ForStmt", 0, NULL, 9, new_ter("FOR"), new_LP(), $3, new_SEMI(), $5, new_SEMI(), $7, new_RP(), $9);
    }
    ;

BreakStmt :
    BREAK {
        $$ = new_node("BreakStmt", 0, NULL, 1, new_ter("BREAK"));
    }
    ;

ReturnStmt :
    RETURN {
        $$ = new_node("ReturnStmt", 0, NULL, 1, new_ter("RETURN"));
    }
    | RETURN Expr{
        $$ = new_node("ReturnStmt", 0, NULL, 2, new_ter("RETURN"), $2);
    }
    ;

PrintStmt :
    PRINT LP ExprList RP{
        $$ = new_node("PrintStmt", 0, NULL, 4, new_ter("PRINT"), new_LP(), $3, new_RP());
    }
    ;

ExprList :
    Expr ExprTail {
        $$ = new_node("ExprList", 0, NULL, 2, $1, $2);
    }
    ;

ExprTail :
    // {$$ = NULL;}
    {
        $$ = new_node("ExprTail", 0, NULL, 0);
    }
    | COMMA Expr ExprTail {
        $$ = new_node("ExprTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

VarDef :
    Var SEMI {
        $$ = new_node("VarDef", 0, NULL, 2, $1, new_SEMI());
    }
    ;

Var :
    Type ID {
        $$ = new_node("Var", 0, NULL, 2, $1, new_id($2));
    }
    ;

Type :
    INT {
        $$ = new_node("Type",0, NULL, 1, new_ter("INT"));
    }
    | BOOL{
        $$ = new_node("Type",0, NULL, 1, new_ter("BOOL"));
    }
    | STRING{
        $$ = new_node("Type",0, NULL, 1, new_ter("STRING"));
    }
    | VOID{
        $$ = new_node("Type",0, NULL, 1, new_ter("VOID"));
    }
    | CLASS ID{
        $$ = new_node("Type",0, NULL, 2, new_ter("CLASS"), new_id($2));
    }
    | Type LB RB{
        $$ = new_node("Type",0, NULL, 3, $1, new_LB(), new_RB());
    }
    ;

Constant :
    INTCONSTANT {
        $$ = new_node("Constant",0, NULL, 1, new_int($1));
    }
    | BOOLCONSTANT {
        $$ = new_node("Constant",0, NULL, 1, new_bool($1));
}
    | STRINGCONSTANT {
        $$ = new_node("Constant",0, NULL, 1, new_str($1));
}
    | NUL {
        $$ = new_node("Constant",0, NULL, 1, new_null());
}
    ;

Expr :
    Constant { $$ = new_node("Expr", 0, NULL, 1, $1);}
    | LValue { $$ = new_node("Expr", 0, NULL, 1, $1);}
    | THIS   {
        $$ = new_node( "Expr", 0, NULL, 1, new_ter("this"));
    }
    | Call {
        $$ = new_node("Expr", 0, NULL, 1, $1);
    }
    | LP Expr RP {$$ = new_node("Expr", 0,NULL, 3, new_ter("LP"), $2, new_ter("RP"));}
    | Expr PLUS Expr {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr MINUS Expr   {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr TIMES Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("TIMES"), $3);}
    | Expr DIVIDE Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("DIVIDE"), $3);}
    | Expr MOD Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("MOD"), $3);}
    | Expr LESS Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("LESS"), $3);}
    | Expr LESSEQ Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("LESSEQ"), $3);}
    | Expr MORE Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("MORE"), $3);}
    | Expr MOREEQ Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("MOREEQ"), $3);}
    | Expr EQ Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("EQ"), $3);}
    | Expr NOTEQ Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("NOTEQ"), $3);}
    | Expr OR Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("OR"), $3);}
    | Expr AND Expr  {$$ = new_node("Expr", 0,NULL, 3, $1, new_ter("AND"), $3);}
    | MINUS Expr %prec UNARYMINUS {$$ = new_node("Expr", 0, NULL, 2, new_ter("UNARYMINUS"), $2);}
    | NOT Expr %prec UNARYNOT {$$ = new_node("Expr", 0, NULL, 2, new_ter("UNARYNOT"), $2);}
    | READINTEGER LP RP {$$ = new_node("Expr", 0, NULL, 3, new_ter("READINTEGER"), new_ter("LP"), new_ter("RP"));}
    | READLINE LP RP {$$ = new_node("Expr", 0, NULL, 3, new_ter("READLINE"), new_ter("LP"), new_ter("RP"));}
    | NEW ID LP RP {$$ = new_node("Expr", 0, NULL, 4, new_ter("NEW"), new_id($2), new_ter("LP"), new_ter("RP"));}
    | NEW Type LB Expr RB {$$ = new_node("Expr", 0, NULL, 5, new_ter("NEW"), $2, new_ter("LB"), $4, new_ter("RB")) ;}
    | INSTANCEOF LP Expr COMMA ID RP {
        $$ = new_node("Expr", 0, NULL, 6, new_ter("INSTANCEOF"), new_LP(), $3, new_ter("COMMA"), new_id($5), new_RP());
    }
    | LP CLASS ID RP Expr {
        $$ = new_node("Expr", 0, NULL, 5, new_LP(), new_ter("CLASS"), new_id($3), new_RP(), $5);
    }
    ;

%%

void PreOrderTraverse(NODE *p, int depth){
    PrintNodeInfo(p, depth);
    // 有孩子，则从p->firstson 到 p->firstson->nextbro->nextbro ...->nextbro
    NODE *pson;
    for(pson = p->firstson; pson != NULL; pson = pson->nextbro){
        PreOrderTraverse(pson, depth + 1);
    }
    return;
}

void PrintNodeInfo(NODE *p, int depth){
    printf("%d ", depth);
    for (int i = 0; i < depth; i++) {
        printf("  " );
    }

    printf("%s\n", p->left_name);

}

// NODE * new_node(char *nodetype, char left_name[20], int ivalue, char *str, int right_num, ...){
NODE * new_node(const char *left_name, int ivalue, char *str, int right_num, ...){
    va_list arg;
    va_start(arg, right_num);
    NODE *p = malloc(sizeof(NODE));
    // 分配失败
    if(!p)
        exit(-1);


    strcpy(p->left_name, left_name);
    p->ivalue = ivalue;
    p->str = str;


    NODE *pson;
    if(right_num == 0){
        p->firstson = NULL;
        return p;
    }
    else{
        p->firstson = va_arg(arg, NODE *);
        pson = p->firstson;
        // printf("%s\n", pson->left_name);
        for (int i = 0; i < right_num-1; i++) {
            NODE* next_bro = va_arg(arg, NODE *);
            pson->nextbro = next_bro;
            pson = pson->nextbro;
        }
        // printf("%s %p\n", left_name, pson);
        pson->nextbro = NULL; //最后一个节点的nextbro置为NULL;
        return p;
    }
}

NODE *new_int(int num){
    return new_node( "intconstant", num, NULL, 0);
}

NODE *new_str(char *str){
    return new_node( "strconstant", 0, str, 0);
}
NODE *new_bool(int bool_var){
    return new_node("boolconstant", bool_var, NULL, 0);
}
NODE *new_null(){
    return new_node("NULL", 0, NULL, 0);
}
NODE *new_ter(char *name){
    return new_node(name, 0, NULL, 0 );
}
NODE *new_id(char *str){
    // printf("%s\n", str);
    return new_node("ID", 0, str, 0);
}
NODE *new_LP(){
    return new_node("LP", 0, NULL, 0);
}
NODE *new_RP(){
    return new_node("RP", 0, NULL, 0);
}
NODE *new_LB(){
    return new_node("LB", 0, NULL, 0);
}
NODE *new_RB(){
    return new_node("RB", 0, NULL, 0);
}
NODE *new_LC(){
    return new_node("LC", 0, NULL, 0);
}
NODE *new_RC(){
    return new_node("RC", 0, NULL, 0);
}
NODE *new_SEMI(){
    return new_node("SEMI", 0, NULL, 0);
}
NODE *new_COMMA(){
    return new_node("COMMA", 0, NULL, 0);
}
