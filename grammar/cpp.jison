
%token IDENTIFIER 

%token ABSTRACT AS  BOOL BREAK  CASE CATCH CHAR CHECKED CLASS CONST CONTINUE DECIMAL DEFAULT DELEGATE DO DOUBLE ELSE ENUM EXPLICIT EXTERN FALSE FINALLY FIXED FLOAT FOR FOREACH GOTO IF IMPLICIT   INT  INTERFACE INTERNAL IS  LONG NAMESPACE NEW NULL  OPERATOR  OVERRIDE PARAMS PRIVATE PROTECTED PUBLIC READONLY RETURN SBYTE SHORT SIZEOF STACKALLOC STATIC  STRUCT SWITCH THIS THROW TRUE TRY TYPEOF UINT ULONG UNCHECKED UNSAFE USHORT USING VIRTUAL VOID VOLATILE WHILE 

%token ASSEMBLY MODULE FIELD METHOD PARAM PROPERTY TYPE
 

%token ADD REMOVE

%token PARTIAL OP_DBLPTR

%token TEMPLATE

%token YIELD  ASYNC  AWAIT  WHERE

%token DELETE  FRIEND  TYPEDEF  AUTO   REGISTER   INLINE    SIGNED    UNSIGNED    UNION    ASM   DOTS   REF    

%token REAL_LITERAL
%token INTEGER_LITERAL   
%token STRING_LITERAL
%token CHARACTER_LITERAL

%token OPEN_BRACE CLOSE_BRACE OPEN_BRACKET CLOSE_BRACKET OPEN_PARENS CLOSE_PARENS DOT COMMA COLON SEMICOLON PLUS MINUS STAR DIV PERCENT AMP BITWISE_OR CARET BANG TILDE ASSIGN LT GT INTERR DOUBLE_COLON OP_COALESCING OP_INC OP_DEC OP_AND OP_OR OP_PTR OP_EQ OP_NE OP_LE OP_GE OP_ADD_ASSIGNMENT OP_SUB_ASSIGNMENT OP_MULT_ASSIGNMENT OP_DIV_ASSIGNMENT OP_MOD_ASSIGNMENT OP_AND_ASSIGNMENT OP_OR_ASSIGNMENT OP_XOR_ASSIGNMENT OP_LEFT_SHIFT OP_LEFT_SHIFT_ASSIGNMENT RIGHT_SHIFT RIGHT_SHIFT_ASSIGNMENT


%token EOF 
 

%start compilationUnit

%%

 
 
es
    :   es e 
    |    e 
    ;
    

e  
    :  declaration-statement
        {
            console.log('declaration-statement '+$1);
        }
    
    |   %empty             
        { 
            console.log('EMPTY');
        }
    ;
    
/* COLON IDENTIFIER */
COLON_IDENTIFIER
    :   COLON_IDENTIFIER COLON IDENTIFIER_WITH_TEMPLATE
    |   IDENTIFIER_WITH_TEMPLATE
    ;

/* Boolearn Literals */
BOOLEAN_LITERAL
    :   TRUE 
    |   FALSE
    ;
    

literal 
    :   BOOLEAN_LITERAL
    {
        $$ = $1;
    }
    |   REAL_LITERAL
    {
        $$ = $1;
    }
    |   INTEGER_LITERAL
    {
        $$ = $1;
    }
    |   STRING_LITERAL
    {
        $$ = $1;
    }
    |   CHARACTER_LITERAL
    {
        $$ = $1;
    }
    |   NULL
    {
        $$ = $1;
    }
    ;
 
/* C.2.1 Basic concepts */

namespace-name
    :   namespace-or-type-name
    {
        $$ = $1;
    }
    ;
    
type-name
    :   namespace-or-type-name
    {
        $$ = $1;
    }
    ;
    
namespace-or-type-name
    :   namespace-or-type-name   DOUBLE_COLON   STAR    IDENTIFIER_WITH_KEYWORD
    |   namespace-or-type-name   DOUBLE_COLON   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "::" + $3;
    }
    |   namespace-or-type-name   DOT   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "." + $3;
    }
    |   IDENTIFIER_WITH_KEYWORD   
    {
        $$ = $1;
    }
    ;
    
IDENTIFIER_WITH_TEMPLATE
    :   IDENTIFIER  TEMPLATE
    { 
    
        $$ = {
            "name": $1
        };
        
        $$["typeParameters"] = [];
        if ($2[0] === "<" && $2[$2.length-1] === ">") {
            var i, _temp, _param, _bounded;
            $2 = $2.substring(1, $2.length-1);
            _temp = $2.split(",");
            for (i = 0; i < _temp.length; i++) {
                _param = _temp[i].trim();
                 
                $$["typeParameters"].push({
                    "node": "TypeParameter",
                    "name": _param
                }); 
                 
            }
        }
    }
    |   IDENTIFIER
    {
        $$ = $1;
    }
    ;
 

/* C.2.2 Types */

STARS
    :   STARS   STAR
    {
        $$ = $1 + "" + $2;
    }
    |   STAR
    {
        $$ = $1;
    }
    ;

type 
    :   type    TEMPLATE 
    |   non-array-type    AMP
    {
        $$ = $1 + "" + $2;
    }
    |   array-type     AMP 
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type    STARS
    {
        $$ = $1 + "" + $2;
    }
    |   array-type     STARS 
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type    OP_AND
    {
        $$ = $1 + "" + $2;
    }
    |   array-type     OP_AND 
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type    CARET
    {
        $$ = $1 + "" + $2;
    }
    |   array-type     CARET 
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type  
    {
        $$ = $1;
    }
    |   array-type       
    {
        $$ = $1;
    }  
    |   type    STAR   AMP
    |   TYPEDEF 
    |   UNSIGNED  type
    |   UNSIGNED
    |   INLINE   
    |   INLINE   STRUCT  type
    |   type   CONST    STAR
    |   type   CONST    
    |   CONST   type  
    |   STATIC  type 
    |   VOLATILE  type
    |   VIRTUAL   type
    |   type    DOUBLE_COLON  STAR  type
    |   type   DOUBLE_COLON   type
    |   FRIEND    CLASS
    |   FRIEND    type
    ;
    
type-with-interr
    :   type     
    ;

non-array-type
    :   type-name
    |   SBYTE 
    |   SHORT
    |   USHORT 
    |   UINT
    |   LONG
    |   ULONG
    |   CHAR
    |   FLOAT
    |   DOUBLE
    |   DECIMAL
    |   BOOL    
    |   VOID 
    |   AUTO
    |   INT
    |   SHORT INT
    |   LONG  INT
    |   LONG  LONG
    |   LONG    DOUBLE
    |   SIGNED  INT
    |   SIGNED  CHAR
    |   SIGNED  LONG
    |   SIGNED  SHORT
    |   SIGNED  SHORT INT
    |   SIGNED  LONG  INT
    |   SIGNED  LONG  LONG
    |   SIGNED  IDENTIFIER
    |   UNSIGNED  INT
    |   UNSIGNED  CHAR
    |   UNSIGNED  LONG
    |   UNSIGNED  SHORT
    |   UNSIGNED  SHORT INT
    |   UNSIGNED  LONG  INT
    |   UNSIGNED  LONG  LONG
    ;
    
array-type
    :   type  local-rank-specifiers
    {
        $$ = $1 + "" + $2;
    }
    ;
     
    
rank-specifiers
    :   rank-specifiers    rank-specifier
    {
        $$ = $1 + "" + $2;
    }
    |  rank-specifier
    {
        $$ = $1;
    }
    ;
    
rank-specifier
    :   OPEN_BRACKET  dim-separators   CLOSE_BRACKET
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   OPEN_BRACKET  CLOSE_BRACKET
    {
        $$ = $1 + "" + $2;
    }
    ;
    
dim-separators
    :   dim-separators   COMMA
    {
        $$ = $1 + "" + $2;
    }
    |   COMMA
    {
        $$ = $1;
    }
    ;
 

