#include <stdio.h>
#include <stdlib.h>
#include "defs.h"
#include "assert.h"

#ifndef POP_STACK_POSTK_H
#define POP_STACK_POSTK_H


typedef struct _POSTK_ {
    SYMB_ITEM  **elems;	//申请内存用于存放栈的元素
    int   max;		//栈能存放的最大元素个数
    int   pos;		//栈实际已有元素个数，栈空时pos=0;
}POSTK;
POSTK * initSTACK(int m);//初始化p指空栈：可存m个元素
// void initSTACK(POSTK *const p, const POSTK&s); //用s初始化p指空栈
int  size (const POSTK *const p);	//返回p指的栈的最大元素个数max
int  howMany (const POSTK *const p);	//返回p指的栈的实际元素个数pos
SYMB_ITEM *getelem (const POSTK *const p, int x);	//取下标x处的栈元素
POSTK * push(POSTK *const p, SYMB_ITEM *e); 	//将e入栈，并返回p
SYMB_ITEM * pop(POSTK *const p);	//出栈到e，并返回p
// POSTK *const assign(POSTK*const p, const POSTK&s);//赋给p指栈,返回p
void print(const POSTK*const p);			//打印p指向的栈元素
void destroySTACK(POSTK*const p);		//销毁p指向的栈，释放


#endif //POP_STACK_POSTK_H
