#ifndef _DEFS_H
#define _DEFS_H

enum decaf_type{
    D_HEAD,
    D_CLASS,
    D_VAR,
    D_FUNC
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

typedef struct node_ {
    // char nodetype[10];
    int noderule;
    char *left_name;
    int ivalue;
    char *str;  //id和STRINGCONSTANT用到的

    int right_num;


    int line_1;
    // int line_2;
    int col_1;
    int col_2;

    struct node_ ** psons;
}NODE;

typedef struct symbitem SYMB_ITEM;

typedef struct blockcontainer{
    SYMB_ITEM *pVars;

    struct blockcontainer *next; //往下一个block

    struct blockcontainer *deep; //往深一个block;

}BlockContainer;

typedef struct classcontainer{
    SYMB_ITEM *pMembers; //成员变量的符号链表

    const char *baseClassName;  //若无继承的则为NULL, 若有继承的,则为继承的类名字
    // struct classnode *baseClass; // 指向基类ClassNode的指针
    SYMB_ITEM *pBaseClass;

    // struct classnode *next;     // 指向下一个
}ClassContainer;

typedef struct funccontainer{
    enum re_type retype;

    int is_static;

    SYMB_ITEM *pFormals;

    BlockContainer *pBlock;

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
    };

    struct symbitem *next;
}SYMB_ITEM;


/*打印*/
void myerror(const int code, int line_1, int col_2, const char *s, ...);
void PrintSymbolTable(SYMB_ITEM *pt);
void PrintSymbolNode(SYMB_ITEM *p);

/*符号表操作 */
SYMB_ITEM *FindInTable(SYMB_ITEM *pt, const char * str);
void InsertToTable(SYMB_ITEM *pt, SYMB_ITEM *pnew);

/* NEW */
SYMB_ITEM *NewSymbolItem(enum decaf_type KIND, const NODE *p);

/* Class相关 */
void HandleClassDefNode(const NODE *p );
void ResolveBaseClass(SYMB_ITEM *pc);

/*扫描*/
void ScanTree(int th, NODE *p);

#endif