/* C.2.3 Variables */
variable-reference
    :   expression
    {
        $$ = $1;
    }
    ;
    
    

/* C.2.4 Expressions */
argument-list
    :   argument-list   COLON   argument
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   argument-list   COMMA   STAR   argument
    |   argument-list   COMMA   argument
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   argument 
    {
        $$ = $1;
    }
    ;
    
argument
    :   CONST   STRUCT   expression
    |   STRUCT  expression
    |   expression
    {
        $$ = $1;
    }
    |   argument    local-rank-specifiers
    |   type
    ;
     

primary-expression
    :   primary-no-array-creation-expression
    {
        $$ = $1;
    }
    |   array-creation-expression
    {
        $$ = $1;
    }
    ;

primary-no-array-creation-expression
    :   lambda-expression
    |   cast-expression     
    {
        $$ = $1;
    }
    |   parenthesized-expression
    {
        $$ = $1;
    }
    |   double-colon-access
    {
        $$ = $1;
    }
    |   member-access
    {
        $$ = $1;
    }
    |   invocation-expressions
    {
        $$ = $1;
    }
    
    |   this-access
    {
        $$ = $1;
    } 
    |   post-increment-expression
    {
        $$ = $1;
    }
    |   post-decrement-expression
    {
        $$ = $1;
    } 
    |   object-creation-expression
    {
        $$ = $1;
    }
    |   typeof-expression
    {
        $$ = $1;
    }
    |   sizeof-expression
    {
        $$ = $1;
    }
    |   checked-expression
    {
        $$ = $1;
    }
    |   unchecked-expression
    {
        $$ = $1;
    }
    |   IDENTIFIER_WITH_KEYWORD   OP_DBLPTR   expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   IDENTIFIER_WITH_KEYWORD   OP_DBLPTR   block
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    
    |   DELEGATE block
    {
        $$ = $1 + "" + $2;
    }
    |   delegate-expression 
    {
        $$ = $1;
    }
    
    |   deallocation-expression 
    |   literal
    {
        $$ = $1;
    } 
    |   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1;
    }
    |   DOUBLE_COLON   STAR    IDENTIFIER_WITH_KEYWORD
    |   DOUBLE_COLON   IDENTIFIER_WITH_KEYWORD
    |   element-access
    {
        $$ = $1;
    }
    ;
 
 
    
type-expression-list
    :   type-expression-list  COMMA   type  expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    } 
    |   type    expression
    {
        $$ = $1 + "" + $2;
    } 
    ;
    
dbl-expression-list
    :   dbl-expression-list  COMMA   expression  expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   expression    expression
    {
        $$ = $1 + "" + $2;
    } 
    ;

lambda-expression
    :   lambda-introducer   lambda-declarator   OP_PTR   type    block
    |   lambda-introducer   lambda-declarator   OP_PTR   block
    |   lambda-introducer   lambda-declarator   block
    |   lambda-introducer   block
    |   lambda-introducer
    ;
    
lambda-introducer
    :   OPEN_BRACKET    lambda-capture    CLOSE_BRACKET
    |   OPEN_BRACKET    expression-list   CLOSE_BRACKET
    |   OPEN_BRACKET    dim-separators   CLOSE_BRACKET  
    |   OPEN_BRACKET    CLOSE_BRACKET
    ;

lambda-capture
    :   capture-default
    |   capture-list
    |   capture-default   COMMA    capture-list
    ;

capture-default
    :   AMP
    |   ASSIGN
    ;

capture-list
    :   capture-list    COMMA   capture
    |   capture 
    ;

capture
    :   THIS
    |   AMP   IDENTIFIER_WITH_KEYWORD
    |   IDENTIFIER_WITH_KEYWORD
    ;
    
lambda-declarator
    :   OPEN_PARENS    formal-parameter-list    CLOSE_PARENS
    |   OPEN_PARENS     CLOSE_PARENS
    ;

delegate-expression
    :   DELEGATE     OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   DELEGATE    OPEN_PARENS     CLOSE_PARENS        block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;
     
 
    
cast-expression
    :    OPEN_PARENS   STRUCT   expression   CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   OPEN_PARENS   STRUCT   type-with-interr     CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    } 
    |   OPEN_PARENS   expression   CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   OPEN_PARENS   type-with-interr     CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   OPEN_PARENS   expression-list   CLOSE_PARENS   expression
    |   OPEN_PARENS   expression-list   CLOSE_PARENS  
    |   type  cast-expression
    ;
     
    
parenthesized-expression
    :    OPEN_PARENS   expression    CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

double-colon-access
    :   IDENTIFIER_WITH_TEMPLATE  DOUBLE_COLON  primary-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   IDENTIFIER_WITH_TEMPLATE  DOUBLE_COLON  member-access
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

member-access
    :   invocation-expressions     DOT     IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   primary-expression   DOT   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   type   DOT   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    |   invocation-expressions     ptr-with-star     IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   primary-expression   ptr-with-star   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   type   ptr-with-star   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    
    ; 
    
ptr-with-star
    :   OP_PTR   STAR
    |   OP_PTR
    ;

keyword-invocation
    :   DEFAULT
    ;


invocation-expression
    :   DOUBLE_COLON    invocation-expression
    |   primary-expression   DOUBLE_COLON   invocation-expression
    |   primary-expression   OPEN_PARENS   type-name   CLOSE_PARENS   
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   primary-expression   OPEN_PARENS   type   CLOSE_PARENS   
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   primary-expression   OPEN_PARENS   argument-list   CLOSE_PARENS   
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   primary-expression   OPEN_PARENS   CLOSE_PARENS   
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   member-name-with-double-colon    OPEN_PARENS   type-name   CLOSE_PARENS   
    |   member-name-with-double-colon    OPEN_PARENS   type   CLOSE_PARENS   
    |   member-name-with-double-colon    OPEN_PARENS   argument-list   CLOSE_PARENS  
    |   member-name-with-double-colon    OPEN_PARENS   CLOSE_PARENS
    
    |   invocation-expression   assignment-operator   variable-initializer
    ;
    
element-access
    :   primary-no-array-creation-expression   OPEN_BRACKET   expression-list   CLOSE_BRACKET
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   primary-no-array-creation-expression   OPEN_BRACKET   dim-separators    CLOSE_BRACKET
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   primary-no-array-creation-expression   OPEN_BRACKET   CLOSE_BRACKET
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

expression-list
    :   STRUCT   expression
    |   expression
    {
        $$ = $1;
    }
    |   expression-list   COMMA   expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

this-access
    :   THIS
    ;
    

    
post-increment-expression
    :   primary-expression   OP_INC
    {
        $$ = $1 + "" + $2;
    }
    ;

post-decrement-expression
    :   primary-expression   OP_DEC
    {
        $$ = $1 + "" + $2;
    }
    ;
    
type-with-identifier
    :   OPEN_PARENS   type-with-identifier   CLOSE_PARENS   type-with-identifier
    |   OPEN_PARENS   type-with-identifier   CLOSE_PARENS  
    
    |   IDENTIFIER  TEMPLATE  
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type 
    {
        $$ = $1;
    }
    ;
    
new-unsigned
    :   NEW   UNSIGNED
    |   NEW   STRUCT
    |   REF   NEW
    |   NEW
    ;
    
