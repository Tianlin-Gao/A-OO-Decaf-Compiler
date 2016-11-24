#include <stdio.h>
// extern FILE* yyin;
// int yylex();
extern int yydebug;
int main(int argc, char const *argv[]) {
    if(argc <= 1){
        printf("缺少参数\n");
        return 0;
    }
    FILE *f;
    if(!(f = fopen(argv[1], "r"))){
        printf("%s无法打开\n", argv[1]);
        return 0;
    }
    yyrestart(f);
    // yydebug = 1;
    yyparse();

    // return yyparse();
    return 0;
}
