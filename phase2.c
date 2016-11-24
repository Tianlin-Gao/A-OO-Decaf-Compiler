#include "user.h"

ClassNode *pClass;





void pr(char *str){
    printf("%s", str);
}
void prln(char *str){
    printf("%s\n", str);
}

ClassNode *NewClassNode(char *str){
    ClassNode *pnew = (ClassNode *)malloc(sizeof(ClassNode));
    assert(pnew != NULL);
    pnew->pfuncs = (FuncContainer *)malloc(sizeof(FuncContainer));
    pnew->pvars = (VarContainer *)malloc(sizeof(VarContainer));
    pnew->next = NULL;
    pnew->baseClass = NULL;
    pnew->baseClassName = NULL;
    // assert(str != NULL);
    if(str == NULL)
        prln("起始节点");
    pnew->str = str;

    return pnew;
}

void HandleClassDefNode(const NODE *p ){


    // pVar = pnew->pvars;
    // pFunc = pnew->pfuncs;
    ClassNode *pnew = NewClassNode(p->psons[1]->str);

    if(p->psons[2]->right_num == 2) //不是空节点,则将基类名保存,便于等下查找,否则为空
    {
        pnew->baseClassName = p->psons[2]->psons[1]->str;
    }

    /* 插入到链表尾部,因为最先遍历到的,在程序中先出现,所以按道理,应该排到前面 */
    ClassNode *ptemp;
    for(ptemp = pClass; ptemp->next != NULL; ptemp = ptemp->next){
    }
    ptemp->next = pnew; //此时在队尾

    pr("插入类: ");
    prln(pnew->str);

    // SecondScanTree(p->psons[4], pnew); //有些操作没什么好做的,往下传就好了

    //TODO 打印节点信息 PrintClassNodeInfo(pnew);

}

void FirstScanTree(const NODE *p){

    assert(p != NULL);
    switch(p->noderule){
        case 1:
            FirstScanTree(p->psons[0]);
            break;
        case 2: //ClassDefs 1
            FirstScanTree(p->psons[0]);
            break;
        case 3:  //ClassDefs 2
            FirstScanTree(p->psons[0]);
            FirstScanTree(p->psons[1]);
            break;

        case 4:
            HandleClassDefNode(p);
            break;
        default:
            printf("无用节点,返回\n" );
            break;
    }
    return;
}

void PrintClassNodeInfo(){

    prln("\n------------------\n");

    for(ClassNode *p = pClass->next; p != NULL; p = p->next){
        assert(p->str != NULL);
        printf("类名: %s\n", p->str);
        if(p->pfuncs){
            // PrintFuncNodeInfo();
        }
        if(p->pvars){
            // PrintVarNodeInfo();
        }
        if(p->baseClassName){
            printf("基类名: %s\n", p->baseClassName );
        }
        if(p->baseClass){
            printf("基类指针指向: %s\n", p->baseClass->str);
        }
        prln("\n------------------\n");
    }
}