object-creation-expression
    :   new-unsigned   type-with-identifier   OPEN_PARENS   argument-list    CLOSE_PARENS    invocation-expressions    IDENTIFIER_WITH_DOT      block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7 + "" + $8;
    }
    |   new-unsigned   type-with-identifier   OPEN_PARENS   argument-list    CLOSE_PARENS    invocation-expressions      IDENTIFIER_WITH_DOT
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   new-unsigned   type-with-identifier   OPEN_PARENS   CLOSE_PARENS      invocation-expressions     IDENTIFIER_WITH_DOT    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   new-unsigned   type-with-identifier   OPEN_PARENS   CLOSE_PARENS      invocation-expressions     IDENTIFIER_WITH_DOT 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   new-unsigned   type-with-identifier   OPEN_PARENS   CLOSE_PARENS     block-expression-with-brace
    { 
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   new-unsigned   type-with-identifier    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   new-unsigned   non-array-type   STAR   rank-specifiers
    |   new-unsigned   non-array-type   STAR   rank-specifiers     block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   new-unsigned   non-array-type   rank-specifiers
    |   new-unsigned   non-array-type   rank-specifiers     block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   new-unsigned   non-array-type   STAR    OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   new-unsigned   non-array-type   STAR    OPEN_BRACKET   argument-list   CLOSE_BRACKET    
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   new-unsigned   non-array-type   OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   new-unsigned   non-array-type   OPEN_BRACKET   argument-list   CLOSE_BRACKET    
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   new-unsigned   type-with-identifier   STAR    rank-specifiers    block-expression-with-brace 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   new-unsigned   type-with-identifier   STAR    OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   new-unsigned   type-with-identifier   STAR    OPEN_BRACKET   argument-list   CLOSE_BRACKET     
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    
    
    |   new-unsigned   type-with-identifier   rank-specifiers    block-expression-with-brace 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   new-unsigned   type-with-identifier   OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   new-unsigned   type-with-identifier   OPEN_BRACKET   argument-list   CLOSE_BRACKET     
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    
    
    |   new-unsigned   type-with-identifier
    |   new-unsigned   STAR    rank-specifiers   block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   new-unsigned   STAR    rank-specifiers     
    {
        $$ = $1 + " " + $2;
    }
    
    |   new-unsigned   rank-specifiers   block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   new-unsigned   rank-specifiers     
    {
        $$ = $1 + " " + $2;
    }
    
    
    |   new-unsigned   block-expression-with-brace
    {
        $$ = $1 + " " + $2;
    }
    ;
    
IDENTIFIER_WITH_DOT
    :   DOT    IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2;
    }
    |   %empty
    ;

argument-list-with-braces
    :   argument-list-with-braces   COMMA   argument-list-with-brace
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   argument-list-with-brace
    {
        $$ = $1;
    }
    ;
    
argument-list-with-brace
    :   OPEN_BRACE   argument-list   COMMA    CLOSE_BRACE
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   OPEN_BRACE   argument-list   CLOSE_BRACE
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   OPEN_BRACE   CLOSE_BRACE 
    {
        $$ = $1 + "" + $2;
    }
    ;



invocation-expressions
    :   invocation-expressions  DOT   invocation-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   invocation-expression
    {
        $$ = $1;
    }
    |   %empty
    ;

array-creation-expression
    :   STACKALLOC   non-array-type   OPEN_BRACKET   CLOSE_BRACKET     argument-list-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   STACKALLOC   non-array-type   OPEN_BRACKET   expression-list   CLOSE_BRACKET 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   STACKALLOC   non-array-type   OPEN_BRACKET   expression-list   CLOSE_BRACKET   rank-specifiers
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   STACKALLOC   non-array-type   OPEN_BRACKET   expression-list   CLOSE_BRACKET   array-initializer
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   STACKALLOC   non-array-type   OPEN_BRACKET   expression-list   CLOSE_BRACKET   rank-specifiers   array-initializer
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   STACKALLOC   array-type   array-initializer
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    ;
    
delegate-creation-expression
    :   NEW   type   OPEN_PARENS   argument-list   CLOSE_PARENS    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   NEW   type   OPEN_PARENS   argument-list   CLOSE_PARENS  
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   NEW   type   OPEN_PARENS   CLOSE_PARENS    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   NEW   type   OPEN_PARENS   CLOSE_PARENS  
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   NEW   type   block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   REF    delegate-creation-expression
    ;
    

typeof-expression
    :   TYPEOF   OPEN_PARENS   type-with-interr   CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;

sizeof-expression
    :   SIZEOF   OPEN_PARENS   STARS   type-with-interr   CLOSE_PARENS
    |   SIZEOF   OPEN_PARENS   STRUCT   type-with-interr   CLOSE_PARENS  
    |   SIZEOF   OPEN_PARENS   type-with-interr   CLOSE_PARENS  
    |   SIZEOF   type-with-interr
    ;


checked-expression
    :   CHECKED   OPEN_PARENS   expression   CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;

unchecked-expression
    :   UNCHECKED   OPEN_PARENS   expression   CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;

unary-expression
    :   pre-increment-expression
    {
        $$ = $1;
    }
    |   pre-decrement-expression
    {
        $$ = $1;
    }
    |   PLUS    unary-expression
    {
        $$ = $1 + "" + $2;
    }
    |   OP_COALESCING   unary-expression
    {
        $$ = $1 + "" + $2;
    }
    |   MINUS   unary-expression
    {
        $$ = $1 + "" + $2;
    }
    |   BANG    unary-expression
    {
        $$ = $1 + "" + $2;
    }
    |   TILDE   unary-expression
    {
        $$ = $1 + "" + $2;
    }
    |   STAR    unary-expression 
    {
        $$ = $1 + "" + $2;
    }
    |   CARET    unary-expression
    |   primary-expression  
    {
        $$ = $1;
    }
    ;

unary-or-cast-expression
    :   unary-expression
    |   OPEN_PARENS  type-name  CLOSE_PARENS  cast-expression
    ;

deallocation-expression
    :   DOUBLE_COLON     DELETE    unary-or-cast-expression
    |   DELETE      unary-or-cast-expression
    |   DOUBLE_COLON     DELETE   OPEN_BRACKET     CLOSE_BRACKET    unary-or-cast-expression
    |   DELETE     OPEN_BRACKET     CLOSE_BRACKET    unary-or-cast-expression
    ;

pre-increment-expression
    :   OP_INC   unary-expression
    {
        $$ = $1 + "" + $2;
    }
    ;

pre-decrement-expression
    :   OP_DEC   unary-expression
    {
        $$ = $1 + "" + $2;
    }
    ;

expression-with-comma
    :   expression-with-comma   COMMA    expression
    {
        $$ = $1 + "" + $3 + "" + $2;
    }
    |   expression
    {
        $$ = $1;
    }
    ;
 
 


multiplicative-expression
    :   unary-expression
    {
        $$ = $1;
    }
    |   multiplicative-expression   STAR        unary-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   multiplicative-expression   DIV         unary-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   multiplicative-expression   PERCENT     unary-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    ;
    
additive-expression
    :   multiplicative-expression
    {
        $$ = $1;
    }
    |   additive-expression   PLUS   multiplicative-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   additive-expression   OP_PTR   multiplicative-expression 
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   additive-expression   OP_COALESCING   multiplicative-expression                           
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   additive-expression   MINUS   multiplicative-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

shift-expression
    :   additive-expression 
    {
        $$ = $1;
    }
    |   shift-expression   OP_LEFT_SHIFT   additive-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   shift-expression   RIGHT_SHIFT   additive-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

relational-expression
    :   shift-expression
    {
        $$ = $1;
    }
    |   relational-expression   LT      shift-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   GT      shift-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   OP_LE   shift-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   OP_GE   shift-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   OP_COALESCING    shift-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   IS      type
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   relational-expression   AS      type
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

equality-expression
    :   relational-expression
    {
        $$ = $1;
    }
    |   equality-expression   OP_EQ   relational-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   equality-expression   OP_NE   relational-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

and-expression
    :   equality-expression
    {
        $$ = $1;
    }
    |   and-expression   AMP   equality-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

exclusive-or-expression
    :   and-expression
    {
        $$ = $1;
    }
    |   exclusive-or-expression   CARET   and-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

inclusive-or-expression
    :   exclusive-or-expression
    {
        $$ = $1;
    } 
    |   inclusive-or-expression   BITWISE_OR   exclusive-or-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

