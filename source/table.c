#include "../include/inclu.h"
#include "../include/defs.h"

SYMB_ITEM *pClass;
SYMB_ITEM *pcur;
SYMB_ITEM *pcurtable;
SYMB_ITEM *pcurblock;

POSTK *pScur;
POSTK *pScurTable;
POSTK *pScurBlock;

extern int error_flag;

static SYMB_ITEM *pcurformal;
// static ACT_FLAG;


void PrintTab(int depth){
    for(int i = 0; i < depth; i++){
        printf("\t");
    }
}

void myerror(const int code, int line_1, int col_1, const char *s, ...){

    error_flag = 1;

  va_list ap;
  va_start(ap, s);
  if(line_1){
        fprintf(stderr, FONT_COLOR_RED"Line %d Col %d: "COLOR_NONE, line_1, col_1);

  }
  fprintf(stderr, FONT_COLOR_RED"ERROR %d : "COLOR_NONE, code);

  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n\n");
}

void PrintSymbolTable(SYMB_ITEM *pt, int depth){
    // for(SYMB_ITEM *p = pt->next; p != NULL; p = p->next){
    for(SYMB_ITEM *p = pt; p != NULL; p = p->next){
        PrintSymbolNode(p, depth);
    }
}

void PrintSymbolNode(SYMB_ITEM *p, int depth){
    // if(p->kind != D_HEAD && p->kind!=D_BLOCK){
    if(p->kind != D_HEAD ){
        printf("\n");

    }
    PrintTab(depth);
    switch(p->kind){
        case D_HEAD:
            #ifdef DEBUG
            printf("Head\n" );

            #endif
        break;
        case D_CLASS:
            printf("\n===================\n" );
            printf("Class Name: %s\t",p->name );
            if(p->pClass->baseClassName){
                printf("| Base Class Name:%s", p->pClass->baseClassName);
            }
            printf("\n");
            PrintSymbolTable(p->pClass->pMembers, depth + 1);
            printf("\n===================\n" );
            // PrintSymbolTable(p->pClass->pMembers);
        break;

        case D_FUNC:
            printf("Func Name: %s \t| Return Type: ",p->name );
            switch (p->pFunc->kind) {
                case V_INT:
                    printf("int" );
                break;
                case V_BOOL:
                    printf("bool" );
                break;
                case V_STRING:

                    printf("string" );
                break;
                case V_VOID:

                    printf("void" );
                break;
                case V_CLASS:

                    printf("class" );
                    printf("  Class Name: %s", p->pVar->pclass->name);
                break;
            }
            printf("\n");
            printf("\n");
            PrintTab(depth);
            printf(" >>  Formals:");
            printf("\n");
            PrintSymbolTable(p->pFunc->pFormals, depth + 1);
            printf("\n");
            printf("\n");
            PrintTab(depth);
            printf(" >> Function Body:");
            PrintSymbolTable(p->pFunc->pBlock, depth + 1);
            break;


        case D_VAR:
            printf("Var  Name: %s\t| Kind: ", p->name);
            switch (p->pVar->kind) {
                case V_INT:
                    printf("int" );
                break;
                case V_BOOL:
                    printf("bool" );
                break;
                case V_STRING:

                    printf("string" );
                break;
                case V_VOID:

                    printf("void" );
                break;
                case V_CLASS:

                    printf("class" );
                    printf("\t| Class Name: %s", p->pVar->pclass->name);
                break;
            }

        break;
        case D_BLOCK:
            #ifdef DEBUG
            printf("block\n");

            #endif
            PrintSymbolTable(p->pBlock->pVars, depth);

            PrintSymbolTable(p->pBlock->pSonBlock, depth+1);

        break;

    }
    return;
}



SYMB_ITEM *FindInTable(SYMB_ITEM *pt, const char * str){
    SYMB_ITEM *p;
    for(p = pt->next; p != NULL; p=p->next){
        assert(p->name != NULL);
        if(0 == strcmp(p->name, str)){
            return p;
        }
    }
    return NULL;
}

