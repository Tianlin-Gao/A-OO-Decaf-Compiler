%locations
%error-verbose


%{
    #include "lex.yy.c"
    // #include "inc.h"
    // #include "defs.h"
    #include "./include/defs.h"
    #include "./include/inclu.h"
    #include "./include/bison_decaf.h"


// #define YYDEBUG 1
    // typedef struct node_ {
    //     // char nodetype[10];
    //     int noderule;
    //     char *left_name;
    //     int ivalue;
    //     char *str;
    //     struct node_ ** psons;
    //     int right_num;
    //     // struct node_ *firstson;
    //     // struct node_ *nextbro;
    // }NODE;

void InitPhase2(NODE *root);
NODE * new_node(enum _noderule noderule, const char *left_name, int ivalue, char *str, int right_num, ...);
void PrintNodeInfo(NODE *p, int depth);
void PreOrderTraverse(NODE *p, int depth);
void yyerror(const char *s, ...);

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
%type <type_node> Argument
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
        $$ = new_node(N_program, "Program", 0, NULL, 1, $1);

        if(!error_flag){
        printf("\n========= Finish tree =========\n");
            InitPhase2($$);
        }
    }
    ;

ClassDefs :
    ClassDef  {
        $$ = new_node(N_classdefs1, "ClassDefs", 0, NULL, 1, $1);
        // printf("1 of classdefs\n"  );
    }
    |  ClassDef ClassDefs  {
        $$ = new_node(N_classdefs2, "ClassDefs", 0, NULL, 2, $1, $2);
        // printf("2 of classdefs\n"  );
    }
    ;

ClassDef :
    CLASS ID ExtendDef LC Fields RC {
        $$ = new_node(N_classdef, "ClassDef", 0, NULL, 6, new_ter("CLASS"), new_id($2), $3, new_LC(), $5, new_RC() );
        // printf("class @ %d %d\n", @1.first_line, @6.first_line);
        // $$ = new_node("ClassDef", 0, NULL, 6, new_ter("CLASS"), new_id($2), $3, new_LC(), $5, new_RC() );
    }
    | error RC {
        $$ = new_node(N_classdeferr, "ClassDef", 0, NULL, 0);
        error_flag = 1;
        // printf("hhh\n");
    }
    // | error RC
    ;

Fields :
    {
        $$ = new_node(N_fieldsempty, "Fields", 0, NULL, 0);
    }
    | Field Fields {
        $$ = new_node(N_fields, "Fields", 0, NULL, 2, $1, $2);
    }
    ;

ExtendDef :
    {
        $$ = new_node(N_extendempty, "ExtendDef", 0, NULL, 0);
    }
    | EXTENDS ID
    {
        // printf("%p\n",  $2);
        $$ = new_node(N_extend, "ExtendDef", 0, NULL, 2, new_ter("EXTENDS"), new_id($2) );
    }
    ;

Field :
    VarDef {
        $$ = new_node(N_fieldvar, "Field", 0, NULL, 1, $1);
    }
    | FuncDef {
        $$ = new_node(N_fieldfunc, "Field", 0, NULL, 1, $1);
    }
    ;

FuncDef :
    STATIC Type ID LP Formals RP StmtBlock {
        $$ = new_node(N_funcdefsta ,"FuncDef", 0, NULL, 7, new_ter("STATIC"), $2, new_id($3), new_LP(), $5, new_RP(), $7);
    }
    | Type ID LP Formals RP StmtBlock
    {
        $$ = new_node(N_funcdef ,"FuncDef", 0, NULL, 6, $1, new_id($2), new_LP(), $4, new_RP(), $6);
    }
    ;

//变量列表
Formals :
    {
        $$ = new_node(N_formalsempty, "Formals", 0, NULL, 0);
    }
    | Var FormalTail  {
        $$ = new_node(N_formals, "Formals", 0, NULL, 2, $1, $2);
    }
    ;