conditional-and-expression
    :   inclusive-or-expression
    {
        $$ = $1;
    } 
    |   conditional-and-expression   OP_AND   inclusive-or-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

conditional-or-expression
    :   conditional-and-expression
    {
        $$ = $1;
    } 
    |   conditional-or-expression   OP_OR   conditional-and-expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

conditional-expression
    :   conditional-or-expression
    {
        $$ = $1;
    } 
    |   conditional-or-expression   INTERR   expression    
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    |   conditional-or-expression   INTERR   expression   COLON   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    } 
    |   conditional-or-expression   INTERR   OPEN_PARENS   expression    CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3;
    }  
    |   conditional-or-expression   INTERR   OPEN_PARENS  expression     CLOSE_PARENS    COLON     expression  
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    } 
    |   conditional-or-expression   INTERR   OPEN_PARENS  expression     CLOSE_PARENS    COLON   OPEN_PARENS  expression       CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    } 
    ;
    
assignment
    :   unary-expression   assignment-operator   expression
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    |   unary-expression   assignment-operator   block-expression-with-brace
    {
        $$ = $1 + "" + $2 + "" + $3;
    }  
    ;

block-expression
    :   block-expression-with-brace
    {
        $$ = $1;
    }
    |   OPEN_BRACE     expression-list    CLOSE_BRACE
    {
        $$ = $1 + "" + $2 + "" + $3;
    } 
    ;
 
block-expression-list-unit
    :   block-expression-with-brace
    {
        $$ = $1;
    }
    |   expression
    {
        $$ = $1;
    }
    ;

block-expression-list
    :   block-expression-list   COMMA   block-expression-list-unit
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   block-expression-list-unit
    {
        $$ = $1;
    }
    ;

block-expression-with-brace
    :   OPEN_BRACE    block-expression-list    CLOSE_BRACE
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;
 
    
assignment-operator
    :   ASSIGN
    |   OP_ADD_ASSIGNMENT
    |   OP_SUB_ASSIGNMENT
    |   OP_MULT_ASSIGNMENT
    |   OP_DIV_ASSIGNMENT
    |   OP_MOD_ASSIGNMENT
    |   OP_AND_ASSIGNMENT
    |   OP_OR_ASSIGNMENT
    |   OP_XOR_ASSIGNMENT
    |   OP_LEFT_SHIFT_ASSIGNMENT
    |   RIGHT_SHIFT_ASSIGNMENT
    ;
    
expression
    :   conditional-expression
    {
        $$ = $1;
    } 
    |   assignment
    ;
    
constant-expression
    :   expression
    {
        $$ = $1;
    }
    ;
    
boolean-expression
    :   expression
    {
        $$ = $1;
    }
    ;



/* C.2.5 Statements */
statement
    :   labeled-statement
    |   declaration-statement
    |   embedded-statement  
    |   using-directive 
    ;
     
     
embedded-statement
    :   block
    |   empty-statement
    |   statement-expression block
    |   statement-expression SEMICOLON
    |   statement-expression    STAR   local-rank-specifiers  ASSIGN    variable-initializer    SEMICOLON
    |   statement-expression    STAR   local-rank-specifiers  SEMICOLON
    |   statement-expression    STAR   local-rank-specifiers  COMMA   local-variable-declarators   SEMICOLON
    |   statement-expression local-rank-specifiers  ASSIGN    variable-initializer    SEMICOLON
    |   statement-expression local-rank-specifiers  SEMICOLON
    |   statement-expression local-rank-specifiers  COMMA   local-variable-declarators   SEMICOLON
    |   selection-statement
    |   iteration-statement
    |   jump-statement
    |   try-statement
    |   checked-statement
    |   unchecked-statement 
    |   using-statement
    |   unsafe-statement
    |   fixed-statement   
    |   shift-expression  SEMICOLON 
    |   conditional-expression    SEMICOLON
    ;

   
fixed-statement
    :   modifiers   FIXED   OPEN_PARENS   type   local-variable-declarators   CLOSE_PARENS   embedded-statement
    |   FIXED   OPEN_PARENS   type   local-variable-declarators   CLOSE_PARENS   embedded-statement
    ;

unsafe-statement
    :   UNSAFE  block
    ;
    
block
    :   OPEN_BRACE   CLOSE_BRACE 
    |   OPEN_BRACE   statement-list   CLOSE_BRACE 
    ;

statement-list
    :   statement
    |   statement-list   statement
    ;

empty-statement
    :   SEMICOLON 
    ;

labeled-statement
    :   IDENTIFIER_WITH_KEYWORD   COLON   switch-labels
    |   IDENTIFIER_WITH_KEYWORD   COLON   statement 
    ;

declaration-statement
    :   local-variable-declaration   SEMICOLON
    |   local-constant-declaration   SEMICOLON
    |   local-variable-declaration   block
    |   local-constant-declaration   block
    |   local-variable-declaration 
    |   local-constant-declaration  
    |   class-declaration   
    ;
    
local-variable-declaration
    :   STATIC  CONST    STRUCT   struct-body    identifier-list    struct-bracket    
    |   STATIC  STRUCT  type  local-variable-declarators
    |   STRUCT  type  local-variable-declarators
    |   CONST   STRUCT  type  local-variable-declarators 
    |   ENUM    OPEN_BRACE   enum-member-declarations   COMMA    CLOSE_BRACE
    |   ENUM    OPEN_BRACE   enum-member-declarations   CLOSE_BRACE
    |   ENUM    type    local-variable-declarators
    |   fixed-parameter-prefix   type   local-variable-declarators 
    |   type   local-variable-declarators
    |   primary-expression   local-variable-declarators
    ;

local-variable-declarators
    :   local-variable-declarators   COMMA   STAR    local-variable-declarator   
    |   local-variable-declarators   COMMA   local-variable-declarator
    |   local-variable-declarator
    ;

local-rank-specifiers
    :   local-rank-specifiers    local-rank-specifier
    {
        $$ = $1 + "" + $2;
    }
    |  local-rank-specifier
    {
        $$ = $1;
    }
    ;
    
local-rank-specifier
    :   OPEN_BRACKET   expression-list   CLOSE_BRACKET
    |   OPEN_BRACKET  dim-separators   CLOSE_BRACKET 
    |   OPEN_BRACKET  CLOSE_BRACKET 
    ;

    
local-variable
    :   STARS   IDENTIFIER_WITH_KEYWORD 
    |   OP_AND  IDENTIFIER_WITH_KEYWORD
    |   AMP   IDENTIFIER_WITH_KEYWORD  
    |   CARET   IDENTIFIER_WITH_KEYWORD  
    |   IDENTIFIER_WITH_KEYWORD    local-rank-specifiers 
    |   IDENTIFIER_WITH_KEYWORD 
    |   %empty
    ;
    
local-variable-declarator
    :   local-variable    ASSIGN   local-variable-initializer
    |   local-variable 
    ;
    
local-variable-initializer
    :   expression
    |   array-initializer
    ;

local-constant-declaration
    :    type   constant-declarators
    ;
    
constant-declarators
    :   constant-declarator
    |   constant-declarators   COMMA   constant-declarator
    ;
    
constant-declarator
    :   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    ;
    
 
    
statement-expression
    :   object-creation-expression
    |   post-increment-expression
    |   post-decrement-expression
    |   pre-increment-expression
    |   pre-decrement-expression
    |   assignment 
    |   invocation-expressions
    ;
    
selection-statement
    :   if-statement
    |   switch-statement
    ;
    
if-statement
    :   IF   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-or-statement
    |   IF   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-or-statement   ELSE   embedded-statement
    |   ELSE    if-statement
    ;
    
boolean-expression
    :   expression 
    ;

switch-statement
    :   SWITCH   OPEN_PARENS   expression   CLOSE_PARENS   switch-block
    ;
    
switch-block
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   switch-sections   CLOSE_BRACE
    ;