SYMB_ITEM *FindInTableStack(POSTK *p, const char *str){
    for(SYMB_ITEM *ptemp = pcurtable->next; ptemp != NULL; ptemp = ptemp->next){
        if(strcmp(ptemp->name, str) == 0){
            return ptemp;
        }
    }
    for (int i = p->pos - 1; i >= 0; i--) {
        // printf("Stack elem[%d]\t", i);
        for(SYMB_ITEM *ptemp = p->elems[i]->next; ptemp != NULL; ptemp = ptemp->next){
            // printf("%s ;  ", ptemp->name);
           if(strcmp(ptemp->name, str)  == 0){
               return ptemp;
           }
        }
        // printf("\n");
    }
    return NULL;
}

void InsertToTable(SYMB_ITEM *pt, SYMB_ITEM *pnew){
    /* 插入到链表尾部,因为最先遍历到的,在程序中先出现,所以按道理,应该排到前面 */
    SYMB_ITEM *ptemp;
    SYMB_ITEM *pprior;
    for(ptemp = pt->next, pprior = pt; ptemp != NULL; pprior = pprior->next, ptemp = ptemp->next){
        assert(ptemp->name != NULL);
    }

    assert(pnew != NULL);
    pprior->next = pnew; //此时在队尾
    #ifdef DEBUG
    printf("插入 %s\n", pnew->name);

    #endif
}

SYMB_ITEM *NewSymbolItem(enum decaf_type KIND, const NODE *p){
    SYMB_ITEM *pnew = (SYMB_ITEM *)malloc(sizeof(SYMB_ITEM));

    pnew->kind = KIND;
    #ifdef DEBUG
    printf("NewSymbolItem:  ");

    #endif
    assert(pnew != NULL);

    switch (KIND) {
        case D_HEAD:
        #ifdef DEBUG
            printf(" head\n" );

        #endif
            pnew->pVar = NULL;
            pnew->name = NULL;
            pnew->next = NULL;
        break;
        case D_CLASS:
            pnew->pClass = (ClassContainer *)malloc(sizeof(ClassContainer));
            pnew->name = p->psons[1]->str;
            pnew->pClass->pMembers = NewSymbolItem(D_HEAD, NULL);
            pnew->next = NULL;
            if(p->psons[2]->right_num == 2)
            {
                pnew->pClass->baseClassName = p->psons[2]->psons[1]->str;
                pnew->pClass->pBaseClass = FindInTable(pClass, pnew->pClass->baseClassName);
                if(pnew->pClass->pBaseClass == NULL){
                    //TODO 报错
                    // myerror(0, p->line_1, p->col_1"%s 找不到基类 %s\n",pnew->name, pnew->pClass->baseClassName);
                }
            }
            else{
                pnew->pClass->baseClassName = NULL;
                pnew->pClass->pBaseClass = NULL;
            }
        break;

        case D_VAR:
        #ifdef DEBUG

            printf("Var\n" );
        #endif
            pnew->pVar = (VarContainer *)malloc(sizeof(VarContainer));
            pnew->name = NULL;
            pnew->next = NULL;
            pnew->pVar->pclass = NULL;
            break;

        case D_FUNC:
        #ifdef DEBUG
            printf("Func\n" );

        #endif
            pnew->pFunc = (FuncContainer *)malloc(sizeof(FuncContainer));
            pnew->name = NULL;
            pnew->next = NULL;
            pnew->pFunc->pFormals = NewSymbolItem(D_HEAD, NULL);
            pnew->pFunc->pBlock =NewSymbolItem(D_HEAD, NULL);
            break;

        case D_BLOCK:
        #ifdef DEBUG
            printf("Block\n");

        #endif
            pnew->pBlock = (BlockContainer *)malloc(sizeof(BlockContainer));
            pnew->name = strdup("Block");
            pnew->next = NULL;
            pnew->pBlock->pVars = NewSymbolItem(D_HEAD, NULL);
            pnew->pBlock->pSonBlock = NewSymbolItem(D_HEAD, NULL);
            break;


        default:
            printf("666\t%d",KIND );
    }
    return pnew;
}

