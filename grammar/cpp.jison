%token VITRUAL STATIC CONST STRUCT CLASS
%token BOOL INT LONG DOUBLE FLOAT CHAR VOID
%token LPAREN RPAREN LBRACE RBRACE

%start compilationUnit

%%
compilationUnit
    :   CLASS CppLetter LBRACE RBRACE
        {
            return {
                "class-name" : $2
            }
        }
    |  commentReturn CLASS CppLetter LBRACE RBRACE
        {
            return {
                "comment" : $1,
                "class-name" : $2
            }
        }
    ;
    
commentReturn
    :   %empty
        {
            $$ = yy.__currentComment;
            yy.__currentComment = null;
        }
    ;
