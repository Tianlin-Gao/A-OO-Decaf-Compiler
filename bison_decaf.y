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
NODE * new_node(int noderule, const char *left_name, int ivalue, char *str, int right_num, ...);
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
int error_flag;
/* When debugging our pure parser, we want to see values and locations
   of the tokens.  */
/* FIXME: Locations. */
// #define YYPRINT(File, Type, Value)
//         yyprint (File, /* FIXME: &yylloc, */ Type, &Value)
// static void yyprint (FILE *file, /* FIXME: const yyltype *loc, */
//                      int type, const YYSTYPE *value);

// void yyerror (const YYLTYPE *location, const char *message);


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
        $$ = new_node(1, "Program", 0, NULL, 1, $1);
        if(!error_flag){
        printf("\n========= Finish tree =========\n");
            InitPhase2($$);
        }
    }
    ;

ClassDefs :
    ClassDef  {
        $$ = new_node(2, "ClassDefs", 0, NULL, 1, $1);
        // printf("1 of classdefs\n"  );
    }
    |  ClassDef ClassDefs  {
        $$ = new_node(3, "ClassDefs", 0, NULL, 2, $1, $2);
        // printf("2 of classdefs\n"  );
    }
    ;

ClassDef :
    CLASS ID ExtendDef LC Fields RC {
        $$ = new_node(4, "ClassDef", 0, NULL, 6, new_ter("CLASS"), new_id($2), $3, new_LC(), $5, new_RC() );
        // printf("class @ %d %d\n", @1.first_line, @6.first_line);
        // $$ = new_node("ClassDef", 0, NULL, 6, new_ter("CLASS"), new_id($2), $3, new_LC(), $5, new_RC() );
    }
    | error RC {
        $$ = new_node(5, "ClassDef", 0, NULL, 0);
        error_flag = 1;
        // printf("hhh\n");
    }
    // | error RC
    ;

Fields :
    {
        $$ = new_node(6, "Fields", 0, NULL, 0);
    }
    | Field Fields {
        $$ = new_node(7, "Fields", 0, NULL, 2, $1, $2);
    }
    ;

ExtendDef :
    {
        $$ = new_node(8, "ExtendDef", 0, NULL, 0);
    }
    | EXTENDS ID
    {
        // printf("%p\n",  $2);
        $$ = new_node(9, "ExtendDef", 0, NULL, 2, new_ter("EXTENDS"), new_id($2) );
    }
    ;

Field :
    VarDef {
        $$ = new_node(10, "Field", 0, NULL, 1, $1);
    }
    | FuncDef {
        $$ = new_node(11, "Field", 0, NULL, 1, $1);
    }
    ;

FuncDef :
    STATIC Type ID LP Formals RP StmtBlock {
        $$ = new_node(12 ,"FuncDef", 0, NULL, 7, new_ter("STATIC"), $2, new_id($3), new_LP(), $5, new_RP(), $7);
    }
    | Type ID LP Formals RP StmtBlock
    {
        $$ = new_node(13 ,"FuncDef", 0, NULL, 6, $1, new_id($2), new_LP(), $4, new_RP(), $6);
    }
    ;

//变量列表
Formals :
    {
        $$ = new_node(14, "Formals", 0, NULL, 0);
    }
    | Var FormalTail  {
        $$ = new_node(15, "Formals", 0, NULL, 2, $1, $2);
    }
    ;

