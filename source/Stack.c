#include "../include/Stack.h"


POSTK *initSTACK(int m)//初始化p指空栈：可存m个元素
{
    //TODO m 是否合法
    assert(m > 0);
    POSTK *p = (POSTK *)malloc(sizeof(POSTK));
    p->elems = (SYMB_ITEM **)malloc(sizeof(SYMB_ITEM*) * m);
    p->pos = 0;
    p->max = m;
    //TODO try-catch 分配失败
    if(p->elems == NULL)
        exit(-1);
    return p;
}

int  size (const POSTK *const p)	//返回p指的栈的最大元素个数max
{
    return p->max;
}
int  howMany (const POSTK *const p)	//返回p指的栈的实际元素个数pos
{
    return p->pos;
}
SYMB_ITEM *getelem (const POSTK *const p, int x)	//取下标x处的栈元素
{
    //TODO check x;

    return p->elems[x];
}

POSTK *push(POSTK *const p, SYMB_ITEM *e) 	//将e入栈，并返回p
{
    assert(p != NULL);
    //TODO stack is full
    assert(p->pos < p->max);
    p->elems[(p->pos)++] = e;
    return p;
}
SYMB_ITEM *pop(POSTK *const p)	//出栈到e，并返回p
{
    if(p->pos <= 0){
        #ifdef DEBUG
        printf("p->pos: %d\n", p->pos );

        #endif
        return NULL;
    }
    // assert(p->pos > 0);
    return p->elems[--(p->pos)];
}


void print(const POSTK*const p)			//打印p指向的栈元素
{
    printf("\n\n== Top  ==\n");
    for (int i = p->pos - 1; i >= 0; i--) {
        printf("Stack elem[%d]\t", i);
        for(SYMB_ITEM *ptemp = p->elems[i]->next; ptemp != NULL; ptemp = ptemp->next){
            printf("%s ;  ", ptemp->name);
        }
        printf("\n");
    }
    printf("== Down  ==\n");
}
void destroySTACK(POSTK*const p)		//销毁p指向的栈，释放
{
    free(p->elems);
    free(p);
}
