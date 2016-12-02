#include "../include/inclu.h"
#include "../include/defs.h"

SYMB_ITEM *pClass;
SYMB_ITEM *pcur;
SYMB_ITEM *pcurtable;
void myerror(const int code, int line_1, int col_1, const char *s, ...){

  va_list ap;
  va_start(ap, s);
  if(line_1){
        fprintf(stderr, FONT_COLOR_RED"Line %d Col %d: "COLOR_NONE, line_1, col_1);

  }
  fprintf(stderr, FONT_COLOR_RED"ERROR %d : "COLOR_NONE, code);

  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}

void PrintSymbolTable(SYMB_ITEM *pt){
    for(SYMB_ITEM *p = pt->next; p != NULL; p = p->next){
        PrintSymbolNode(p);
    }
}

void PrintSymbolNode(SYMB_ITEM *p){
    switch(p->kind){
        case D_HEAD:

        break;
        case D_CLASS:
            printf("===================\n" );
            printf("Class Name: %s",p->name );
            if(p->pClass->baseClassName){
                printf("  Base Class Name:%s", p->pClass->baseClassName);
            }
            printf("\n");
            PrintSymbolTable(p->pClass->pMembers);
            printf("===================\n" );
            // PrintSymbolTable(p->pClass->pMembers);
        break;

        case D_VAR:
            printf("\tVar Name:%s  Kind: ", p->name);
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
                    printf("  Class Name: %s", p->pVar->pclass->name);
                break;
            }
            printf("\n");

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

void InsertToTable(SYMB_ITEM *pt, SYMB_ITEM *pnew){
    /* 插入到链表尾部,因为最先遍历到的,在程序中先出现,所以按道理,应该排到前面 */
    SYMB_ITEM *ptemp;
    SYMB_ITEM *pprior;
    for(ptemp = pt->next, pprior = pt; ptemp != NULL; pprior = pprior->next, ptemp = ptemp->next){
        assert(ptemp->name != NULL);
    }

    assert(pnew != NULL);
    pprior->next = pnew; //此时在队尾
    printf("插入 %s\n", pnew->name);
}

SYMB_ITEM *NewSymbolItem(enum decaf_type KIND, const NODE *p){
    SYMB_ITEM *pnew = (SYMB_ITEM *)malloc(sizeof(SYMB_ITEM));

    pnew->kind = KIND;

    assert(pnew != NULL);

    switch (KIND) {
        case D_HEAD:
            pnew->pVar = NULL;
            pnew->name = NULL;
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
                    printf("%s 找不到基类 %s\n",pnew->name, pnew->pClass->baseClassName);
                }
            }
            else{
                pnew->pClass->baseClassName = NULL;
                pnew->pClass->pBaseClass = NULL;
            }
        break;

        case D_VAR:
            printf("Var\n" );
            pnew->pVar = (VarContainer *)malloc(sizeof(VarContainer));
            pnew->name = NULL;
            pnew->next = NULL;
            pnew->pVar->pclass = NULL;
            break;

        case D_FUNC:
            printf("Func\n" );
            pnew->pFunc = (FuncContainer *)malloc(sizeof(FuncContainer));
            pnew->name = NULL;
            pnew->next = NULL;
            pnew->pFunc->pFormals = NewSymbolItem(D_HEAD, NULL);
            pnew->pFunc->pBlock = NULL;
            break;

        default:
            printf("666\n" );
    }
    return pnew;
}

void HandleClassDefNode(const NODE *p ){

    SYMB_ITEM *pnew = NewSymbolItem(D_CLASS ,p);
    if(FindInTable(pClass, pnew->name)){
        //TODO 报错
        printf("重复定义\n" );
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
            printf("%s --?--> %s\n", p->name, p->pClass->baseClassName);
            a[i++] = p->pClass;
            // continue;
        }
        // 当解决了上述问题之后,会打印 子类 ------> 基类
        for(int j = 0; j < i; ++j){
            if(strcmp(a[j]->baseClassName, p->name) == 0){
                printf("-------> %s\n", p->name) ;
                a[j]->pBaseClass = p;
            }
        }
    }
    //若此时还有基类未定义,则报错
    for(SYMB_ITEM *p = pClass->next; p != NULL; p = p->next){
        if(p->pClass->baseClassName != NULL && p->pClass->pBaseClass == NULL){
            // printf("ERROR 21 : %s 没找到基类  %s\n", p->str, p->baseClassName);
            // myerror(0, "test", "hhh", "\t hh");
            myerror(21,0, 0, "%s 缺少基类 %s 的定义", p->name, p->pClass->baseClassName);
        }
    }
}

void HandleVarTypeDef(const NODE *p){
    switch (p->noderule) {
        case 83:
            pcur->pVar->kind = V_INT;
        break;
        case 84:
            pcur->pVar->kind = V_BOOL;
        break;
        case 85:
            pcur->pVar->kind = V_STRING;
        break;
        case 86:
            pcur->pVar->kind = V_VOID;
        break;
        case 87:
            pcur->pVar->kind = V_CLASS;
            pcur->pVar->pclass = FindInTable(pClass, p->psons[1]->str);
            //定义的类不存在
            if(pcur->pVar->pclass == NULL ){
                myerror(0, p->line_1, p->col_1, "对象 %s 的类 %s不存在", pcur->name, p->psons[1]->str);
                free(pcur);
                pcur = NULL;
                return ;
            }

        break;
    }
    if(FindInTable(pcurtable->pClass->pMembers, pcur->name) == NULL){
        InsertToTable(pcurtable->pClass->pMembers, pcur);
        printf("插入变量 %s\n", pcur->name);
    }
    else{
        myerror(0, p->line_1, p->col_1, "变量 %s 重复定义", pcur->name);
    }
}

void ScanTree(int th, NODE *p){
    // printf("%d\n", p->noderule);
    assert(p != NULL);
    switch(p->noderule){
        case 1:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 2:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 3:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 4:
            if(th == 1){
                HandleClassDefNode(p);
            }
            else if(th == 2){
                pcurtable = FindInTable(pClass, p->psons[1]->str);
            }
            else if(th == 3){

            }
            break;

        case 5:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 6:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 7:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 8:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 9:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 10:
            if(th == 1){

            }
            else if(th == 2){
                pcur = NewSymbolItem(D_VAR, NULL); // NULL是因为这时候还不知道
            }
            else if(th == 3){

            }
            break;

        case 11:
            if(th == 1){

            }
            else if(th == 2){
                pcur = NewSymbolItem(D_FUNC, NULL);
            }
            else if(th == 3){

            }
            break;

        case 12: case 13:
            if(th == 1){

            }
            else if(th == 2){
                return;
            }
            else if(th == 3){

            }
            break;


        case 14:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 15:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 16:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 17:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 18:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 19:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;

        case 20:
            if(th == 1){

            }
            else if(th == 2){

            }
            else if(th == 3){

            }
            break;
        case 82:
            if(th == 1){

            }
            else if(th == 2){
                // printf("82\n" );
                pcur->name = p->psons[1]->str;
            }
            else if(th == 3){

            }
            break;
        case 83:
        case 84:
        case 85:
        case 86:
        case 87:
            if(th == 1){

            }
            else if(th == 2){
                HandleVarTypeDef(p);
            }
            else if(th == 3){

            }
            break;

    }
    for(int i = 0; i < p->right_num ; i++){
       ScanTree(th, p->psons[i]);
   }


}
