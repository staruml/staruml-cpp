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

/* literal */
%token IntegerLiteral FloatingLiteral BooleanLiteral CharacterLiteral StringLiteral NullLiteral PointerLiteral

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMI COMMA DOT

%token ASSIGN GT LSHIFT LT BANG TILDE QUESTION COLON EQUAL LE GE NOTEQUAL AND OR INC DEC ADD SUB MUL DIV BITAND BITOR CARET MOD
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN MOD_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN URSHIFT_ASSIGN

%token Identifier

%token TEMPLATE

%token EOF

%start compilationUnit

%%
compilationUnit : simple-expression EOF
    | simple-expression simple-expression EOF
    | simple-expression simple-expression simple-expression EOF
    ;


/* lex.literal.kinds */
literal : IntegerLiteral
    |FloatingLiteral
    |BooleanLiteral
    |CharacterLiteral
    |StringLiteral
    |NullLiteral
    |PointerLiteral
    ;
    
    
    
/* expr.prim.general */    
    
    
    
    
    
    
    
    
    
    
    
    
    
simple-expression : type var_name assign expr SEMI{
        console.log($4);
    };
    
type : Identifier {
        console.log($1);
    }| INT {
        console.log($1);
    }| DOUBLE {
        console.log($1);
    }| BOOLEAN {
        console.log($1);
    };
    
var_name : Identifier {
        console.log($1);
    };
    
assign : ASSIGN 
    | ADD_ASSIGN 
    | SUB_ASSIGN
    | MUL_ASSIGN 
    | AND_ASSIGN 
    | OR_ASSIGN 
    | XOR_ASSIGN 
    | MOD_ASSIGN 
    | LSHIFT_ASSIGN 
    ;
expr
    :   number
    |   number operator number{
        $$ = $1;
        $$ += $2;
        $$ += $3;
    }|   string
    |   string operator string{
        $$ = $1;
        $$ += $2;
        $$ += $3;
    };

number
    :   IntegerLiteral 
    |   FloatingLiteral 
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