NODETYPE *NewNodeType1(NODETYPE *p){
    NODETYPE *pnew = (NODETYPE *)malloc(sizeof(NODETYPE));
    if(p->kind == D_FUNC){
        pnew->kind = D_VAR;
        pnew->pVar = (VarContainer *)malloc(sizeof(VarContainer));
        pnew->pVar->kind = p->pFunc->kind;
        pnew->pVar->pclass = p->pFunc->pclass;

    }
    return pnew;
}

/**********
函数功能: 寻找变量的定义,一直找到成员变量域.如果找不到则报错.
        如果找到了,根据定义的类型,赋予对应的var类型, 函数Container, 类Container

参数 : ID节点

*****/
NODETYPE *NewNodeType1_2(const NODE *p){
    NODETYPE *pnew = (NODETYPE *)malloc(sizeof(NODETYPE));
    SYMB_ITEM *psym = FindInTableStack(pScurTable, p->str);
    if(psym == NULL){
        myerror(0, p->line_1, p->col_1, "找不到变量 %s 的定义", p->str );
        return NULL;
    }
    else{
        #ifdef TYPE
            printf("find %s : ok\n", p->str );
        #endif
        pnew->kind = psym->kind;
        switch (psym->kind) {
            case D_VAR:
            pnew->pVar = psym->pVar;
        #ifdef TYPE
            printf("新建: Var, 变量名%s\n", pnew->kind, psym->name);
        #endif
            break;
            case D_FUNC:
        #ifdef TYPE
            printf("新建: Func, 变量名%s\n", pnew->kind, psym->name);
        #endif
                pnew->pFunc = psym->pFunc;

            break;
            case D_CLASS:
            //绝对找不到class,只能是func 和 var
            exit(-9);

            break;
            default:
            break;
        }
        return pnew;
    }


}

NODETYPE *NewNodeType2opnotype(const NODE *p,  NODETYPE *p1,  NODETYPE *p2){



    /* 有一个是空节点表示已经出现了错误 */
    if(p1 == NULL || p2 == NULL){
        #ifdef TYPE
            printf("%s : blank expr\n", p->left_name );
        #endif
        return NULL;
    }
    /* 都是Var类型 且 都为 t类型 */
    if(p1->kind == p2->kind && p2->kind == D_VAR && p1->pVar->kind == p2->pVar->kind ){
        if(p1->pVar->kind == V_CLASS){
            if(p1->pVar->pclass != p2->pVar->pclass){
                myerror(0, p->line_1, p->col_1, "操作数的类不一致: 不应为%s, 应为%s", p1->pVar->pclass->name, p2->pVar->pclass->name);
                return NULL;
            }
        }
        #ifdef TYPE
            printf("%s : ok\n", p->left_name );
        #endif
        return p1;
    }
    else
    {
        #ifdef TYPE
        // printf("%d, %d | %d, %d\n", p1->kind, p2->kind, p1->varkind, p2->varkind);
        #endif
        #ifdef TYPE
            printf("notype\n" );
        #endif
        myerror(0, p->line_1, p->col_1, "操作数类型不匹配");

        return NULL;
    }
}


NODETYPE *NewNodeType2optype(const NODE *p,  NODETYPE *p1,  NODETYPE *p2, enum var_type t){
    /* 有一个是空节点表示已经出现了错误 */
    if(p1 == NULL || p2 == NULL){
        #ifdef TYPE
            printf("%s : blank expr\n", p->left_name );
        #endif
        return NULL;
    }
    /* 都是Var类型 且 都为 t类型 */
    if(p1->kind == p2->kind && p2->kind == D_VAR && p1->pVar->kind == p2->pVar->kind && p2->pVar->kind == t){
        assert(t != V_CLASS); //TODO 处理class
        #ifdef TYPE
            printf("%s : ok\n", p->left_name );
        #endif
        return p1;
    }
    else
    {

        #ifdef TYPE
        // printf("%d, %d | %d, %d\n", p1->kind, p2->kind, p1->varkind, p2->varkind);
        #endif
        #ifdef TYPE
            printf("optype\n" );
        #endif
        myerror(0, p->line_1, p->col_1, "操作数类型不匹配");
        return NULL;
    }
}

