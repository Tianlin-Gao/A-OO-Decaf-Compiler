#ifndef DEBUG

// #define DEBUG

#endif

#ifndef TYPE

// #define TYPE

#endif

#ifndef _DEFS_H
#define _DEFS_H


enum decaf_type{
    D_HEAD,
    D_CLASS,
    D_VAR,
    D_FUNC,
    D_BLOCK  // 4
};

enum re_type{
    R_CLASS = 1,
    R_INT,
    R_BOOL
};

enum var_type{
    V_INT = 1,
    V_BOOL,
    V_STRING,
    V_VOID,
    V_CLASS // 5
};

enum _noderule{
    //  1
    N_program = 1,
    N_classdefs1 ,
    N_classdefs2 ,
    N_classdef ,
    N_classdeferr ,

    //6
    N_fieldsempty ,
    N_fields ,
    N_extendempty ,
    N_extend ,
    N_fieldvar ,

    // 11
    N_fieldfunc ,
    N_funcdefsta ,
    N_funcdef ,
    N_formalsempty ,
    N_formals ,

    //16
    N_formaltailempty ,
    N_formaltail ,
    N_stmtblock ,
    N_stmtblockerror ,
    N_stmtlistempty ,

    // 21
    N_stmtlist ,
    N_stmtVar ,
    N_stmtsimple ,
    N_stmtif ,
    N_stmtwhile ,

    //26
    N_stmtfor ,
    N_stmtbreak ,
    N_stmtreturn ,
    N_stmtprint ,
    N_stmtstmtblock ,

    //31
    N_simpleassign ,
    N_simplecall ,
    N_simpleempty ,

    //34
    N_lvaluemember ,
    N_lvalueid ,

    //36
    N_lvaluearray ,
    N_callmember ,
    N_call ,

    // 39
    N_actualsempty ,
    N_actualexpr ,

    //41
    N_ifstmt ,
    N_ifstmtelse ,
    N_whilestmt ,
    N_boolexpr ,
    N_forstmt ,

    //46
    N_breakstmt ,
    N_returnstmt ,
    N_returnstmtexpr ,
    N_printstmt ,
    N_exprlist ,

    //51
    N_exprtailempty ,
    N_exprtail ,

    //53
    N_vardef ,
    N_var ,

    //55
    N_typeint ,
    N_typebool ,
    N_typestring ,
    N_typevoid ,
    N_typeclass ,
    N_typearray ,

    //61
    N_conint ,
    N_conbool ,
    N_constring ,
    N_connull ,

    //65
    N_exprcon ,
    N_exprlvalue ,
    N_exprthis ,
    N_exprcall ,
    N_exprp,
    N_exprplus ,

    //71
    N_exprminus ,
    N_exprtimes ,
    N_exprdivide ,
    N_exprmod ,
    N_exprless ,

    //76
    N_exprlesseq ,
    N_exprmore ,
    N_exprmoreeq ,
    N_expreq ,
    N_exprnoteq ,

    // 81
    N_expror ,
    N_exprand ,
    N_exprneg ,
    N_exprnot ,
    N_exprrdint ,

    //86
    N_exprrdline ,
    N_exprnewobj ,
    N_exprnewarray ,
    N_exprinstance ,
    N_exprtrans,

    N_argument

};

typedef struct symbitem SYMB_ITEM;




typedef struct blockcontainer{
    SYMB_ITEM *pVars;

    SYMB_ITEM *pSonBlock; //往深一个block;

}BlockContainer;

typedef struct classcontainer{

    SYMB_ITEM *pMembers; //成员变量的符号链表

    const char *baseClassName;  //若无继承的则为NULL, 若有继承的,则为继承的类名字
    // struct classnode *baseClass; // 指向基类ClassNode的指针
    SYMB_ITEM *pBaseClass;

    // struct classnode *next;     // 指向下一个
}ClassContainer;

typedef struct funccontainer{
    enum var_type kind;
    SYMB_ITEM *pclass;
    int is_static;

    SYMB_ITEM *pFormals;

    SYMB_ITEM *pBlock;

}FuncContainer;

typedef struct varcontainer{
    enum var_type kind;// 1 int 2 bool 3 class
    SYMB_ITEM *pclass;
}VarContainer;


typedef struct symbitem{
    enum decaf_type kind;
    const char *name;

    union {
        VarContainer *pVar;
        FuncContainer *pFunc;
        ClassContainer *pClass;
        BlockContainer *pBlock;
    };

    struct symbitem *next;
}SYMB_ITEM;

typedef struct {
    enum decaf_type kind; // class / func / var

    union {

        VarContainer *pVar;
        FuncContainer *pFunc;
    };
}NODETYPE;

typedef struct node_ {
    // char nodetype[10];
    enum _noderule noderule;
    char *left_name;
    int ivalue;  // intcons
    char *str;  //id和STRINGCONSTANT用到的

    int right_num;

    NODETYPE *ptype;

    int line_1;
    // int line_2;
    int col_1;
    int col_2;

    struct node_ ** psons;
}NODE;

/*打印*/
void myerror(const int code, int line_1, int col_2, const char *s, ...);
void PrintSymbolTable(SYMB_ITEM *pt, int depth);
void PrintSymbolNode(SYMB_ITEM *p, int depth);

/*符号表操作 */
SYMB_ITEM *FindInTable(SYMB_ITEM *pt, const char * str);
void InsertToTable(SYMB_ITEM *pt, SYMB_ITEM *pnew);

/* NEW */
SYMB_ITEM *NewSymbolItem(enum decaf_type KIND, const NODE *p);
NODETYPE *NewNodeType1(NODETYPE *p);

/* Class相关 */
void HandleClassDefNode(const NODE *p );
void ResolveBaseClass(SYMB_ITEM *pc);

/*扫描*/
void ScanTree(int th, NODE *p);

#endif