switch-sections
    :   switch-sections   switch-section
    |   switch-section
    ;
    
switch-section
    :   switch-labels   statement-list
    ;
    
switch-labels
    :   switch-labels   switch-label
    |   switch-label
    ;
    
switch-label
    :   CASE   constant-expression   COLON
    |   DEFAULT   COLON     
    ;

iteration-statement
    :   while-statement
    |   do-statement
    |   for-statement 
    ;
    
embedded-or-statement
    :   statement
    |   embedded-statement
    ;
    
while-statement
    :   WHILE   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-or-statement
    ;
    
do-statement
    :   DO   embedded-or-statement   WHILE   OPEN_PARENS   boolean-expression   CLOSE_PARENS   SEMICOLON
    ;

for-statement
    :   FOR   OPEN_PARENS   SEMICOLON   SEMICOLON   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   SEMICOLON   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   SEMICOLON   for-condition   SEMICOLON   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   SEMICOLON   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   for-condition   SEMICOLON   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   SEMICOLON   for-condition   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   for-condition   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-or-statement
    |   FOR   OPEN_PARENS   for-initializer   COLON   expression   CLOSE_PARENS    embedded-or-statement
    ;

for-initializer
    :   local-variable-declaration
    |   statement-expression-list
    ;

for-condition
    :   boolean-expression
    ;
    
for-iterator
    :   statement-expression-list
    ;
    
statement-expression-list
    :   statement-expression
    |   statement-expression-list   COMMA   STAR   statement-expression
    |   statement-expression-list   COMMA   statement-expression
    ;
 
    
jump-statement
    :   break-statement
    |   continue-statement
    |   goto-statement
    |   return-statement
    |   throw-statement
    ;
    
break-statement
    :   YIELD   BREAK   SEMICOLON
    |   BREAK   SEMICOLON
    ;

continue-statement
    :   CONTINUE   SEMICOLON
    ;

goto-statement
    :   GOTO   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    |   GOTO   CASE   constant-expression   SEMICOLON
    |   GOTO   DEFAULT   SEMICOLON
    ;
    
return-statement
    :   YIELD    RETURN      block-expression-with-brace      SEMICOLON
    |   YIELD    RETURN    expression   SEMICOLON
    |   YIELD    RETURN    SEMICOLON
    |   RETURN   block-expression-with-brace  SEMICOLON
    |   RETURN   SEMICOLON
    |   RETURN   expression   SEMICOLON
    ;

throw-statement
    :   THROW   SEMICOLON
    |   THROW   expression   SEMICOLON
    ;
    
try-statement
    :   TRY   block   catch-clauses
    |   TRY   block   finally-clause
    |   TRY   block   catch-clauses   finally-clause
    ;

catch-clauses
    :   specific-catch-clauses
    |   general-catch-clause
    |   specific-catch-clauses   general-catch-clause
    ;

specific-catch-clauses
    :   specific-catch-clause
    |   specific-catch-clauses   specific-catch-clause
    ;

specific-catch-clause
    :   CATCH   OPEN_PARENS   type   CLOSE_PARENS   block
    |   CATCH   OPEN_PARENS   type   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS   block
    ;
    
general-catch-clause
    :   CATCH   block
    ;
    
finally-clause
    :   FINALLY   block
    ;
    
checked-statement
    :   CHECKED   block
    ;
    
unchecked-statement
    :   UNCHECKED   block
    ;
    
 
    
using-statement
    :   USING   OPEN_PARENS    resource-acquisition   CLOSE_PARENS    embedded-or-statement
    ;
    
resource-acquisition
    :   local-variable-declaration
    |   expression
    ;

 
 
/* C.2.9 Arrays */
 
array-initializer
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   variable-initializer-list   CLOSE_BRACE
    |   OPEN_BRACE   variable-initializer-list   COMMA   CLOSE_BRACE
    ;

variable-initializer-list
    :   variable-initializer
    |   variable-initializer-list   COMMA   STAR    variable-initializer
    |   variable-initializer-list   COMMA   variable-initializer
    ;

variable-initializer
    :   expression
    |   array-initializer
    ;


    
 

/* C.2.11 Enums */
enum-declaration
    :   enum-class   enum-body
    |   enum-class   enum-body    SEMICOLON
    |   modifiers  enum-class   enum-body
    |   modifiers  enum-class   enum-body  SEMICOLON
    |   enum-class   member-name-with-double-colon   SEMICOLON
    |   enum-class   member-name-with-double-colon   enum-body  
    |   modifiers   enum-class   member-name-with-double-colon   enum-body 
    |   enum-class   member-name-with-double-colon   enum-base   enum-body    
    |   enum-class   member-name-with-double-colon   enum-body   SEMICOLON  
    |   modifiers   enum-class   member-name-with-double-colon   enum-base   enum-body   
    |   modifiers   enum-class   member-name-with-double-colon   enum-body   SEMICOLON 
    |   enum-class   member-name-with-double-colon   enum-base   enum-body   SEMICOLON 
    |   modifiers   enum-class   member-name-with-double-colon   enum-base   enum-body   SEMICOLON   
    ;
    
enum-class
    :   ENUM    class-key
    |   ENUM
    ;

enum-base
    :   COLON   type-with-interr
    {
        $$ = $2;
    }
    ;
    
enum-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   enum-member-declarations   CLOSE_BRACE
    {
        $$ = $2;
    }
    |   OPEN_BRACE   enum-member-declarations   COMMA   CLOSE_BRACE
    {
        $$ = $2;
    }   
    |   enum-body    IDENTIFIER_WITH_KEYWORD
    ;

    
enum-member-declarations
    :   enum-member-declaration
    {
        $$ = [ $1 ];
    }
    |   enum-member-declarations   COMMA   enum-member-declaration
    {
        $1.push($3);
        $$ = $1;
    }
    ;
    
enum-member-declaration
    :   IDENTIFIER_WITH_TEMPLATE
    {
        $$ = {
            "name": $1
        };
    } 
    |   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    {
        $$ = {
            "name": $1,
            "value": $3
        };
    } 
    ;

 
struct-bracket
    :   local-rank-specifiers  ASSIGN    variable-initializer    
    ;

