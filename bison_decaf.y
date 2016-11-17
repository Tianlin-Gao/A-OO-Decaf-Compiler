%{
    #include <stdio.h>
    #include "lex.yy.c"
%}

// declare tokes
%token INT BOOL STRING VOID NUL
%token STATIC
%token PRINT READINTEGER READLINE INSTANCEOF
%token SEMI COMMA PERIOD
%token LP RP LB RB LC RC // () [] {}
%token ASSIGNOP  // =
%token EXTENDS CLASS THIS NEW
%token INTCONSTANT STRINGCONSTANT BOOLCONSTANT
%token ID

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



%%
Program :
    ClassDefs
    ;

ClassDefs :
    ClassDef
    |  ClassDef ClassDefs
    ;

ClassDef :
    CLASS ID ExtendDef LC Fields RC
    ;

Fields :

    | Field Fields
    ;

ExtendDef :

    | EXTENDS ID
    ;

Field :
    VarDef
    | FuncDef
    ;

FuncDef :
    STATIC Type ID LP Formals RP StmtBlock
    | Type ID LP Formals RP StmtBlock
    ;

//变量列表
Formals :
    | Var FormalTail
    ;

FormalTail :

    | COMMA Var FormalTail
    ;

StmtBlock :
    LC StmtList RC
    ;

StmtList :

    | Stmt StmtList
    ;

Stmt :
    VarDef
    | SimpleStmt SEMI
    | IfStmt
    | WhileStmt
    | ForStmt
    | BreakStmt SEMI
    | ReturnStmt SEMI
    | PrintStmt SEMI
    | StmtBlock

SimpleStmt :
    LValue ASSIGNOP Expr
    | Call
    |
    ;

LValue :
    ClassMember ID
    | Expr LB Expr RB
    ;

ClassMember :

    | Expr PERIOD
    ;

Call :
    ClassMember ID LP Actuals RP
    ;

//调用时的传参
Actuals :

    |ExprList
    ;

IfStmt :
    IF LP BoolExpr RP Stmt ELSE Stmt
    | IF LP BoolExpr RP Stmt %prec LOWER_THAN_ELSE
    ;

WhileStmt :
    WHILE LP BoolExpr RP Stmt
    ;

BoolExpr :
    Expr
    ;

ForStmt :
    FOR LP SimpleStmt SEMI BoolExpr SEMI SimpleStmt RP Stmt
    ;

BreakStmt :
    BREAK
    ;

ReturnStmt :
    RETURN
    | RETURN Expr
    ;

PrintStmt :
    PRINT LP ExprList RP
    ;

ExprList :
    Expr ExprTail
    ;

ExprTail :

    | COMMA Expr ExprTail
    ;

VarDef :
    Var SEMI
    ;

Var :
    Type ID
    ;

Type :
    INT
    | BOOL
    | STRING
    | VOID
    | CLASS ID
    | Type LB RB
    ;

Constant :
    INTCONSTANT
    | BOOLCONSTANT
    | STRINGCONSTANT
    | NUL
    ;

Expr :
    Constant
    | LValue
    | THIS
    | Call
    | LP Expr RP
    | Expr PLUS Expr
    | Expr MINUS Expr
    | Expr TIMES Expr
    | Expr DIVIDE Expr
    | Expr MOD Expr
    | Expr LESS Expr
    | Expr LESSEQ Expr
    | Expr MORE Expr
    | Expr MOREEQ Expr
    | Expr EQ Expr
    | Expr NOTEQ Expr
    | Expr OR Expr
    | Expr AND Expr
    | MINUS Expr %prec UNARYMINUS
    | NOT Expr %prec UNARYNOT
    | READINTEGER LP RP
    | READLINE LP RP
    | NEW ID LP RP
    | NEW Type LB Expr RB
    | INSTANCEOF LP Expr COMMA ID RP
    | LP CLASS ID RP Expr
    ;
