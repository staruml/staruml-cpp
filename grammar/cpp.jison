%token ABSTRACT ASSERT
%token BOOLEAN BREAK BYTE
%token CASE CATCH CHAR CLASS CONST CONTINUE
%token DEFAULT DO DOUBLE
%token ELSE ENUM EXTENDS
%token FINAL FINALLY FLOAT FOR
%token IF
%token GOTO
%token IMPLEMENTS IMPORT INSTANCEOF INT INTERFACE
%token LONG
%token NATIVE NEW
%token PACKAGE PRIVATE PROTECTED PUBLIC
%token RETURN
%token SHORT STATIC STRICTFP SUPER SWITCH SYNCHRONIZED
%token THIS THROW THROWS TRANSIENT TRY VOID VOLATILE WHILE

%token IntegerLiteral FloatingPointLiteral BooleanLiteral CharacterLiteral StringLiteral NullLiteral

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMI COMMA DOT

%token ASSIGN GT LSHIFT LT BANG TILDE QUESTION COLON EQUAL LE GE NOTEQUAL AND OR INC DEC ADD SUB MUL DIV BITAND BITOR CARET MOD
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN MOD_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN URSHIFT_ASSIGN

%token Identifier

%token TEMPLATE

%token EOF

%start compilationUnit

%%
compilationUnit
    : i assign expr EOF
        {
            return {
                "node":"compilationUnit",
                "var_name":$1,
                "op":$2,
                "exp":$3
            };
        }
    ;

i
    : Identifier
        {
            console.log('Var_name ' + $1);
        }
    ;
assign
    :   ASSIGN
        {
            console.log('Assign ' + $1);
        }
    |   ADD_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   SUB_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   MUL_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   AND_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   OR_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   XOR_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   MOD_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    |   LSHIFT_ASSIGN 
        {
            console.log('Assign ' + $1);
        }
    ;
expr
    :   number
    |   number operator number
    |   string
    |   string operator string
    ;

number
    :   IntegerLiteral 
    |   FloatingPointLiteral 
    ;
operator
    :   ADD
    |   SUB
    |   MUL
    |   DIV
    ;
string
    :   StringLiteral
    ;