FormalTail :
{
        $$ = new_node(N_formaltailempty, "FormalTail", 0, NULL, 0);
    }
    | COMMA Var FormalTail  {
        $$ = new_node(N_formaltail, "FormalTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

StmtBlock :
    LC StmtList RC {
        $$ = new_node(N_stmtblock,  "StmtBlock", 0, NULL, 3, new_LC(), $2, new_RC());

    }
    | error RC {
        $$ = new_node(N_stmtblockerror, "StmtBlock", 0, NULL, 0);
        // printf("hhh\n");
        error_flag = 1;
    }
    ;

StmtList : {
        $$ = new_node(N_stmtlistempty, "StmtList", 0, NULL, 0);
    }
    | Stmt StmtList{
        $$ = new_node(N_stmtlist, "StmtList", 0, NULL, 2, $1, $2);
    }
    ;

Stmt :
    VarDef {
        $$ = new_node(N_stmtVar, "Stmt", 0, NULL, 1, $1);

    }
    | SimpleStmt SEMI {
        $$ = new_node(N_stmtsimple ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | IfStmt {
        $$ = new_node(N_stmtif ,"Stmt", 0, NULL, 1, $1);
    }
    | WhileStmt {
        $$ = new_node(N_stmtwhile ,"Stmt", 0, NULL, 1, $1);
    }
    | ForStmt{
        $$ = new_node(N_stmtfor ,"Stmt", 0, NULL, 1, $1);
    }
    | BreakStmt SEMI {
        $$ = new_node(N_stmtbreak ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | ReturnStmt SEMI {
        $$ = new_node(N_stmtreturn ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | PrintStmt SEMI {
        $$ = new_node(N_stmtprint ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | StmtBlock {
        $$ = new_node(N_stmtstmtblock ,"Stmt", 0, NULL, 1, $1);
    }

SimpleStmt :
    LValue ASSIGNOP Expr {
        $$ = new_node(N_simpleassign , "SimpleStmt", 0, NULL, 3, $1, new_ter("ASSIGNOP"), $3);

    }
    | Call {
        $$ = new_node(N_simplecall , "SimpleStmt", 0, NULL, 1, $1);
    }
    | {
        $$ = new_node(N_simpleempty , "SimpleStmt", 0, NULL, 0);
    }
    ;

LValue :
    Expr PERIOD ID {
        $$ = new_node(N_lvaluemember , "LValue", 0, NULL, 3, $1, new_ter("PEROID"), new_id($3));
    }
    | ID {
        $$ = new_node(N_lvalueid , "LValue", 0, NULL, 1, new_id($1));
    }
    | Expr LB Expr RB {
        $$ = new_node(N_lvaluearray , "LValue", 0, NULL, 4, $1,new_LB(), $3, new_RB());
    }
    ;


Call :
    Expr PERIOD ID LP Actuals RP{
        $$ = new_node(N_callmember ,"Call", 0, NULL, 6, $1, new_ter("PERIOD"), new_id($3), new_LP(), $5, new_RP());
    }
    | ID LP Actuals RP
    {
        $$ = new_node(N_call , "Call", 0, NULL, 4, new_id($1), new_LP(), $3, new_RP());
    }
    ;

//调用时的传参
Actuals :
    {
        $$ = new_node(N_actualsempty , "Actuals", 0, NULL, 0);
    }
    | ExprList{
        $$ = new_node(N_actualexpr, "Actuals", 0, NULL, 1, $1);
    }
    ;

IfStmt :
    IF LP BoolExpr RP Stmt ELSE Stmt {
        $$ = new_node(N_ifstmtelse,"IfStmt", 0, NULL, 7, new_ter("IF"), new_LP(), $3, new_RP(), $5, new_ter("ELSE"), $7);
    }
    | IF LP BoolExpr RP Stmt %prec LOWER_THAN_ELSE{
        $$ = new_node(N_ifstmt , "IfStmt", 0, NULL, 5, new_ter("IF"), new_LP(), $3, new_RP(), $5);
    }
    ;

WhileStmt :
    WHILE LP BoolExpr RP Stmt{
        $$ = new_node(N_whilestmt , "WhileStmt", 0, NULL, 5, new_ter("WHILE"), new_LP(), $3, new_RP(), $5);
    }
    ;

BoolExpr :
    Expr {
        $$ = new_node(N_boolexpr , "BoolExpr", 0, NULL, 1, $1);
    }
    ;

ForStmt :
    FOR LP SimpleStmt SEMI BoolExpr SEMI SimpleStmt RP Stmt {
        $$ = new_node(N_forstmt , "ForStmt", 0, NULL, 9, new_ter("FOR"), new_LP(), $3, new_SEMI(), $5, new_SEMI(), $7, new_RP(), $9);
    }
    ;

BreakStmt :
    BREAK {
        $$ = new_node(N_breakstmt, "BreakStmt", 0, NULL, 1, new_ter("BREAK"));
    }
    ;

ReturnStmt :
    RETURN {
        $$ = new_node(N_returnstmt, "ReturnStmt", 0, NULL, 1, new_ter("RETURN"));
    }
    | RETURN Expr{
        $$ = new_node(N_returnstmtexpr, "ReturnStmt", 0, NULL, 2, new_ter("RETURN"), $2);
    }
    ;

PrintStmt :
    PRINT LP ExprList RP{
        $$ = new_node(N_printstmt, "PrintStmt", 0, NULL, 4, new_ter("PRINT"), new_LP(), $3, new_RP());
    }
    ;

ExprList :
    Argument ExprTail {
        $$ = new_node(N_exprlist, "ExprList", 0, NULL, 2, $1, $2);
    }
    ;

ExprTail :
    // {$$ = NULL;}
    {
        $$ = new_node(N_exprtailempty, "ExprTail", 0, NULL, 0);
    }
    | COMMA Argument ExprTail {
        $$ = new_node(N_exprtail, "ExprTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

Argument :
    Expr {
        $$ = new_node(N_argument, "Argument", 0, NULL, 1, $1);
    }
    ;

VarDef :
    Var SEMI {
        $$ = new_node(N_vardef, "VarDef", 0, NULL, 2, $1, new_SEMI());
    }
    ;

Var :
    Type ID {
        $$ = new_node(N_var, "Var", 0, NULL, 2, $1, new_id($2));
    }
    ;

Type :
    INT {
        $$ = new_node(N_typeint, "Type",0, NULL, 1, new_ter("INT"));
    }
    | BOOL{
        $$ = new_node(N_typebool, "Type",0, NULL, 1, new_ter("BOOL"));
    }
    | STRING{
        $$ = new_node(N_typestring, "Type",0, NULL, 1, new_ter("STRING"));
    }
    | VOID{
        $$ = new_node(N_typevoid, "Type",0, NULL, 1, new_ter("VOID"));
    }
    | CLASS ID{
        $$ = new_node(N_typeclass, "Type",0, NULL, 2, new_ter("CLASS"), new_id($2));
    }
    | Type LB RB{
        $$ = new_node(N_typearray, "Type",0, NULL, 3, $1, new_LB(), new_RB());
    }
    ;

Constant :
    INTCONSTANT {
        $$ = new_node(N_conint, "Constant",0, NULL, 1, new_int($1));
    }
    | BOOLCONSTANT {
        $$ = new_node(N_conbool, "Constant",0, NULL, 1, new_bool($1));
}
    | STRINGCONSTANT {
        $$ = new_node(N_constring, "Constant",0, NULL, 1, new_str($1));
}
    | NUL {
        $$ = new_node(N_connull, "Constant",0, NULL, 1, new_null());
}
    ;

Expr :
    Constant { $$ = new_node(N_exprcon ,"Expr", 0, NULL, 1, $1);}
    | LValue { $$ = new_node(N_exprlvalue,"Expr", 0, NULL, 1, $1);}
    | THIS   {
        $$ = new_node( N_exprthis,"Expr", 0, NULL, 1, new_ter("this"));
    }
    | Call {
        $$ = new_node(N_exprcall,"Expr", 0, NULL, 1, $1);
    }
    | LP Expr RP {$$ = new_node(N_exprp,"Expr", 0,NULL, 3, new_ter("LP"), $2, new_ter("RP"));}
    | Expr PLUS Expr {$$ = new_node(N_exprplus,"Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr MINUS Expr   {$$ = new_node(N_exprminus,"Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr TIMES Expr  {$$ = new_node(N_exprtimes,"Expr", 0,NULL, 3, $1, new_ter("TIMES"), $3);}
    | Expr DIVIDE Expr  {$$ = new_node(N_exprdivide,"Expr", 0,NULL, 3, $1, new_ter("DIVIDE"), $3);}
    | Expr MOD Expr  {$$ = new_node(N_exprmod,"Expr", 0,NULL, 3, $1, new_ter("MOD"), $3);}
    | Expr LESS Expr  {$$ = new_node(N_exprless,"Expr", 0,NULL, 3, $1, new_ter("LESS"), $3);}
    | Expr LESSEQ Expr  {$$ = new_node(N_exprlesseq,"Expr", 0,NULL, 3, $1, new_ter("LESSEQ"), $3);}
    | Expr MORE Expr  {$$ = new_node(N_exprmore,"Expr", 0,NULL, 3, $1, new_ter("MORE"), $3);}
    | Expr MOREEQ Expr  {$$ = new_node(N_exprmoreeq,"Expr", 0,NULL, 3, $1, new_ter("MOREEQ"), $3);}
    | Expr EQ Expr  {$$ = new_node(N_expreq,"Expr", 0,NULL, 3, $1, new_ter("EQ"), $3);}
    | Expr NOTEQ Expr  {$$ = new_node(N_exprnoteq,"Expr", 0,NULL, 3, $1, new_ter("NOTEQ"), $3);}
    | Expr OR Expr  {$$ = new_node(N_expror,"Expr", 0,NULL, 3, $1, new_ter("OR"), $3);}
    | Expr AND Expr  {$$ = new_node(N_exprand ,"Expr", 0,NULL, 3, $1, new_ter("AND"), $3);}
    | MINUS Expr %prec UNARYMINUS {$$ = new_node(N_exprneg, "Expr", 0, NULL, 2, new_ter("UNARYMINUS"), $2);}
    | NOT Expr %prec UNARYNOT { $$ = new_node(N_exprnot, "Expr", 0, NULL, 2, new_ter("UNARYNOT"), $2);}
    | READINTEGER LP RP {$$ = new_node(N_exprrdint, "Expr", 0, NULL, 3, new_ter("READINTEGER"), new_ter("LP"), new_ter("RP"));}
    | READLINE LP RP {$$ = new_node(N_exprrdline, "Expr", 0, NULL, 3, new_ter("READLINE"), new_ter("LP"), new_ter("RP"));}
    | NEW ID LP RP {$$ = new_node(N_exprnewobj, "Expr", 0, NULL, 4, new_ter("NEW"), new_id($2), new_ter("LP"), new_ter("RP"));}
    | NEW Type LB Expr RB {$$ = new_node(N_exprnewarray, "Expr", 0, NULL, 5, new_ter("NEW"), $2, new_ter("LB"), $4, new_ter("RB")) ;}
    | INSTANCEOF LP Expr COMMA ID RP {
        $$ = new_node(N_exprinstance, "Expr", 0, NULL, 6, new_ter("INSTANCEOF"), new_LP(), $3, new_ter("COMMA"), new_id($5), new_RP());
    }
    | LP CLASS ID RP Expr {
        $$ = new_node(N_exprtrans, "Expr", 0, NULL, 5, new_LP(), new_ter("CLASS"), new_id($3), new_RP(), $5);
    }
    ;

%%
void InitPhase2(NODE *root){
    // PreOrderTraverse(root, 0) ;



    pClass = NewSymbolItem(D_HEAD, NULL);
    pScur = initSTACK(STACK_SIZE);
    pScurTable = initSTACK(STACK_SIZE);
    pScurBlock = initSTACK(STACK_SIZE);
    // assert(pScur != NULL);

    ScanTree(1, root);
    ResolveBaseClass(pClass);
    ScanTree(2, root);
    ScanTree(3, root);
    if(!error_flag){
        PrintSymbolTable(pClass, 0);
    }

}

void yyerror(const char *s, ...)
{
    error_flag = 1;
  va_list ap;
  va_start(ap, s);

  if(yylloc.first_line){
       fprintf(stderr, "Line %-3d:%s\n         ", yylloc.first_line, linebuf);

       for (int i = 1; i <= yylloc.last_column; i++) {
           if(i >= yylloc.first_column){
               fprintf(stderr, FONT_COLOR_RED"^"COLOR_NONE);
           }
           else{
               fprintf(stderr, " ");
           }
       }
       fprintf(stderr, "\n" );
  }
    // fprintf(stderr, "%s\n %d.%d-%d.%d: error: ", linebuf, yylloc.first_line, yylloc.first_column,
	//     yylloc.last_line, yylloc.last_column);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}


void PreOrderTraverse(NODE *p, int depth){
    PrintNodeInfo(p, depth);
    // 有孩子，则从p->firstson 到 p->firstson->nextbro->nextbro ...->nextbro
    // NODE *pson;
    for(int i = 0; i < p->right_num; i++){
        assert(p->psons[i] != NULL);
        PreOrderTraverse(p->psons[i], depth + 1);
    }
    return;
}

void PrintNodeInfo(NODE *p, int depth){
    // printf("%-3d :", yylloc.first_line);
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }

    printf("%s", p->left_name);
    if((strcmp(p->left_name, "ID") == 0 )|| (strcmp(p->left_name, "STRCONSTANT") == 0)){
        assert(p->str != NULL);
        printf(" : %s", p->str);
    }

    printf("\n" );

}

// NODE * new_node(char *nodetype, char left_name[20], int ivalue, char *str, int right_num, ...){
NODE * new_node(enum _noderule noderule, const char *left_name, int ivalue, char *str, int right_num, ...){
    va_list arg;
    va_start(arg, right_num);
    NODE *p = malloc(sizeof(NODE));

    // 分配失败
    if(!p)
        exit(-1);


    assert(left_name!=NULL);

    p->left_name = strdup(left_name);
    // printf("%s\n", p->left_name);
    p->ivalue = ivalue;
    p->str = str;
    p->noderule = noderule;
    p->line_1 = yylloc.first_line;
    p->col_1 = yylloc.first_column;
    p->col_2 = yylloc.last_column;

    // if(strcmp(left_name, "BOOLCONSTANT") == 0){
    //     p->ptype = NewNodeType1(V_BOOL);
    // }
    // else if(strcmp(left_name, "INTCONSTANT") == 0){
    //     p->ptype = NewNodeType1(V_INT);
    // }
    // else if(strcmp(left_name, "STRINGCONSTANT") == 0){
    //     p->ptype = NewNodeType1(V_STRING);
    // }
    // else{
    //     p->ptype = NULL;
    // }

    p->ptype = NULL;

    // NODE *psons;
    p->right_num = right_num;
    if(right_num == 0){
        p->psons = NULL;
        return p;
    }
    else{
        NODE **psons = malloc(right_num * sizeof(NODE *));
        if(!psons)
            exit(-1);
        for(int i = 0; i < right_num; i++){
            psons[i] = va_arg(arg, NODE*);
        }
        p->psons = psons;
        return p;
    }
}

NODE *new_int(int num){
    return new_node( 0, "INTCONSTANT", num, NULL, 0);
}

NODE *new_str(char *str){
    return new_node( 0, "STRCONSTANT", 0, str, 0);
}
NODE *new_bool(int bool_var){
    return new_node(0, "BOOLCONSTANT", bool_var, NULL, 0);
}
NODE *new_null(){
    return new_node(0, "NULL", 0, NULL, 0);
}
NODE *new_ter(char *name){
    return new_node(0, name, 0, NULL, 0 );
}
NODE *new_id(char *str){
    // printf("%s\n", str);
    return new_node(0, "ID", 0, str, 0);
}
NODE *new_LP(){
    return new_node(0, "LP", 0, NULL, 0);
}
NODE *new_RP(){
    return new_node(0, "RP", 0, NULL, 0);
}
NODE *new_LB(){
    return new_node(0, "LB", 0, NULL, 0);
}
NODE *new_RB(){
    return new_node(0, "RB", 0, NULL, 0);
}
NODE *new_LC(){
    return new_node(0, "LC", 0, NULL, 0);
}
NODE *new_RC(){
    return new_node(0, "RC", 0, NULL, 0);
}
NODE *new_SEMI(){
    return new_node(0, "SEMI", 0, NULL, 0);
}
NODE *new_COMMA(){
    return new_node(0, "COMMA", 0, NULL, 0);
}