void HandleClassDefNode(const NODE *p ){

    SYMB_ITEM *pnew = NewSymbolItem(D_CLASS ,p);
    if(FindInTable(pClass, pnew->name)){
        //TODO 报错
        myerror(0, p->line_1, p->col_1, "重复定义了类%s", pnew->name);
    }
    else{
        InsertToTable(pClass, pnew);
    }

}

void ResolveBaseClass(SYMB_ITEM *pc){
    // 解决前面extends后面定义的类
//报错: extends未定义的类
    ClassContainer *(a[N]);
    int i = 0;
    for(SYMB_ITEM *p = pc->next; p != NULL; p = p->next){
        //继承于自己
        if(p->pClass->baseClassName){
            if(strcmp(p->pClass->baseClassName, p->name) == 0){
                // prln("ERROR 20: Can't extends itself");
                p->pClass->baseClassName = NULL;  //若出错,则假设没有extends语句,继续进行检查

                myerror(20, 0, 0, "%s 不能继承于自己", p->name);
                continue;
            }
        }
        //当出现定义在声明之后时,会打印 子类 ---???---> 基类
        if(p->pClass->baseClassName != NULL && p->pClass->pBaseClass == NULL){
            #ifdef DEBUG
            printf("%s --?--> %s\n", p->name, p->pClass->baseClassName);

            #endif
            a[i++] = p->pClass;
            // continue;
        }
        // 当解决了上述问题之后,会打印 子类 ------> 基类
        for(int j = 0; j < i; ++j){
            if(strcmp(a[j]->baseClassName, p->name) == 0){
                #ifdef DEBUG
                printf("-------> %s\n", p->name) ;

                #endif
                a[j]->pBaseClass = p;
            }
        }
    }
    //若此时还有基类未定义,则报错
    for(SYMB_ITEM *p = pClass->next; p != NULL; p = p->next){
        if(p->pClass->baseClassName != NULL && p->pClass->pBaseClass == NULL){
            // printf("ERROR 21 : %s 没找到基类  %s\n", p->str, p->baseClassName);
            // myerror(0, "test", "hhh", "\t hh");
            myerror(21,82, 28, "%s 缺少基类 %s 的定义", p->name, p->pClass->baseClassName);
        }
    }
}

bool HandleArgumentTypeCompare(VarContainer *p1, VarContainer *p2){
    if(p1->kind == p2->kind && p1->pclass == p2->pclass){
        return true;
    }
    return false;

}

void HandleTypeDef(const NODE *p){
    SYMB_ITEM *ptemp;
    // if(!pcur)
    //     return;
    switch (p->noderule) {
        case N_typeint:
            if(pcur->kind == D_VAR){
                pcur->pVar->kind = V_INT;
            }
            else if(pcur->kind == D_FUNC){
                pcur->pFunc->kind = V_INT;
            }
        break;
        case N_typebool:
            if(pcur->kind == D_VAR){
                pcur->pVar->kind = V_BOOL;
            }
            else if(pcur->kind == D_FUNC){
                pcur->pFunc->kind = V_BOOL;
            }
        break;
        case N_typestring:
            if(pcur->kind == D_VAR){
                pcur->pVar->kind = V_STRING;
            }
            else if(pcur->kind == D_FUNC){
                pcur->pFunc->kind = V_STRING;
            }
        break;
        case N_typevoid:
            if(pcur->kind == D_VAR){
                pcur->pVar->kind = V_VOID;
            }
            else if(pcur->kind == D_FUNC){
                pcur->pFunc->kind = V_VOID;
            }
        break;
        case N_typeclass:

            ptemp = FindInTable(pClass, p->psons[1]->str);
            //定义的类不存在
            if(ptemp == NULL){
                myerror(0, p->line_1, p->col_1, "对象 %s 的类 %s不存在", pcur->name, p->psons[1]->str);
                free(pcur);
                pcur = NULL;
                return ;
            }
            if(pcur->kind == D_VAR){
                pcur->pVar->kind = V_CLASS;
                pcur->pVar->pclass = ptemp;
            }
            else if(pcur->kind == D_FUNC){
                pcur->pFunc->kind = V_CLASS;
                pcur->pFunc->pclass = ptemp;
            }
        break;
        default :
             break;
    }

}