/* C.2.8 Structs */
struct-declaration 
    :   STRUCT   struct-body    SEMICOLON
    |   STRUCT   struct-body
    |   STRUCT   member-name-with-double-colon     OPEN_PARENS   CLOSE_PARENS    struct-method-body
    |   STRUCT   member-name-with-double-colon     OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    struct-method-body
    |   STRUCT   type   member-name-with-double-colon    OPEN_PARENS   CLOSE_PARENS        struct-method-body
    |   STRUCT   type   member-name-with-double-colon    OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    struct-method-body    
    |   STRUCT   member-name-with-double-colon   SEMICOLON
    |   STRUCT   type   member-name-with-double-colon   SEMICOLON
    |   STRUCT   member-name-with-double-colon    struct-body     
    |   STRUCT   member-name-with-double-colon     struct-body   SEMICOLON
    |   STRUCT   member-name-with-double-colon     struct-body   IDENTIFIER_WITH_TEMPLATE    struct-bracket   SEMICOLON
    |   STRUCT   member-name-with-double-colon     struct-body   IDENTIFIER_WITH_TEMPLATE    SEMICOLON
    |   STRUCT   member-name-with-double-colon   struct-interfaces    struct-body 
    |   STRUCT   member-name-with-double-colon   struct-interfaces    struct-body   SEMICOLON
    |   modifiers   STRUCT   struct-body
    |   modifiers   STRUCT   struct-body    IDENTIFIER_WITH_TEMPLATE    struct-bracket   SEMICOLON
    |   modifiers   STRUCT   struct-body    IDENTIFIER_WITH_TEMPLATE    SEMICOLON
    |   modifiers   STRUCT   member-name-with-double-colon   struct-body    IDENTIFIER_WITH_TEMPLATE    SEMICOLON
    |   modifiers   STRUCT   member-name-with-double-colon   SEIMCOLON
    |   modifiers   STRUCT   type   member-name-with-double-colon    SEMICOLON
    |   modifiers   STRUCT   member-name-with-double-colon      struct-body 
    |   modifiers   STRUCT   member-name-with-double-colon   struct-interfaces   struct-body
    |   modifiers   STRUCT   member-name-with-double-colon     struct-body   SEMICOLON
    |   modifiers   STRUCT   member-name-with-double-colon   struct-interfaces    struct-body   SEMICOLON
    |   modifiers   STRUCT   struct-body   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    |   modifiers   CONST    STRUCT   struct-body
    |   modifiers   CONST    STRUCT   struct-body    identifier-list    struct-bracket    SEMICOLON
    |   modifiers   CONST    STRUCT   struct-body    identifier-list    SEMICOLON
    |   modifiers   CONST    STRUCT   member-name-with-double-colon   struct-body    IDENTIFIER_WITH_TEMPLATE    SEMICOLON
    |   modifiers   CONST    STRUCT   member-name-with-double-colon   SEIMCOLON
    |   modifiers   CONST    STRUCT   type   member-name-with-double-colon    SEMICOLON
    |   modifiers   CONST    STRUCT   member-name-with-double-colon      struct-body 
    |   modifiers   CONST    STRUCT   member-name-with-double-colon   struct-interfaces   struct-body
    |   modifiers   CONST    STRUCT   member-name-with-double-colon     struct-body   SEMICOLON
    |   modifiers   CONST    STRUCT   member-name-with-double-colon   struct-interfaces    struct-body   SEMICOLON
    |   modifiers   CONST    STRUCT   struct-body   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    |   CONST   struct-declaration
    |   STRUCT  struct-body  IDENTIFIER_WITH_TEMPLATE  SEMICOLON
    ;
 
struct-method-body
    :   CONST  block
    |   block
    ;
 
struct-interfaces
    :   COLON   base-list
    {
        $$ = $2;
    }
    ;

struct-body
    :   OPEN_BRACE   struct-member-list   CLOSE_BRACE
    |   OPEN_BRACE   CLOSE_BRACE
    {
        $$ = $2;
    }
    ;
     
struct-member-list
    :   access-specifier    COLON   member-list
    |   access-specifier    COLON
    |   struct-member-declaration    member-list
    |   struct-member-declaration
    ;
 

struct-member-declarations
    :   struct-member-declaration
    {
        $$ = [ $1 ];
    }
    |   struct-member-declarations   struct-member-declaration
    {
        $1.push($2);
        $$ = $1;
    }
    ;
    
struct-member-declaration
    :   field-declaration
    {
        $$ = $1;
    }
    |   class-method-declaration
    {
        $$ = $1;
    }
    |   property-declaration
    {
        $$ = $1;
    }  
    |   operator-declaration
    {
        $$ = $1;
    }  
    |   type-declaration
    {
        $$ = $1;
    } 
    |   static-constructor-declaration
    {
        $$ = $1;
    }
    ;



/* C.2.6 Namespaces */
compilationUnit
    :   EOF
    |   block_or_statement_list       EOF
    ;

block_or_statement_list
    :   block_or_statement_list     block_or_statement
    |   block_or_statement
    ;
    
block_or_statement
    :   class-declaration
    |   method-declaration 
    |   class-member-declaration  
    |   namespace-declaration
    |   struct-declaration 
    |   enum-declaration
    |   extern-declaration
    ;

extern-declaration
    :   EXTERN  STRING_LITERAL  OPEN_BRACE    block_or_statement_list    CLOSE_BRACE 
    |   EXTERN  STRING_LITERAL  OPEN_BRACE    CLOSE_BRACE
    |   EXTERN  STRUCT   class-method-declaration
    |   EXTERN  class-method-declaration
    ;

namespace-declaration
    :   NAMESPACE   namespace-or-type-name   OPEN_BRACE    block_or_statement_list    CLOSE_BRACE 
    |   NAMESPACE   namespace-or-type-name   OPEN_BRACE   CLOSE_BRACE
    |   NAMESPACE   INTERNAL   OPEN_BRACE    block_or_statement_list    CLOSE_BRACE 
    |   NAMESPACE   INTERNAL   OPEN_BRACE   CLOSE_BRACE
    |   NAMESPACE   OPEN_BRACE    block_or_statement_list    CLOSE_BRACE 
    |   NAMESPACE   OPEN_BRACE    CLOSE_BRACE 
    |   namespace-declaration    SEMICOLON
    ;
 

namespace-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   using-directives   CLOSE_BRACE
    {
        $$ = $2;
    }
    |   OPEN_BRACE   namespace-member-declarations   CLOSE_BRACE
    {
        $$ = $2;
        
    }
    |   OPEN_BRACE   using-directives   namespace-member-declarations   CLOSE_BRACE
    {
        
        $$ = $2.concat($3);
    }   
    ;

using-directives
    :   using-directive
    {
        $$ = [ $1 ];
    }
    |   using-directives   using-directive
    {
        $1.push($2);
        $$ = $1;
    }
    ;

using-directive
    :   using-alias-directive
    {
        $$ = $1;
    }
    |   using-namespace-directive
    {
        $$ = $1;
    }
    ;

using-alias-directive
    :   USING   NAMESPACE   IDENTIFIER_WITH_TEMPLATE   ASSIGN   namespace-or-type-name   SEMICOLON
    {
        $$ = {
            "node" : "using",
            "qualifiedName" : $4
        };
    }
    |   USING   IDENTIFIER_WITH_TEMPLATE   ASSIGN   namespace-or-type-name   SEMICOLON
    {
        $$ = {
            "node" : "using",
            "qualifiedName" : $4
        };
    }
    ;

using-namespace-directive
    :   USING   NAMESPACE   namespace-name   SEMICOLON
    {
        $$ = {
            "node" : "using",
            "qualifiedName" : $2
        };
    }
    |   USING   namespace-name   SEMICOLON
    {
        $$ = {
            "node" : "using",
            "qualifiedName" : $2
        };
    }
    ;

namespace-member-declarations
    :   namespace-member-declaration
    {
        $$ = [ $1 ];
    }
    |   namespace-member-declarations   namespace-member-declaration
    {
        $1.push($2);
        $$ = $1;
    }
    ;
    
namespace-member-declaration
    :   namespace-declaration
    {
        $$ = $1;
    }
    |   type-declaration
    {
        $$ = $1;
    }
    ;

type-declaration
    :   struct-declaration
    {
        $$ = $1;
    } 
    |   enum-declaration
    {
        $$ = $1;
    } 
    ;


/* Modifier */ 

 
modifier
    :   UNSAFE 
    |   ASYNC
    |   PUBLIC
    |   PARTIAL
    |   PROTECTED 
    |   INTERNAL
    |   PRIVATE
    |   ABSTRACT 
    |   STATIC
    |   READONLY
    |   VOLATILE 
    |   VIRTUAL   
    |   OVERRIDE   
    |   IDENTIFIER   STATIC
    |   TYPEDEF 
    |   EXPLICIT
    |   IMPLICIT
    ;

modifiers
    :   modifier
    {
        $$ = [ $1 ];
    }
    |   modifiers   modifier
    {
        $1.push($2);
        $$ = $1;
    }
    ;

/* C.2.7 Classes */

class-key
    :   FRIEND  CLASS
    |   PUBLIC  REF     CLASS
    |   REF     CLASS
    |   CLASS
    |   UNION
    ; 
    
