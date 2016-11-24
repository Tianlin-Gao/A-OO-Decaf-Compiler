#include <stdio.h>
extern FILE* yyin;
int yylex();
int main(int argc, char const *argv[]) {
    if(argc <= 1){
        printf("缺少参数\n");
        return 0;
    }
    if(!(yyin = fopen(argv[1], "r"))){
        printf("%s无法打开\n", argv[1]);
        return 0;
    }
    while(yylex() != 0);

    return 0;
}