void ScanTree(int th, NODE *p){
    #ifdef DEBUG
    printf("NODERULE : %d\n", p->noderule);

    #endif
    assert(p != NULL);
    switch(p->noderule){
        case N_program:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;


        case N_classdef:
            if(th == 1){
                HandleClassDefNode(p);
            }
            else if(th == 2){
                // push(pScurTable, pcurtable);
                pcurtable =  (FindInTable(pClass, p->psons[1]->str))->pClass->pMembers;
            }
            else if(th == 3){
                // push(pScurTable, pcurtable);
                pcurtable =  (FindInTable(pClass, p->psons[1]->str))->pClass->pMembers;
            }
            break;

        case N_fieldvar:
            if(th == 3){
                return;
            }



        case N_fieldfunc: //Field FuncDef
            if(th == 1){

            }
            else if(th == 2){
                pcur = NewSymbolItem(D_FUNC, NULL);
            }
            else if(th == 3){
                // if(howMany(pScurTable) >= 1){
                //     pcurtable = pop(pScurTable);
                // }
            }
            break;

        case N_funcdefsta: //FuncDef Static
            if(th == 1){

            }
            else if(th == 2){
                pcur->name = p->psons[2]->str;
                pcur->pFunc->is_static = 1;
            }
            else if(th == 3){
                // push(pScurTable, pcurtable);
                //利用pcur做个跳转, 指示下一层该怎么做
                pcur = FindInTable(pcurtable, p->psons[2]->str);
            }
            break;

        case N_funcdef:
            if(th == 1){

            }
            else if(th == 2){
                pcur->name = p->psons[1]->str;
                pcur->pFunc->is_static = 0;

            }
            else if(th == 3){
                // push(pScurTable, pcurtable);
                pcur = FindInTable(pcurtable, p->psons[1]->str);
            }
            break;

        // Formals empty
            if(th == 1){

            }
            else if(th == 2){
                // printf("无参数\n", );
            }
            else if(th == 3){

            }
            break;

        case N_formals: //Formals
        case N_formalsempty:
            if(th == 1){

            }
            else if(th == 2){
                //切换到参数符号表
                push(pScurTable, pcurtable);
                pcurtable = pcur->pFunc->pFormals;
                //保存当前函数符号表项
                assert(pScur != NULL);
                push(pScur, pcur);
            }
            else if(th == 3){
                push(pScurTable, pcurtable);
                push(pScurTable, pcur->pFunc->pFormals);
                return ;
            }
            break;



            case N_call:
                if(th == 3){

                    NODETYPE *pf = NewNodeType1_2(p->psons[0]);
                    if(pf->kind != D_FUNC){
                        myerror(0, p->psons[0]->line_1, p->psons[0]->col_1, "变量 %s 应为一个函数", p->psons[0]->str);
                        p->ptype = NULL;
                        return ; //不检查接下来的节点
                    }
                    else{
                        p->ptype = NewNodeType1(pf);  // 产生一个变量节点
                        pcurformal = pf->pFunc->pFormals->next;
                    }
                    // return;

                }
            break;

        case N_stmtblock:
            if(th == 1){

            }
            else if(th == 2){
                #ifdef DEBUG
                printf("应该到stmtblock\n");

                #endif
                // exit(-1);
                return;
            }
            else if(th == 3){
                if(pcur->kind == D_FUNC){
                #ifdef DEBUG
                    printf("Func->block\n");
                #endif


                    // 当前pcur为函数
                    //当前pcurtable为Members
                    pcurblock = pcur->pFunc->pBlock;

                    SYMB_ITEM *pnew = NewSymbolItem(D_BLOCK, NULL);
                    InsertToTable(pcurblock, pnew);

                    pcurblock = pnew;

                    //当前pcurtable为pMembers
                    // push(pScurTable, pcurtable);
                    // push(pScurTable, pcur->pFunc->pFormals);
                    pcurtable = pnew->pBlock->pVars;

                }
                else {
                    #ifdef DEBUG
                    printf("block->block\n");

                    #endif
                    push(pScurBlock, pcurblock);
                    // pcurblock = pcurblock->pBlock->pSonBlock;
                    SYMB_ITEM *pnew = NewSymbolItem(D_BLOCK, NULL);
                    InsertToTable(pcurblock->pBlock->pSonBlock, pnew);

                    pcurblock = pnew;
                    //TODO
                    // ptemp = pcurtable->pBlock->pSonBlock;
                    push(pScurTable, pcurtable);
                    pcurtable = pnew->pBlock->pVars;
                }

            }
            break;


        case N_var:
            if(th == 1){

            }
            else if(th == 2){
                // printf("82\n" );
                pcur = NewSymbolItem(D_VAR, NULL); // NULL是因为这时候还不知道
                pcur->name = p->psons[1]->str;
            }
            else if(th == 3){
                pcur = NewSymbolItem(D_VAR, NULL); // NULL是因为这时候还不知道
                pcur->name = p->psons[1]->str;

            }
            break;
        case N_typeint:
        case N_typevoid:
        case N_typebool:
        case N_typestring:
        case N_typeclass:
            if(th == 1){

            }
            else if(th == 2){
                HandleTypeDef(p);

            }
            else if(th == 3){
                HandleTypeDef(p);

            }
            break;

        default:
                 break;

    }


    for(int i = 0; i < p->right_num ; i++){
       ScanTree(th, p->psons[i]);
   }



   switch(p->noderule){
       case N_stmtblock:
       if(th == 3){

            print(pScurTable);
            if(howMany(pScurTable) == 2){
                pop(pScurTable);
            }
           pcurtable = pop(pScurTable);
           //这个应该会报个错 pScurBlock 已为空
           pcurblock = pop(pScurBlock);

       }
       break;

       case N_formals:
       case N_formalsempty:
           if(th == 1){

           }
           else if(th == 2){
               //若函数形参没有问题的话插入函数
               pcur = pop(pScur);
               pcurtable = pop(pScurTable);
               assert(pcur->kind == D_FUNC);
               if(pcur->kind == D_FUNC){
                   if(FindInTable(pcurtable, pcur->name) == NULL){

                       InsertToTable(pcurtable, pcur);
                    //    printf("插入 %s\n", pcur->name);
                   }
                   else{
                       myerror(7, p->line_1, p->col_1, " 标识符 %s 在此被重复定义", pcur->name);
                       // free(pcur)
                   }
               }
               return;
           }
           else if(th == 3){
               printf("error\n");
           }
           break;

    case N_funcdef:
    case N_funcdefsta:
        // // 弹出pformals
        // if(th == 3){
        // pop(pScurTable);
        //
        // //弹出pmembers
        // pcurtable = pop(pScurTable);
        // }
    break;


       case N_var:
           if(th == 1){

           }
           else if(th == 2 || th == 3){
               // 如果是变量的话,已经处理完成了,可以插入符号表
               //如果是其他的话,还需要看参数是否正确
               if(pcur->kind == D_VAR ){
                   if(FindInTable(pcurtable, pcur->name) == NULL){
                       InsertToTable(pcurtable, pcur);
                    //    printf("插入 %s\n", pcur->name);
                   }
                   else{
                       myerror(0, p->line_1, p->col_1, " %s 重复定义", pcur->name);
                   }
               }
           }
        //    else if(th == 3){
           //
        //    }
           break;


           case N_callmember:
               #ifdef DEBUG
                   printf("callmember\n");
               #endif
               if(th == 3){
                   if(p->psons[0]->ptype == NULL){
                       #ifdef DEBUG
                       printf("1 %s\n", p->psons[0]->left_name );

                       #endif
                       p->ptype = NULL;
                       return;
                   }
                   if(p->psons[0]->ptype->kind != D_VAR || p->psons[0]->ptype->pVar->kind != V_CLASS){
                       myerror(14, p->line_1, p->col_1, "对非对象使用了 . 运算符");
                       p->ptype = NULL;
                       return;
                   }
                   SYMB_ITEM *pc =  p->psons[0]->ptype->pVar->pclass;
                   SYMB_ITEM *pfunc = FindInTable(pc->pClass->pMembers, p->psons[2]->str);
                   if(pfunc == NULL){
                       myerror(15, p->line_1, p->col_1, "访问了类%s 不存在的域 %s", pc->name, p->psons[2]->str);
                       return;
                   }

               }
           break;

        case N_call:
            if(th == 3){
                if(pcurformal != NULL){
                    for(;pcurformal!=NULL; pcurformal = pcurformal->next){
                        myerror(0, p->line_1, p->col_1, "参数个数不匹配,缺少参数 %s", pcurformal->name);
                    }
                }
            }
        break;

        case N_argument:
            if(th == 3){
                if(pcurformal == NULL){
                    myerror(0, p->line_1, p->col_1, "参数个数不匹配,有多余的参数");
                    return;
                }
                NODETYPE *pt = p->psons[0]->ptype;
                assert(pt->kind == D_VAR);
                assert(pcurformal->kind == D_VAR); // TODO 可能为一个函数,待处理
                VarContainer *pv = pcurformal->pVar;
                if(false == HandleArgumentTypeCompare(pt->pVar, pv)){
                       myerror(0, p->line_1, p->col_1, "参数类型不匹配" );
                }
                pcurformal = pcurformal->next;
            }

        break;

        case N_simpleassign:
            if(th == 3){
                p->ptype = NewNodeType2opnotype(p->psons[1], p->psons[0]->ptype, p->psons[2]->ptype);
                #ifdef TYPE
                // if(p->ptype)
                    // printf("%d : %d \n", p->ptype->kind, p->ptype->varkind);
                #endif
            }
        break;

        case N_exprlvalue:
        case N_exprcall:
            if(th == 3){
                p->ptype = p->psons[0]->ptype;
                #ifdef TYPE
                // if(p->ptype)
                //     printf("%d : %d \n", p->ptype->kind, p->ptype->varkind);
                #endif
            }
        break;

        case N_lvalueid:
            if(th == 3){
                // 找到id

                //
                p->ptype = NewNodeType1_2(p->psons[0]);
                #ifdef TYPE
                // if(p->ptype)
                    // printf("%d : %d \n", p->ptype->kind, p->ptype->varkind);
                #endif
            }
        break;

        case N_exprplus:
        case N_exprminus:
        case N_exprtimes:
        case N_exprdivide:
            if(th == 3){
                p->ptype = NewNodeType2optype(p->psons[1], p->psons[0]->ptype, p->psons[2]->ptype, V_INT);
                #ifdef TYPE
                // if(p->ptype)
                    // printf("%d : %d \n", p->ptype->kind, p->ptype->varkind);
                #endif
            }
        break;
        case N_exprless:
        case N_exprlesseq:
        case N_exprmore:
        case N_exprmoreeq:
        case N_expreq:
        case N_exprnoteq:
            if(th == 3){
                p->ptype = NewNodeType2optype(p->psons[1], p->psons[0]->ptype, p->psons[2]->ptype, V_BOOL);
                #ifdef TYPE
                // if(p->ptype)
                    // printf("%d : %d \n", p->ptype->kind, p->ptype->varkind);
                #endif
            }
        break;


        case N_exprneg:

        break;

        case N_exprnot:

        break;


        default :
            return ;
   }
}