class-declaration 
    :   class-key   class-body      identifier-list     SEMICOLON
    |   class-key   class-body      SEMICOLON
    |   class-key   identifier-list   class-suffix      identifier-list     SEMICOLON
    |   class-key   identifier-list   class-suffix      SEMICOLON
    |   class-key   identifier-list   class-suffix      class-body  
    |   class-key   identifier-list   class-suffix      class-base      class-body   
    |   class-key   identifier-list   class-suffix      class-body      identifier-list     SEMICOLON  
    |   class-key   identifier-list   class-suffix      class-body      SEMICOLON  
    |   class-key   identifier-list   class-suffix      class-base      class-body   identifier-list    SEMICOLON  
    |   class-key   identifier-list   class-suffix      class-base      class-body   SEMICOLON   
    ;



identifier-list
    :   identifier-list    DOUBLE_COLON   IDENTIFIER_WITH_TEMPLATE
    |   identifier-list    IDENTIFIER_WITH_TEMPLATE
    |   IDENTIFIER_WITH_TEMPLATE
    ;

class-suffix
    :   ABSTRACT
    |   %empty
    ;
    
class-base
    :   COLON   base-list
    ;

base-list
    :   base-list   COMMA    base-specifier
    |   base-specifier
    ;    

base-specifier
    :   type-with-interr
    |   VIRTUAL     access-specifier    type-with-interr
    |   VIRTUAL     type-with-interr
    |   access-specifier    VIRTUAL     type-with-interr
    |   access-specifier    type-with-interr
    ;
    
access-specifier
    :   PRIVATE
    |   PROTECTED
    |   PUBLIC
    |   INTERNAL
    |   PROTECTED  PRIVATE 
    |   type  
    ;
     

class-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   member-list   CLOSE_BRACE 
    ;

member-list
    :   access-specifier    access-specifier    COLON   member-list
    |   access-specifier    access-specifier    COLON
    |   access-specifier    COLON   member-list
    |   access-specifier    COLON
    |   class-member-declaration    member-list
    |   class-member-declaration
    ;

class-member-declarations
    :   class-member-declaration
    {
        $$ = [ $1 ];
    }
    |   class-member-declarations   class-member-declaration
    {
        $1.push($2);
        $$ = $1;
    }
    ;

class-member-declaration
    :   operator-declaration
    {
        $$ = $1;
    }  
    |   class-method-declaration
    {
        $$ = $1;
    }
    |   field-declaration 
    {
        $$ = $1;
    }
    |   property-declaration
    {
        $$ = $1;
    }  
    
    |   destructor-declaration
    {
        $$ = $1;
    }
    |   type-declaration
    {
        $$ = $1;
    }
    |   using-directive
    |   constant-declaration
    |   FRIEND   CLASS   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    |   class-declaration
    |   struct-declaration
    |   enum-declaration
    |   static-constructor-declaration
    {
        $$ = $1;
    }
    ;


constant-declaration
    :   type-with-interr   constant-declarators   SEMICOLON  
    |   modifiers   type-with-interr   constant-declarators   SEMICOLON  
    ;
 
constant-declarators
    :   constant-declarator 
    |   constant-declarators   COMMA   STAR    constant-declarator 
    |   constant-declarators   COMMA   constant-declarator 
    ;

constant-declarator
    :   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression 
    |   IDENTIFIER_WITH_TEMPLATE
    ;

field-declaration
    :   field-variable-declarators   SEMICOLON  
    |   modifiers    field-variable-declarators   SEMICOLON    
    |   field-variable-declarators     function-pointer     SEMICOLON
    |   modifiers    field-variable-declarators     function-pointer    SEMICOLON
    |   field-variable-declarators     function-pointer       static-constructor-parameter
    |   modifiers    field-variable-declarators     function-pointer       static-constructor-parameter
    ;
    
function-pointer
    :   OPEN_PARENS   STAR    member-name-with-double-colon-star    CLOSE_PARENS
    |   OPEN_PARENS   member-name-with-double-colon-star    CLOSE_PARENS    
    |   OPEN_PARENS   CLOSE_PARENS   
    ;  

field-variable-declarators
    :   field-variable-declarators   COMMA   STAR    field-variable-declarator 
    |   field-variable-declarators   COMMA   field-variable-declarator 
    |   field-variable-declarator 
    ;

field-variable-declarator
    :   member-name-with-double-colon      ASSIGN     variable-initializer 
    |   member-name-with-double-colon   
    ;


variable-declarators
    :   variable-declarators   COMMA   STAR    variable-declarator 
    |   variable-declarators   COMMA   variable-declarator 
    |   variable-declarator 
    ;

variable-declarator
    :   type      ASSIGN   variable-initializer 
    |   type     
    ;

variable-initializer
    :   expression 
    |   array-initializer 
    ;


method-declaration
    :   method-header   method-prefixs      ctor-initializer   block  
    |   method-header   ctor-initializer    block  
    |   method-header   method-prefixs      block  
    |   method-header   block 
    ;
    
ctor-initializer
    :   COLON    mem-initializer-list
    ;

mem-initializer-list
    :   mem-initializer    COMMA    mem-initializer-list
    |   mem-initializer
    ;

mem-initializer
    :   type     OPEN_PARENS     member-name-with-double-colon-list     CLOSE_PARENS
    |   type     OPEN_PARENS     argument-list   CLOSE_PARENS
    |   type     OPEN_PARENS     CLOSE_PARENS 
    ;    

member-name-with-double-colon-list
    :   member-name-with-double-colon-list    COMMA    member-name-with-double-colon
    |   member-name-with-double-colon-literal 
    ;
    