FormalTail :
{
        $$ = new_node(16, "FormalTail", 0, NULL, 0);
    }
    | COMMA Var FormalTail  {
        $$ = new_node(17, "FormalTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

StmtBlock :
    LC StmtList RC {
        $$ = new_node(18,  "StmtBlock", 0, NULL, 3, new_LC(), $2, new_RC());

    }
    | error RC {
        $$ = new_node(19, "StmtBlock", 0, NULL, 0);
        // printf("hhh\n");
        error_flag = 1;
    }
    ;

StmtList : {
        $$ = new_node(20, "StmtList", 0, NULL, 0);
    }
    | Stmt StmtList{
        $$ = new_node(21, "StmtList", 0, NULL, 2, $1, $2);
    }
    ;

Stmt :
    VarDef {
        $$ = new_node(30, "Stmt", 0, NULL, 1, $1);

    }
    | SimpleStmt SEMI {
        $$ = new_node(31 ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | IfStmt {
        $$ = new_node(32 ,"Stmt", 0, NULL, 1, $1);
    }
    | WhileStmt {
        $$ = new_node(33 ,"Stmt", 0, NULL, 1, $1);
    }
    | ForStmt{
        $$ = new_node(34 ,"Stmt", 0, NULL, 1, $1);
    }
    | BreakStmt SEMI {
        $$ = new_node(35 ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | ReturnStmt SEMI {
        $$ = new_node(36 ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | PrintStmt SEMI {
        $$ = new_node(37 ,"Stmt", 0, NULL, 2, $1, new_SEMI());
    }
    | StmtBlock {
        $$ = new_node(38 ,"Stmt", 0, NULL, 1, $1);
    }

SimpleStmt :
    LValue ASSIGNOP Expr {
        $$ = new_node(39, "SimpleStmt", 0, NULL, 3, $1, new_ter("ASSIGNOP"), $3);

    }
    | Call {
        $$ = new_node(40, "SimpleStmt", 0, NULL, 1, $1);
    }
    | {
        $$ = new_node(41, "SimpleStmt", 0, NULL, 0);
    }
    ;

LValue :
    Expr PERIOD ID {
        $$ = new_node(42, "LValue", 0, NULL, 3, $1, new_ter("PEROID"), new_id($3));
    }
    | ID {
        $$ = new_node(43, "LValue", 0, NULL, 1, new_id($1));
    }
    | Expr LB Expr RB {
        $$ = new_node(44, "LValue", 0, NULL, 4, $1,new_LB(), $3, new_RB());
    }
    ;


Call :
    Expr PERIOD ID LP Actuals RP{
        $$ = new_node(45 ,"Call", 0, NULL, 6, $1, new_ter("PERIOD"), new_id($3), new_LP(), $5, new_RP());
    }
    | ID LP Actuals RP
    {
        $$ = new_node(46, "Call", 0, NULL, 4, new_id($1), new_LP(), $3, new_RP());
    }
    ;

//调用时的传参
Actuals :
    {
        $$ = new_node(47, "Actuals", 0, NULL, 0);
    }
    | ExprList{
        $$ = new_node(48, "Actuals", 0, NULL, 1, $1);
    }
    ;

IfStmt :
    IF LP BoolExpr RP Stmt ELSE Stmt {
        $$ = new_node(60,"IfStmt", 0, NULL, 7, new_ter("IF"), new_LP(), $3, new_RP(), $5, new_ter("ELSE"), $7);
    }
    | IF LP BoolExpr RP Stmt %prec LOWER_THAN_ELSE{
        $$ = new_node(61, "IfStmt", 0, NULL, 5, new_ter("IF"), new_LP(), $3, new_RP(), $5);
    }
    ;

WhileStmt :
    WHILE LP BoolExpr RP Stmt{
        $$ = new_node(62, "WhileStmt", 0, NULL, 5, new_ter("WHILE"), new_LP(), $3, new_RP(), $5);
    }
    ;

BoolExpr :
    Expr {
        $$ = new_node(63, "BoolExpr", 0, NULL, 1, $1);
    }
    ;

ForStmt :
    FOR LP SimpleStmt SEMI BoolExpr SEMI SimpleStmt RP Stmt {
        $$ = new_node(64, "ForStmt", 0, NULL, 9, new_ter("FOR"), new_LP(), $3, new_SEMI(), $5, new_SEMI(), $7, new_RP(), $9);
    }
    ;

BreakStmt :
    BREAK {
        $$ = new_node(65, "BreakStmt", 0, NULL, 1, new_ter("BREAK"));
    }
    ;

ReturnStmt :
    RETURN {
        $$ = new_node(66, "ReturnStmt", 0, NULL, 1, new_ter("RETURN"));
    }
    | RETURN Expr{
        $$ = new_node(67, "ReturnStmt", 0, NULL, 2, new_ter("RETURN"), $2);
    }
    ;

PrintStmt :
    PRINT LP ExprList RP{
        $$ = new_node(68, "PrintStmt", 0, NULL, 4, new_ter("PRINT"), new_LP(), $3, new_RP());
    }
    ;

ExprList :
    Expr ExprTail {
        $$ = new_node(70, "ExprList", 0, NULL, 2, $1, $2);
    }
    ;

ExprTail :
    // {$$ = NULL;}
    {
        $$ = new_node(71, "ExprTail", 0, NULL, 0);
    }
    | COMMA Expr ExprTail {
        $$ = new_node(72, "ExprTail", 0, NULL, 3, new_COMMA(), $2, $3);
    }
    ;

VarDef :
    Var SEMI {
        $$ = new_node(81 , "VarDef", 0, NULL, 2, $1, new_SEMI());
    }
    ;

Var :
    Type ID {
        $$ = new_node(82 , "Var", 0, NULL, 2, $1, new_id($2));
    }
    ;

Type :
    INT {
        $$ = new_node(83 , "Type",0, NULL, 1, new_ter("INT"));
    }
    | BOOL{
        $$ = new_node(84 , "Type",0, NULL, 1, new_ter("BOOL"));
    }
    | STRING{
        $$ = new_node(85 , "Type",0, NULL, 1, new_ter("STRING"));
    }
    | VOID{
        $$ = new_node(86 , "Type",0, NULL, 1, new_ter("VOID"));
    }
    | CLASS ID{
        $$ = new_node(87, "Type",0, NULL, 2, new_ter("CLASS"), new_id($2));
    }
    | Type LB RB{
        $$ = new_node(88 , "Type",0, NULL, 3, $1, new_LB(), new_RB());
    }
    ;

Constant :
    INTCONSTANT {
        $$ = new_node(91 , "Constant",0, NULL, 1, new_int($1));
    }
    | BOOLCONSTANT {
        $$ = new_node(92 , "Constant",0, NULL, 1, new_bool($1));
}
    | STRINGCONSTANT {
        $$ = new_node(93 , "Constant",0, NULL, 1, new_str($1));
}
    | NUL {
        $$ = new_node(94 , "Constant",0, NULL, 1, new_null());
}
    ;

Expr :
    Constant { $$ = new_node(100 ,"Expr", 0, NULL, 1, $1);}
    | LValue { $$ = new_node(101 ,"Expr", 0, NULL, 1, $1);}
    | THIS   {
        $$ = new_node( 102 ,"Expr", 0, NULL, 1, new_ter("this"));
    }
    | Call {
        $$ = new_node(103 ,"Expr", 0, NULL, 1, $1);
    }
    | LP Expr RP {$$ = new_node(104 ,"Expr", 0,NULL, 3, new_ter("LP"), $2, new_ter("RP"));}
    | Expr PLUS Expr {$$ = new_node(105 ,"Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr MINUS Expr   {$$ = new_node(106 ,"Expr", 0,NULL, 3, $1, new_ter("PLUS"), $3);}
    | Expr TIMES Expr  {$$ = new_node(107 ,"Expr", 0,NULL, 3, $1, new_ter("TIMES"), $3);}
    | Expr DIVIDE Expr  {$$ = new_node(108 ,"Expr", 0,NULL, 3, $1, new_ter("DIVIDE"), $3);}
    | Expr MOD Expr  {$$ = new_node(109 ,"Expr", 0,NULL, 3, $1, new_ter("MOD"), $3);}
    | Expr LESS Expr  {$$ = new_node(110 ,"Expr", 0,NULL, 3, $1, new_ter("LESS"), $3);}
    | Expr LESSEQ Expr  {$$ = new_node(111 ,"Expr", 0,NULL, 3, $1, new_ter("LESSEQ"), $3);}
    | Expr MORE Expr  {$$ = new_node(112 ,"Expr", 0,NULL, 3, $1, new_ter("MORE"), $3);}
    | Expr MOREEQ Expr  {$$ = new_node(113 ,"Expr", 0,NULL, 3, $1, new_ter("MOREEQ"), $3);}
    | Expr EQ Expr  {$$ = new_node(114 ,"Expr", 0,NULL, 3, $1, new_ter("EQ"), $3);}
    | Expr NOTEQ Expr  {$$ = new_node(115 ,"Expr", 0,NULL, 3, $1, new_ter("NOTEQ"), $3);}
    | Expr OR Expr  {$$ = new_node(116 ,"Expr", 0,NULL, 3, $1, new_ter("OR"), $3);}
    | Expr AND Expr  {$$ = new_node(117 ,"Expr", 0,NULL, 3, $1, new_ter("AND"), $3);}
    | MINUS Expr %prec UNARYMINUS {$$ = new_node(118, "Expr", 0, NULL, 2, new_ter("UNARYMINUS"), $2);}
    | NOT Expr %prec UNARYNOT { $$ = new_node(119, "Expr", 0, NULL, 2, new_ter("UNARYNOT"), $2);}
    | READINTEGER LP RP {$$ = new_node(120, "Expr", 0, NULL, 3, new_ter("READINTEGER"), new_ter("LP"), new_ter("RP"));}
    | READLINE LP RP {$$ = new_node(121, "Expr", 0, NULL, 3, new_ter("READLINE"), new_ter("LP"), new_ter("RP"));}
    | NEW ID LP RP {$$ = new_node(122, "Expr", 0, NULL, 4, new_ter("NEW"), new_id($2), new_ter("LP"), new_ter("RP"));}
    | NEW Type LB Expr RB {$$ = new_node(123, "Expr", 0, NULL, 5, new_ter("NEW"), $2, new_ter("LB"), $4, new_ter("RB")) ;}
    | INSTANCEOF LP Expr COMMA ID RP {
        $$ = new_node(124, "Expr", 0, NULL, 6, new_ter("INSTANCEOF"), new_LP(), $3, new_ter("COMMA"), new_id($5), new_RP());
    }
    | LP CLASS ID RP Expr {
        $$ = new_node(125, "Expr", 0, NULL, 5, new_LP(), new_ter("CLASS"), new_id($3), new_RP(), $5);
    }
    ;

%%
void InitPhase2(NODE *root){
    PreOrderTraverse(root, 0) ;
    pClass = NewSymbolItem(D_HEAD, NULL);
    ScanTree(1, root);
    ResolveBaseClass(pClass);
    ScanTree(2, root);
    PrintSymbolTable(pClass);
    // FirstScanTree(root);
    // CheckExtendsError();
    //
    // PrintClassNodeInfo();
    //
    // /* 开始第二遍扫描*/
    // pcurClass = pClass;
    // SecondScanTree(root);
    //
    // PrintClassNodeInfo();

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
NODE * new_node(int noderule, const char *left_name, int ivalue, char *str, int right_num, ...){
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
