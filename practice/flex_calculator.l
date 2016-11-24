%{
    #include "syntax.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
%}

%%
\d* {printf("find %d", atoi(yytext))}
%%