member-name-with-double-colon-literal
    :   STRUCT   expression
    |`  expression
    |   member-name-with-double-colon-literal   local-rank-specifiers
    ; 
    
class-method-declaration
    :   class-method-header   method-prefixs   block   SEMICOLON 
    |   class-method-header   method-prefixs   ctor-initializer   block     SEMICOLON
    |   class-method-header   method-prefixs   ctor-initializer   block
    |   class-method-header   method-prefixs   block
    |   class-method-header   method-prefixs   SEMICOLON
    |   class-method-header   method-prefixs   
    |   class-method-header   IDENTIFIER_WITH_KEYWORD   block   SEMICOLON 
    |   class-method-header   block   SEMICOLON 
    |   class-method-header   ctor-initializer    block    SEMICOLON
    |   class-method-header   ctor-initializer    block
    |   class-method-header   IDENTIFIER_WITH_KEYWORD   block
    |   class-method-header   block
    |   class-method-header   IDENTIFIER_WITH_KEYWORD   OPEN_PARENS   argument-list    CLOSE_PARENS     SEMICOLON 
    |   class-method-header   IDENTIFIER_WITH_KEYWORD   SEMICOLON 
    |   class-method-header   SEMICOLON 
    |   class-method-header    
    ;

method-prefixs
    :   method-prefixs  method-prefix
    |   method-prefix
    ;

method-prefix
    :   CONST   type
    |   CONST
    |   OVERRIDE
    ;
    

class-method-header  
    :   member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    class-method-header
    |   member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS     class-method-header      
    |   member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   
    |   member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS     
    |   type   member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS     
    |   type   member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS         
    |   type   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    class-method-header
    |   type   OPEN_PARENS   CLOSE_PARENS    class-method-header
    |   type   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS        
    |   type   OPEN_PARENS   CLOSE_PARENS 
    |   modifiers   type   function-pointer   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS
    |   modifiers   type   function-pointer   OPEN_PARENS   CLOSE_PARENS
    |   modifiers   type    member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS
    |   modifiers   type   member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS     
    |   modifiers    member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS
    |   modifiers    member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS       
    |   member-name-with-double-colon 
    |   class-method-header    ASSIGN   variable-initializer  
    |   class-method-header    CONST    ASSIGN   variable-initializer  
    ; 

method-header  
    :   method-types   member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS       
    |   method-types   member-name-with-double-colon   OPEN_PARENS    CLOSE_PARENS   
    |   member-name-with-double-colon   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS      
    |   member-name-with-double-colon   OPEN_PARENS   CLOSE_PARENS        
    ;
     

method-types
    :   method-types  method-type
    |   method-type
    ;

method-type
    :   type      
    ;     
     
member-name-with-double-colon-star
    :   type    STAR   member-name-with-double-colon-star  
    |   type    member-name-with-double-colon-star  
    |   member-name-with-double-colon-star   member-name     DOUBLE_COLON    STAR    member-name
    |   member-name-with-double-colon-star   member-name     DOUBLE_COLON    TILDE    member-name
    |   member-name-with-double-colon-star   member-name     DOUBLE_COLON   member-name
    |   member-name-with-double-colon-star   COMMA   STAR   member-name
    |   member-name-with-double-colon-star   COMMA   member-name
    |   member-name-with-double-colon-star   STAR    member-name
    |   member-name-with-double-colon-star   member-name
    |   type    STAR
    |   type
    ;     
     
member-name-with-double-colon
    :   type    member-name-with-double-colon  
    |   member-name-with-double-colon   member-name     DOUBLE_COLON    STAR    member-name
    |   member-name-with-double-colon   member-name     DOUBLE_COLON    TILDE    member-name
    |   member-name-with-double-colon   member-name     DOUBLE_COLON   member-name
    |   member-name-with-double-colon   COMMA   STAR   member-name
    |   member-name-with-double-colon   COMMA   member-name
    |   member-name-with-double-colon   member-name
    |   type
    ;
     
member-name
    :   variable-declarators 
    {
        $$ = $1;
    }
    ;
 

method-body
    :   block   SEMICOLON
    |   block
    |   SEMICOLON
    ;

formal-parameter-list
    :   fixed-parameters 
    |   fixed-parameters   COMMA   STAR    parameter-array 
    |   fixed-parameters   COMMA   parameter-array 
    |   parameter-array 
    ;

fixed-parameters
    :   fixed-parameters   COMMA   STAR   fixed-parameter  
    |   fixed-parameters   COMMA   fixed-parameter 
    |   fixed-parameter
    ;

IDENTIFIER_WITH_KEYWORD
    :   TILDE   IDENTIFIER_WITH_KEYWORD  
    |   IDENTIFIER_WITH_TEMPLATE
    |   ADD
    |   REMOVE
    |   SET
    |   PARAMS
    |   DEFAULT
    |   METHOD
    |   PARAM
    |   ASSEMBLY  
    |   PROPERTY
    |   MODULE 
    |   FIELD 
    |   TYPE
    |   THIS
    |   ASYNC
    |   VOLATILE 
    |   DOTS   
    |   DELEGATE
    |   OPERATOR    overloadable-operator
    |   OPERATOR
    |   REF
    |   literal
    ;

fixed-parameter
    :   type-with-interr   function-pointer     OPEN_PARENS   formal-parameter-list    CLOSE_PARENS
    |   type-with-interr   function-pointer     OPEN_PARENS     CLOSE_PARENS
    |   type-with-interr   IDENTIFIER_WITH_KEYWORD     ASSIGN     expression   
    |   CONST    STRUCT   type-with-interr   IDENTIFIER_WITH_KEYWORD  
    |   STRUCT   type-with-interr   IDENTIFIER_WITH_KEYWORD  
    |   STRUCT   type-with-interr   
    |   CONST    ENUM   type-with-interr   IDENTIFIER_WITH_KEYWORD  
    |   ENUM   type-with-interr   IDENTIFIER_WITH_KEYWORD  
    |   ENUM   type-with-interr  
    |   type-with-interr   AMP   IDENTIFIER_WITH_KEYWORD  
    |   type-with-interr   IDENTIFIER_WITH_KEYWORD  
    |   type-with-interr   
    |   fixed-parameter-prefix   type-with-interr   IDENTIFIER_WITH_KEYWORD  ASSIGN   expression  
    |   fixed-parameter-prefix   type-with-interr   IDENTIFIER_WITH_KEYWORD     
    |   THIS    type-with-interr    IDENTIFIER_WITH_KEYWORD  
    |   fixed-parameter    local-rank-specifiers
    ;

fixed-parameter-prefix
    :   UNSIGNED
    ;

 

parameter-array
    :   PARAMS   array-type   IDENTIFIER_WITH_TEMPLATE 
    |   attributes   PARAMS   array-type   IDENTIFIER_WITH_TEMPLATE 
    ;


property-declaration
    :   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE  
    |   modifiers   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE  
    ;
 
 
  
operator-declaration
    :   modifiers   operator-declarator   method-body 
    |   attributes   modifiers   operator-declarator   method-body  
    ;
 

operator-declarator
    :   unary-operator-declarator
    |   binary-operator-declarator  
    ;

unary-operator-declarator
    :   type-with-interr   OPERATOR   overloadable-operator   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS 
    ;

overloadable-operator
    :   overloadable-unary-operator 
    |   overloadable-binary-operator 
    ;
    

overloadable-unary-operator
    :   OP_INC
    |   OP_DEC
    |   MINUS
    |   BANG
    |   TILDE
    |   PLUS
    |   TRUE
    |   FALSE
    ;
    
binary-operator-declarator
    :   type-with-interr   OPERATOR   overloadable-operator   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_TEMPLATE   COMMA   type-with-interr   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS 
    ;

overloadable-binary-operator
    :   PLUS
    |   MINUS
    |   STAR
    |   DIV
    |   PERCENT
    |   AMP
    |   BITWISE_OR
    |   CARET
    |   OP_LEFT_SHIFT
    |   RIGHT_SHIFT
    |   OP_EQ
    |   OP_NE
    |   OP_GE
    |   OP_LE
    |   OP_PTR 
    |   OP_INC
    |   OP_DEC
    |   OP_ADD_ASSIGNMENT
    |   OP_SUB_ASSIGNMENT
    |   OP_MULT_ASSIGNMENT
    |   OP_DIV_ASSIGNMENT
    |   OP_MOD_ASSIGNMENT
    |   OP_AND_ASSIGNMENT
    |   OP_OR_ASSIGNMENT
    |   OP_XOR_ASSIGNMENT
    |   GT
    |   LT
    |   ASSIGN
    |   OPEN_PARENS    CLOSE_PARENS
    ;
 

constructor-declaration
    :   constructor-declarator   SEMICOLON
    |   constructor-declarator   method-body  
    |   modifiers   constructor-declarator   method-body  
    ;
 
constructor-declarator
    :   type   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    ctor-initializer 
    |   type   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   
    |   type   OPEN_PARENS   member-name-with-double-colon-list   CLOSE_PARENS   ctor-initializer 
    |   type   OPEN_PARENS   member-name-with-double-colon-list   CLOSE_PARENS 
    |   type   OPEN_PARENS   CLOSE_PARENS   ctor-initializer 
    |   type   OPEN_PARENS   CLOSE_PARENS 
    ;
 


static-constructor-declaration
    :   modifiers   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   STAR    member-name-with-double-colon    CLOSE_PARENS  
    |   modifiers   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   member-name-with-double-colon    CLOSE_PARENS    
    |   modifiers   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS   
    |   static-constructor-declaration    static-constructor-parameter
    |   static-constructor-declaration    ctor-initializer    method-body
    ;
 
    

static-constructor-parameter
    :   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    method-body  
    |   OPEN_PARENS   CLOSE_PARENS    method-body  
    |   method-body
    ;
 

destructor-declaration
    :   modifiers   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS    formal-parameter-list   CLOSE_PARENS    destructor-method-body  
    |   modifiers   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS    formal-parameter-list   CLOSE_PARENS    destructor-method-body  
    |   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS    formal-parameter-list   CLOSE_PARENS    destructor-method-body  
    |   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS    formal-parameter-list   CLOSE_PARENS    destructor-method-body  
    |   modifiers   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    destructor-method-body  
    |   modifiers   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    destructor-method-body  
    |   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    destructor-method-body  
    |   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    destructor-method-body  
    ;
 
 destructor-method-body
    :   method-body
    |   ASSIGN   variable-initializer   SEMICOLON
    ;
 
 
