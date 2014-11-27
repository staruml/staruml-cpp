
%token IDENTIFIER 

%token ABSTRACT AS BASE BOOL BREAK BYTE CASE CATCH CHAR CHECKED CLASS CONST CONTINUE DECIMAL DEFAULT DELEGATE DO DOUBLE ELSE ENUM EVENT EXPLICIT EXTERN FALSE FINALLY FIXED FLOAT FOR FOREACH GOTO IF IMPLICIT IN INT INTERFACE INTERNAL IS LOCK LONG NAMESPACE NEW NULL OBJECT OPERATOR OUT OVERRIDE PARAMS PRIVATE PROTECTED PUBLIC READONLY REF RETURN SBYTE SEALED SHORT SIZEOF STACKALLOC STATIC STRING STRUCT SWITCH THIS THROW TRUE TRY TYPEOF UINT ULONG UNCHECKED UNSAFE USHORT USING VIRTUAL VOID VOLATILE WHILE 

%token ASSEMBLY MODULE FIELD METHOD PARAM PROPERTY TYPE

%token GET SET

%token ADD REMOVE

%token PARTIAL OP_DBLPTR

%token TEMPLATE

%token YIELD  ASYNC  AWAIT  WHERE

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
    :   namespace-or-type-name   DOUBLE_COLON   IDENTIFIER_WITH_KEYWORD
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

EMPTY_TEMPLATE
    :   LT     GT
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
    :   non-array-type    STARS
    {
        $$ = $1 + "" + $2;
    }
    |   array-type     STARS 
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
    ;
    
type-with-interr
    :   type    INTERR
    {
        $$ = $1 + "" + $2;
    }
    |   type
    {
        $$ = $1;
    }
    ;

non-array-type
    :   type-name
    |   SBYTE
    |   BYTE
    |   SHORT
    |   USHORT
    |   INT
    |   UINT
    |   LONG
    |   ULONG
    |   CHAR
    |   FLOAT
    |   DOUBLE
    |   DECIMAL
    |   BOOL 
    |   OBJECT
    |   STRING  
    |   VOID 
    ;
    
array-type
    :   type  rank-specifiers
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
    :   expression
    {
        $$ = $1;
    }
    |   REF  variable-reference
    {
        $$ = $1 + " " + $2;
    }
    |   OUT  variable-reference
    {
        $$ = $1 + " " + $2;
    }
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
    :   literal
    {
        $$ = $1;
    }
    |   lambda-expression
    {
        $$ = $1;
    }
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
    |   element-access
    {
        $$ = $1;
    }
    |   this-access
    {
        $$ = $1;
    }
    |   base-access
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
    |   delegate-creation-expression
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
    |   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1;
    }
    |   DELEGATE block
    {
        $$ = $1 + "" + $2;
    }
    |   delegate-expression 
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
    :   OPEN_PARENS   dbl-expression-list   CLOSE_PARENS  OP_DBLPTR     expression 
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   dbl-expression-list   CLOSE_PARENS  OP_DBLPTR     block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   type-expression-list   CLOSE_PARENS  OP_DBLPTR     expression 
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   type-expression-list   CLOSE_PARENS  OP_DBLPTR     block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   expression-list   CLOSE_PARENS  OP_DBLPTR     expression 
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   expression-list   CLOSE_PARENS  OP_DBLPTR     block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
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
    :   OPEN_PARENS   type  expression   CLOSE_PARENS   OP_DBLPTR   expression    block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   OPEN_PARENS   expression   CLOSE_PARENS   OP_DBLPTR   expression    block
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   OPEN_PARENS   expression   CLOSE_PARENS   OP_DBLPTR   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   OPEN_PARENS   expression   CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    |   OPEN_PARENS   type-with-interr     CLOSE_PARENS   expression
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;
    
parenthesized-expression
    :    OPEN_PARENS   expression    CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ;

double-colon-access
    :   IDENTIFIER_WITH_TEMPLATE  DOUBLE_COLON  member-access
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
    |   invocation-expressions     OP_PTR     IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   primary-expression   OP_PTR   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   type   OP_PTR   IDENTIFIER_WITH_KEYWORD
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    ; 

keyword-invocation
    :   DEFAULT
    ;


invocation-expression
    :   AWAIT   primary-expression   OPEN_PARENS   type   CLOSE_PARENS  
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   AWAIT   primary-expression   OPEN_PARENS   argument-list   CLOSE_PARENS 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   AWAIT   primary-expression   OPEN_PARENS   CLOSE_PARENS  
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
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
    :   expression
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
    
base-access
    :   BASE   DOT   IDENTIFIER_WITH_TEMPLATE
    {
        $$ = $1 + "" + $2 + "" + $3;
    }
    |   BASE   OPEN_BRACKET   expression-list   CLOSE_BRACKET
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
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
    :   IDENTIFIER  TEMPLATE  
    {
        $$ = $1 + "" + $2;
    }
    |   non-array-type 
    {
        $$ = $1;
    }
    ;
    
object-creation-expression
    :   NEW   type-with-identifier   OPEN_PARENS   argument-list    CLOSE_PARENS    invocation-expressions    IDENTIFIER_WITH_DOT      block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7 + "" + $8;
    }
    |   NEW   type-with-identifier   OPEN_PARENS   argument-list    CLOSE_PARENS    invocation-expressions      IDENTIFIER_WITH_DOT
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   NEW   type-with-identifier   OPEN_PARENS   CLOSE_PARENS      invocation-expressions     IDENTIFIER_WITH_DOT    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6 + "" + $7;
    }
    |   NEW   type-with-identifier   OPEN_PARENS   CLOSE_PARENS      invocation-expressions     IDENTIFIER_WITH_DOT 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   NEW   type-with-identifier   OPEN_PARENS   CLOSE_PARENS     block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   NEW   type-with-identifier    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   NEW   non-array-type   rank-specifiers     block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   NEW   non-array-type   OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   NEW   non-array-type   OPEN_BRACKET   argument-list   CLOSE_BRACKET    
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5;
    }
    |   NEW   type-with-identifier   rank-specifiers    block-expression-with-brace 
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   NEW   type-with-identifier   OPEN_BRACKET   argument-list   CLOSE_BRACKET    block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4 + "" + $5 + "" + $6;
    }
    |   NEW   type-with-identifier   OPEN_BRACKET   argument-list   CLOSE_BRACKET     
    {
        $$ = $1 + " " + $2 + "" + $3 + "" + $4;
    }
    |   NEW   rank-specifiers   block-expression-with-brace
    {
        $$ = $1 + " " + $2 + "" + $3;
    }
    |   NEW   rank-specifiers     
    {
        $$ = $1 + " " + $2;
    }
    |   NEW   block-expression-with-brace
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
    ;
    

typeof-expression
    :   TYPEOF   OPEN_PARENS   type-with-interr   CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
    ;

sizeof-expression
    :   SIZEOF   OPEN_PARENS   type-with-interr   CLOSE_PARENS
    {
        $$ = $1 + "" + $2 + "" + $3 + "" + $4;
    }
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
    |   OP_PTR  unary-expression
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
    |   primary-expression  
    {
        $$ = $1;
    }
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
    {
        $$ = $1;
    }
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
    ;
 

embedded-statement
    :   block
    |   empty-statement
    |   statement-expression SEMICOLON
    |   selection-statement
    |   iteration-statement
    |   jump-statement
    |   try-statement
    |   checked-statement
    |   unchecked-statement
    |   lock-statement
    |   using-statement
    |   unsafe-statement
    |   fixed-statement 
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
    ;
    
local-variable-declaration
    :   primary-expression   local-variable-declarators
    |   type   local-variable-declarators
    ;

local-variable-declarators
    :   local-variable-declarators   COMMA   local-variable-declarator
    |   local-variable-declarator
    ;
    
local-variable
    :   %empty 
    |   INTERR  IDENTIFIER_WITH_KEYWORD
    |   STARS   IDENTIFIER_WITH_KEYWORD  
    |   IDENTIFIER_WITH_KEYWORD
    ;
    
local-variable-declarator
    :   local-variable
    |   local-variable   ASSIGN   local-variable-initializer
    ;
    
local-variable-initializer
    :   expression
    |   array-initializer
    ;

local-constant-declaration
    :   CONST   type   constant-declarators
    ;
    
constant-declarators
    :   constant-declarator
    |   constant-declarators   COMMA   constant-declarator
    ;
    
constant-declarator
    :   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    ;
    
 
    
statement-expression
    :   invocation-expressions
    |   object-creation-expression
    |   assignment      
    |   post-increment-expression
    |   post-decrement-expression
    |   pre-increment-expression
    |   pre-decrement-expression
    ;
    
selection-statement
    :   if-statement
    |   switch-statement
    ;
    
if-statement
    :   IF   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-statement
    |   IF   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-statement   ELSE   embedded-statement
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
    |   foreach-statement
    ;
    
while-statement
    :   WHILE   OPEN_PARENS   boolean-expression   CLOSE_PARENS   embedded-statement
    ;
    
do-statement
    :   DO   embedded-statement   WHILE   OPEN_PARENS   boolean-expression   CLOSE_PARENS   SEMICOLON
    ;

for-statement
    :   FOR   OPEN_PARENS   SEMICOLON   SEMICOLON   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   SEMICOLON   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   SEMICOLON   for-condition   SEMICOLON   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   SEMICOLON   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   for-condition   SEMICOLON   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   SEMICOLON   for-condition   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-statement
    |   FOR   OPEN_PARENS   for-initializer   SEMICOLON   for-condition   SEMICOLON   for-iterator   CLOSE_PARENS   embedded-statement
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
    |   statement-expression-list   COMMA   statement-expression
    ;

foreach-statement
    :   FOREACH   OPEN_PARENS   type   IDENTIFIER_WITH_KEYWORD   IN   expression   CLOSE_PARENS   embedded-statement
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
    
lock-statement
    :   LOCK   OPEN_PARENS   expression   CLOSE_PARENS   embedded-statement
    ;
    
using-statement
    :   USING   OPEN_PARENS    resource-acquisition   CLOSE_PARENS    embedded-statement
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
    |   variable-initializer-list   COMMA   variable-initializer
    ;

variable-initializer
    :   expression
    |   array-initializer
    ;



/* C.2.13 Attributes */
global-attributes
    :   global-attribute-sections
    ;
    
global-attribute-sections
    :   global-attribute-section
    |   global-attribute-sections global-attribute-section
    ;
    
global-attribute-section
    :   OPEN_BRACKET   global-attribute-target-specifier   attribute-list   CLOSE_BRACKET
    |   OPEN_BRACKET   global-attribute-target-specifier   attribute-list   COMMA   CLOSE_BRACKET
    ;
    
global-attribute-target-specifier
    :   global-attribute-target   COLON
    ;

global-attribute-target
    :   ASSEMBLY
    |   MODULE
    ;
    
attributes
    :   attribute-sections
    ;

attribute-sections
    :   attribute-section
    |   attribute-sections   attribute-section
    ;
    
attribute-section
    :   OPEN_BRACKET   attribute-list   CLOSE_BRACKET
    |   OPEN_BRACKET   attribute-list   COMMA   CLOSE_BRACKET
    |   OPEN_BRACKET   attribute-target-specifier   attribute-list   CLOSE_BRACKET
    |   OPEN_BRACKET   attribute-target-specifier   attribute-list   COMMA   CLOSE_BRACKET
    ;

attribute-target-specifier
    :   attribute-target   COLON
    ;

attribute-target
    :   FIELD
    |   EVENT
    |   METHOD
    |   PARAM
    |   PROPERTY
    |   RETURN
    |   TYPE
    ;
    
attribute-list
    :   attribute
    |   attribute-list   COMMA   attribute
    ;

attribute
    :   attribute-name  
    |   attribute-name   attribute-arguments   
    ;

attribute-name
    :   type-name
    ;
    
attribute-arguments
    :   OPEN_PARENS   CLOSE_PARENS
    |   OPEN_PARENS   positional-argument-list   CLOSE_PARENS
    |   OPEN_PARENS   positional-argument-list   COMMA   named-argument-list   CLOSE_PARENS
    |   OPEN_PARENS   named-argument-list   CLOSE_PARENS
    ;
    
positional-argument-list
    :   positional-argument
    |   positional-argument-list   COMMA   positional-argument
    ;

positional-argument
    :   attribute-argument-expression
    ;

named-argument-list
    :   named-argument
    |   named-argument-list   COMMA   named-argument
    ;
    
named-argument
    :   IDENTIFIER_WITH_TEMPLATE   ASSIGN   attribute-argument-expression
    ;
    
attribute-argument-expression
    :   expression
    ;




 

/* C.2.12 Delegates */

delegate-declaration
    :   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base    SEMICOLON
    {
        $$ = {
            "node": "delegate", 
            "type": $2
        };
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base    SEMICOLON
    {
        $$ = {
            "node": "delegate", 
            "type": $3 
        };
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   modifiers   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS     where-base   SEMICOLON
    {
        $$ = {
            "node": "delegate",
            "modifiers": $1,
            "type": $3 
        };
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS     where-base   SEMICOLON
    {
        $$ = {
            "node": "delegate", 
            "type": $2, 
            "parameters": $5
        };
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    where-base    SEMICOLON
    {
        $$ = {
            "node": "delegate",
            "modifiers": $1,
            "type": $3, 
            "parameters": $6
        };
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS     where-base   SEMICOLON
    {
        $$ = {
            "node": "delegate", 
            "type": $3, 
            "parameters": $6
        };
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS     where-base   SEMICOLON
    {
        $$ = {
            "node": "delegate",
            "modifiers": $2,
            "type": $4
        };
        if($5["typeParameters"]){
            $$["name"] = $5["name"];
            $$["typeParameters"] = $5["typeParameters"];
        }
        else {
            $$["name"] = $5;
        }
    }
    |   attributes   modifiers   DELEGATE   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS     where-base   SEMICOLON
    {
        $$ = {
            "node": "delegate",
            "modifiers": $2,
            "type": $4, 
            "parameters": $7
        };
        if($5["typeParameters"]){
            $$["name"] = $5["name"];
            $$["typeParameters"] = $5["typeParameters"];
        }
        else {
            $$["name"] = $5;
        }
    }
    ;
    
 

/* C.2.11 Enums */
enum-declaration
    :   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body
    {
        $$ = {
            "node": "enum", 
            "body": $3
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body
    {
        $$ = {
            "node": "enum", 
            "body": $4
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body
    {
        $$ = {
            "node": "enum",
            "modifiers": $1, 
            "body": $4
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   
    {
        $$ = {
            "node": "enum", 
            "base": $3,
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum", 
            "body": $3
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body
    {
        $$ = {
            "node": "enum",
            "modifiers": $2, 
            "body": $5
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body
    {
        $$ = {
            "node": "enum", 
            "base": $4,
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum", 
            "body": $4
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   
    {
        $$ = {
            "node": "enum",
            "modifiers": $1, 
            "base": $4,
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",
            "modifiers": $1, 
            "body": $4
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",  
            "base": $3,
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",
            "modifiers": $1, 
            "base": $4,
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",  
            "base": $4,
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",
            "modifiers": $2, 
            "body": $5
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body 
    {
        $$ = {
            "node": "enum",
            "modifiers": $2, 
            "base": $5,
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   ENUM   IDENTIFIER_WITH_TEMPLATE   enum-base   enum-body   SEMICOLON
    {
        $$ = {
            "node": "enum",
            "modifiers": $2, 
            "base": $5,
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
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
    |   attributes   IDENTIFIER_WITH_TEMPLATE
    {
        $$ = {
            "name": $2
        };
    }
    |   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    {
        $$ = {
            "name": $1,
            "value": $3
        };
    }
    |   attributes   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    {
        $$ = {
            "name": $2,
            "value": $4
        };
    }
    ;


/* C.2.10 Interfaces */
interface-declaration
    :   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body
    {
        $$ = {
            "node": "interface", 
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   INTERFACE   IDENTIFIER_WITH_TEMPLATE   where-base     interface-body 
    {
        $$ = {
            "node": "interface", 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE   where-base     interface-body
    {
        $$ = {
            "node": "interface",
            "modifiers": $1, 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body   
    {
        $$ = {
            "node": "interface",  
            "base": $3,
            "body": $5
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",  
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body
    {
        $$ = {
            "node": "interface",
            "modifiers": $2, 
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base   where-base     interface-body
    {
        $$ = {
            "node": "interface",  
            "base": $4,
            "body": $6
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",  
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body   
    {
        $$ = {
            "node": "interface",
            "modifiers": $1, 
            "base": $4,
            "body": $6
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",
            "modifiers": $1, 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base   where-base     interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",  
            "base": $3,
            "body": $5
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",
            "modifiers": $1, 
            "base": $4,
            "body": $6
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface", 
            "base": $4,
            "body": $6
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",
            "modifiers": $2, 
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body  
    {
        $$ = {
            "node": "interface",
            "modifiers": $2, 
            "base": $5,
            "body": $7
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   INTERFACE   IDENTIFIER_WITH_TEMPLATE   interface-base    where-base    interface-body   SEMICOLON
    {
        $$ = {
            "node": "interface",
            "modifiers": $2, 
            "base": $5,
            "body": $7
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    ;
 
interface-base
    :   COLON   interface-type-list
    {
        $$ = $2;
    }
    ;
    
interface-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   interface-member-declarations   CLOSE_BRACE
    {
        $$ = $2;
    }
    ;
    
interface-member-declarations
    :   interface-member-declaration
    {
        $$ = [ $1 ];
    }
    |   interface-member-declarations   interface-member-declaration
    {
        $1.push($2);
        $$ = $1;
    }
    ;

interface-member-declaration
    :   interface-method-declaration
    {
        $$ = $1;
    }
    |   interface-property-declaration
    {
        $$ = $1;
    }
    |   interface-event-declaration
    {
        $$ = $1;
    }
    |   interface-indexer-declaration
    {
        $$ = $1;
    }
    ;
    
interface-method-declaration
    :   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $1,
            "name": $2
        };
    }
    |   attributes   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $2,
            "name": $3
        };
    }
    |   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $2,
            "name": $3
        };
    }
    |   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $1,
            "name": $2,
            "parameters": $4
        };
    }
    |   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   where-base    SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $2,
            "name": $3,
            "parameters": $5
        };
    }
    |   attributes   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   where-base    SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $2,
            "name": $3,
            "parameters": $5
        };
    }
    |   attributes   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $3,
            "name": $4
        };
    }
    |   attributes   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    where-base   SEMICOLON
    {
        $$ = {
            "node": "method",
            "type": $3,
            "name": $4,
            "parameters": $6
        };
    }
    ;

interface-property-declaration
    :   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $1,
            "name": $2
        };
    }
    |   attributes   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $2,
            "name": $3
        };
    }
    |   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $2,
            "name": $3
        };
    }
    |   attributes   NEW   type-with-interr   IDENTIFIER_WITH_TEMPLATE   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $3,
            "name": $4
        };
    }
    ;
    
interface-accessors 
    :   attributes   GET   SEMICOLON   attributes   SET   SEMICOLON
    |   attributes   SET   SEMICOLON   attributes   GET   SEMICOLON 
    |   attributes   GET   SEMICOLON   SET   SEMICOLON
    |   attributes   SET   SEMICOLON   GET   SEMICOLON
    |   SET   SEMICOLON   attributes   GET   SEMICOLON
    |   GET   SEMICOLON   attributes   SET   SEMICOLON
    |   SET   SEMICOLON   GET   SEMICOLON
    |   GET   SEMICOLON   SET   SEMICOLON
    |   attributes   SET   SEMICOLON 
    |   attributes   GET   SEMICOLON 
    |   GET   SEMICOLON
    |   SET   SEMICOLON
    ;
    
interface-event-declaration
    :   EVENT   type-with-interr   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $2,
            "name": $3
        };
    }
    |   attributes   EVENT   type-with-interr   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $3,
            "name": $4
        };
    }
    |   NEW   EVENT   type-with-interr   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $3,
            "name": $4
        };
    }
    |   attributes   NEW   EVENT   type-with-interr   IDENTIFIER_WITH_TEMPLATE   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $4,
            "name": $5
        };
    }
    ;

interface-indexer-declaration
    :   type-with-interr   THIS   OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "indexer",
            "type": $1,
            "name": $2,
            "parameters": $4
        };
    }
    |   attributes   type-with-interr   THIS   OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "indexer",
            "type": $2,
            "name": $3,
            "parameters": $5
        };
    }
    |   NEW   type-with-interr   THIS   OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "indexer",
            "type": $2,
            "name": $3,
            "parameters": $5
        };
    }
    |   attributes   NEW   type-with-interr   THIS   OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET   OPEN_BRACE   interface-accessors   CLOSE_BRACE
    {
        $$ = {
            "node": "indexer",
            "type": $3,
            "name": $4,
            "parameters": $6
        };
    }
    ;


/* C.2.8 Structs */
struct-declaration 
    :   STRUCT   IDENTIFIER_WITH_TEMPLATE    where-base    struct-body
    {
        $$ = {
            "node": "struct", 
            "body": $4
        };  
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   STRUCT   IDENTIFIER_WITH_TEMPLATE    where-base    struct-body 
    {
        $$ = {
            "node": "struct", 
            "body": $5
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE    where-base    struct-body
    {
        $$ = {
            "node": "struct",
            "modifiers": $1, 
            "body": $5
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces   where-base     struct-body   
    {
        $$ = {
            "node": "struct", 
            "base": $3,
            "body": $5
        };  
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   STRUCT   IDENTIFIER_WITH_TEMPLATE   where-base     struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct", 
            "body": $4
        };  
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   where-base     struct-body
    {
        $$ = {
            "node": "struct",
            "modifiers": $2, 
            "body": $6
        };  
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces   where-base     struct-body
    {
        $$ = {
            "node": "struct", 
            "base": $4,
            "body": $6
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   STRUCT   IDENTIFIER_WITH_TEMPLATE    where-base    struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct", 
            "body": $5
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces    where-base    struct-body
    {
        $$ = {
            "node": "struct",
            "modifiers": $1, 
            "base": $4,
            "body": $6
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   where-base     struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct",
            "modifiers": $1, 
            "body": $5
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces    where-base    struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct", 
            "base": $3,
            "body": $5
        };  
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces    where-base    struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct",
            "modifiers": $1, 
            "base": $4,
            "body": $6
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces    where-base    struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct", 
            "base": $4,
            "body": $6
        };  
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   where-base     struct-body   SEMICOLON
    {
        $$ = {
            "node": "struct",
            "modifiers": $2, 
            "body": $6
        };  
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces   where-base     struct-body  
    {
        $$ = {
            "node": "struct",
            "modifiers": $2, 
            "base": $5,
            "body": $7
        };  
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   STRUCT   IDENTIFIER_WITH_TEMPLATE   struct-interfaces   where-base     struct-body   SEMICOLON 
    {
        $$ = {
            "node": "struct",
            "modifiers": $2, 
            "base": $5,
            "body": $7
        };  
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    ;
 
struct-interfaces
    :   COLON   interface-type-list
    {
        $$ = $2;
    }
    ;

struct-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   struct-member-declarations   CLOSE_BRACE
    {
        $$ = $2;
    }
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
    :   constant-declaration
    {
        $$ = $1;
    }
    |   field-declaration
    {
        $$ = $1;
    }
    |   method-declaration
    {
        $$ = $1;
    }
    |   property-declaration
    {
        $$ = $1;
    }
    |   event-declaration
    {
        $$ = $1;
    }
    |   indexer-declaration
    {
        $$ = $1;
    }
    |   operator-declaration
    {
        $$ = $1;
    }
    |   constructor-declaration
    {
        $$ = $1;
    }
    |   static-constructor-declaration
    {
        $$ = $1;
    }
    |   type-declaration
    {
        $$ = $1;
    }
    ;



/* C.2.6 Namespaces */
compilationUnit
    :   %empty      EOF
    |   namespace-member-declarations    EOF 
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
    :   statement
    {
        $$ = $1;
    }
    |   type-declaration
    {
        $$ = $1;
    }
    ;

type-declaration
    :   class-declaration
    {
        $$ = $1;
    }   
    |   struct-declaration
    {
        $$ = $1;
    }
    |   interface-declaration
    {
        $$ = $1;
    }
    |   enum-declaration
    {
        $$ = $1;
    }
    |   delegate-declaration
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
    |   SEALED
    |   STATIC
    |   READONLY
    |   VOLATILE 
    |   VIRTUAL   
    |   OVERRIDE  
    |   EXTERN  
    |   NEW
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
class-declaration 
    :   CLASS   IDENTIFIER_WITH_TEMPLATE    where-base     class-body
    { 
        $$ = {
            "node": "class", 
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   CLASS   IDENTIFIER_WITH_TEMPLATE   where-base    class-body 
    {
        $$ = {
            "node": "class", 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE   where-base     class-body
    {
        $$ = {
            "node": "class",
            "modifiers": $1, 
            "body": $5  
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base   where-base    class-body  
    {
        isAnnotationType = false;
        for(i=0;i<$3.length;i++){
            if($3[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",  
                "base": $3,
                "body": $5
            };
        }
        else{
            $$ = {
                "node": "class",  
                "base": $3,
                "body": $5  
            };
        }
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
        
    }
    |   CLASS   IDENTIFIER_WITH_TEMPLATE   where-base    class-body   SEMICOLON
    {
        $$ = {
            "node": "class",  
            "body": $4
        };
        
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   attributes   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE  where-base     class-body
    {
        $$ = {
            "node": "class", 
            "modifiers": $2, 
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base     class-body
    {
        isAnnotationType = false;
        for(i=0;i<$4.length;i++){
            if($4[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",   
                "base": $4,
                "body": $6 
            };
        }
        else {
            $$ = {
                "node": "class",   
                "base": $4,
                "body": $6
            };
        }
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   CLASS   IDENTIFIER_WITH_TEMPLATE  where-base     class-body   SEMICOLON
    {
        $$ = {
            "node": "class", 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base     class-body
    {
        isAnnotationType = false;
        for(i=0;i<$4.length;i++){
            if($4[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",
                "modifiers": $1, 
                "base": $4,
                "body": $6 
            };
        }
        else {
            $$ = {
                "node": "class",
                "modifiers": $1, 
                "base": $4,
                "body": $6
            };
        } 
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE  where-base     class-body   SEMICOLON
    {
        $$ = {
            "node": "class",
            "modifiers": $1, 
            "body": $5
        };
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base     class-body   SEMICOLON
    {
        isAnnotationType = false;
        for(i=0;i<$3.length;i++){
            if($3[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        if (isAnnotationType){
            $$ = {
                "node": "annotationType", 
                "base": $3,
                "body": $5 
            };
        }
        else {
            $$ = {
                "node": "class", 
                "base": $3,
                "body": $5
            };
        }
        if($2["typeParameters"]){
            $$["name"] = $2["name"];
            $$["typeParameters"] = $2["typeParameters"];
        }
        else {
            $$["name"] = $2;
        }
    }
    |   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base     class-body   SEMICOLON
    {
        isAnnotationType = false;
        for(i=0;i<$4.length;i++){
            if($4[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",
                "modifiers": $1, 
                "base": $4,
                "body": $6 
            };
        }
        else {
            $$ = {
                "node": "class",
                "modifiers": $1, 
                "base": $4,
                "body": $6
            };
        } 
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        } 
    }
    |   attributes   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base     class-body   SEMICOLON
    {
        isAnnotationType = false;
        for(i=0;i<$4.length;i++){
            if($4[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",  
                "base": $4,
                "body": $6 
            };
        }
        else {
            $$ = {
                "node": "class",  
                "base": $4,
                "body": $6
            };
        }
        
        if($3["typeParameters"]){
            $$["name"] = $3["name"];
            $$["typeParameters"] = $3["typeParameters"];
        }
        else {
            $$["name"] = $3;
        }
    }
    |   attributes   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE  where-base     class-body   SEMICOLON
    {
        $$ = {
            "node": "class", 
            "modifiers": $2, 
            "body": $6
        };
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base   class-body  
    {
        isAnnotationType = false;
        for(i=0;i<$5.length;i++){
            if($5[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",
                "modifiers": $2, 
                "base": $5,
                "body": $7 
            };
        }
        else {
            $$ = {
                "node": "class",
                "modifiers": $2, 
                "base": $5,
                "body": $7
            };
        }
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    |   attributes   modifiers   CLASS   IDENTIFIER_WITH_TEMPLATE   class-base  where-base   class-body   SEMICOLON
    {
        isAnnotationType = false;
        for(i=0;i<$5.length;i++){
            if($5[i] == "System.Attribute"){
                isAnnotationType = true;
            }
        }
        
        if (isAnnotationType){
            $$ = {
                "node": "annotationType",
                "modifiers": $2, 
                "base": $5,
                "body": $7 
            };
        }
        else {
            $$ = {
                "node": "class",
                "modifiers": $2, 
                "base": $5,
                "body": $7
            };
        }
        
        if($4["typeParameters"]){
            $$["name"] = $4["name"];
            $$["typeParameters"] = $4["typeParameters"];
        }
        else {
            $$["name"] = $4;
        }
    }
    ;
    
 

where-base
    :   where-units    COMMA    NEW   OPEN_PARENS   CLOSE_PARENS
    |   where-units
    ;


where-units
    :   where-units  where-unit
    |   where-unit
    ;

where-names
    :   where-names   COMMA    where-name
    |   where-name
    ;

where-name
    :   type-name
    |   type
    |   CLASS
    |   STRUCT
    |   NEW   OPEN_PARENS   CLOSE_PARENS
    ;
 
where-unit
    :   WHERE   type-name   COLON   where-names   
    |   %empty
    ;

class-base
    :   COLON   type-with-interr
    {
        $$ = [ $2 ];
    }
    |   COLON   interface-type-list
    {
        $$ = $2;
    }
    |   COLON   type-with-interr   COMMA   interface-type-list
    {
        $4.push($2);
        $$ = $4;
    }
    ;

interface-type-list
    :   type-with-interr
    {
        $$ = [ $1 ];
    }
    |   interface-type-list   COMMA   type-with-interr
    {
        $1.push($2);
        $$ = $1;
    }
    ;

class-body
    :   OPEN_BRACE   CLOSE_BRACE
    |   OPEN_BRACE   class-member-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "classMembers", 
            "members": $2
        };
    }
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
    :   constant-declaration
    {
        $$ = $1;
    }
    |   method-declaration
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
    |   event-declaration
    {
        $$ = $1;
    }
    |   indexer-declaration
    {
        $$ = $1;
    }
    |   operator-declaration
    {
        $$ = $1;
    }
    |   constructor-declaration
    {
        $$ = $1;
    }
    |   static-constructor-declaration
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
    ;


constant-declaration
    :   CONST   type-with-interr   constant-declarators   SEMICOLON
    {
        $$ = {
            "node": "constant",
            "type": $2,
            "names": $3
        };
    }
    |   attributes   CONST   type-with-interr   constant-declarators   SEMICOLON
    {
        $$ = {
            "node": "constant",
            "type": $3,
            "names": $4
        };
    }
    |   modifiers   CONST   type-with-interr   constant-declarators   SEMICOLON
    {
        $$ = {
            "node": "constant",
            "modifiers": $1,
            "type": $2,
            "names": $3
        };
    }
    |   attributes   modifiers   CONST   type-with-interr   constant-declarators   SEMICOLON
    {
        $$ = {
            "node": "constant",
            "modifiers": $2,
            "type": $4,
            "names": $5
        };
    }
    ;
 
constant-declarators
    :   constant-declarator
    {
        $$ = [ $1 ];
    }
    |   constant-declarators   COMMA   constant-declarator
    {
        $1.push($3);
        $$ = $1;
    }
    ;

constant-declarator
    :   IDENTIFIER_WITH_TEMPLATE   ASSIGN   constant-expression
    {
        $$ = {
            "name": $1,
            "value": $3
        };
    }
    ;

field-declaration
    :   type-with-interr    member-name   SEMICOLON
    {
        $$ = {
            "node": "field",
            "type": $1, 
            "name": $2
        };
    }
    |   attributes   type-with-interr    member-name   SEMICOLON
    {
        $$ = {
            "node": "field",
            "type": $2,
            "name": $3
        };
    }
    |   modifiers   type-with-interr    member-name   SEMICOLON
    {
        $$ = {
            "node": "field",
            "modifiers": $1,
            "type": $2,
            "name": $3
        };
    }
    |   attributes    modifiers   type-with-interr    member-name   SEMICOLON
    {
        $$ = {
            "node": "field",
            "modifiers": $2,
            "type": $3,
            "name": $4
        };
    }
    ;
      
    
variable-declarators
    :   variable-declarators   COMMA   variable-declarator
    {
        $1.push($3);
        $$ = $1;
    }
    |   variable-declarator
    {
        $$ = [ $1 ];
    }
    ;

variable-declarator
    :   type-name      ASSIGN   variable-initializer
    {
        $$ = {
            "node": "variable",
            "name": $1,
            "initialize": $3
        };
    }
    |   type-name   
    {
        $$ = {
            "node": "variable",
            "name": $1 
        };
    }
    ;

variable-initializer
    :   expression
    {
        $$ = $1;
    }
    |   array-initializer
    {
        $$ = $1;
    }
    ;


method-declaration
    :   method-header   block
    {
        $$ = $1;
    }
    |   method-header   SEMICOLON
    {
        $$ = $1;
    }
    ;
    

method-header  
    :   type-with-interr   member-name   OPEN_PARENS   CLOSE_PARENS      where-base
    {
        $$ = {
            "node": "method",
            "type": $1, 
            "name": $2
        };
    }
    |   attributes   type-with-interr   member-name   OPEN_PARENS   CLOSE_PARENS      where-base
    {
        $$ = {
            "node": "method",
            "type": $1, 
            "name": $2
        };
    }
    |   modifiers   type-with-interr   member-name   OPEN_PARENS   CLOSE_PARENS       where-base
    {
        $$ = {
            "node": "method",
            "modifiers": $1,
            "type": $2, 
            "name": $3
        };
    }
    |   type-with-interr   member-name   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS       where-base
    {
        $$ = {
            "node": "method",
            "type": $1, 
            "name": $2,
            "parameter": $4
        };
    }
    |   modifiers   type-with-interr   member-name   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS       where-base
    {
        $$ = {
            "node": "method",
            "modifiers": $1,
            "type": $2, 
            "name": $3,
            "parameter": $5
        };
    }
    |   attributes   type-with-interr   member-name   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS      where-base
    {
        $$ = {
            "node": "method",
            "type": $2, 
            "name": $3,
            "parameter": $5
        };
    }
    |   attributes   modifiers   type-with-interr   member-name   OPEN_PARENS   CLOSE_PARENS       where-base
    {
        $$ = {
            "node": "method",
            "modifiers": $2,
            "type": $3, 
            "name": $4 
        };
    }
    |   attributes   modifiers   type-with-interr   member-name   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS    where-base
    {
        $$ = {
            "node": "method",
            "modifiers": $2,
            "type": $3, 
            "name": $4,
            "parameter": $6
        };
    }
    ;
     
     
member-name
    :   variable-declarators 
    {
        $$ = $1;
    }
    ;
 

method-body
    :   block
    |   SEMICOLON
    ;

formal-parameter-list
    :   fixed-parameters
    {
        $$ = $1;
    }
    |   fixed-parameters   COMMA   parameter-array
    {
        $1.push($3);
        $$ = $1;
    }
    |   parameter-array
    {
        $$ = [ $1 ];
    }
    ;

fixed-parameters
    :   fixed-parameter
    {
        $$ = [ $1 ];
    }
    |   fixed-parameters   COMMA   fixed-parameter
    {
        $1.push($3);
        $$ = $1;
    }
    ;

IDENTIFIER_WITH_KEYWORD
    :   IDENTIFIER_WITH_TEMPLATE
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
    |   WHERE
    ;

fixed-parameter
    :   type-with-interr   IDENTIFIER_WITH_KEYWORD      ASSIGN     expression
    {
        $$ = {
            "type": $1,
            "name": $2
        };
    }
    |   type-with-interr   IDENTIFIER_WITH_KEYWORD
    {
        $$ = {
            "type": $1,
            "name": $2
        };
    }
    |   THIS    type-with-interr    IDENTIFIER_WITH_KEYWORD
    {
        $$ = {
            "type": $2,
            "name": $3
        };
    }
    |   attributes   type-with-interr   IDENTIFIER_WITH_KEYWORD
    {
        $$ = {
            "type": $2,
            "name": $3
        };
    }
    |   parameter-modifier   type-with-interr   IDENTIFIER_WITH_KEYWORD
    {
        $$ = {
            "modifier": $1,
            "type": $2,
            "name": $3
        };
    }
    |   attributes   parameter-modifier   type-with-interr   IDENTIFIER_WITH_KEYWORD
    {
        $$ = {
            "modifier": $2,
            "type": $3,
            "name": $4
        };
    }
    ;

parameter-modifier
    :   REF
    |   OUT
    ;

parameter-array
    :   PARAMS   array-type   IDENTIFIER_WITH_TEMPLATE
    {
        $$ = {
            "type": $2,
            "name": $3
        };
    }
    |   attributes   PARAMS   array-type   IDENTIFIER_WITH_TEMPLATE
    {
        $$ = {
            "type": $3,
            "name": $4
        };
    }
    ;


property-declaration
    :   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $1, 
            "name": $2
        };
    }
    |   attributes   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "type": $2,
            "name": $3
        };
    }
    |   modifiers   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "modifiers": $1,
            "type": $2,
            "name": $3
        };
    }
    |   attributes   modifiers   type-with-interr   member-name   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "property",
            "modifiers": $2,
            "type": $3,
            "name": $4
        };
    }
    ;

accessor-declarations
    :   get-accessor-declaration 
    |   get-accessor-declaration   set-accessor-declaration
    |   set-accessor-declaration 
    |   set-accessor-declaration   get-accessor-declaration
    ;

get-accessor-declaration
    :   attributes  modifiers  GET   method-body
    |   modifiers  GET   method-body
    |   attributes  GET   method-body
    |   GET   method-body
    ;

set-accessor-declaration
    :   attributes  modifiers    SET   method-body
    |   modifiers   SET   method-body
    |   attributes   SET   method-body
    |   SET   method-body
    ;



event-declaration
    :   EVENT   type-with-interr   variable-declarators   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $2,
            "variables": $3            
        };
    }
    |   attributes   EVENT   type-with-interr   variable-declarators   SEMICOLON
    {
        $$ = {
            "node": "event",
            "type": $3,
            "variables": $4            
        };
    }
    |   modifiers   EVENT   type-with-interr   variable-declarators   SEMICOLON
    {
        $$ = {
            "node": "event",
            "modifiers": $1,
            "type": $3,
            "variables": $4            
        };
    }
    |   attributes   modifiers   EVENT   type-with-interr   variable-declarators   SEMICOLON
    {
        $$ = {
            "node": "event",
            "modifiers": $2,
            "type": $4,
            "variables": $5
        };
    }
    |   EVENT   type-with-interr   member-name   OPEN_BRACE   event-accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "event",
            "type": $2,
            "variables": $3 
        };
    }
    |   attributes   EVENT   type-with-interr   member-name   OPEN_BRACE   event-accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "event",
            "type": $3,
            "variables": $4 
        };
    }
    |   modifiers   EVENT   type-with-interr   member-name   OPEN_BRACE   event-accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "event",
            "modifiers": $1,
            "type": $3,
            "variables": $4
        };
    }
    |   attributes   modifiers   EVENT   type-with-interr   member-name   OPEN_BRACE   event-accessor-declarations   CLOSE_BRACE
    {
        $$ = {
            "node": "event",
            "modifiers": $2,
            "type": $4,
            "variables": $5
        };
    }
    ;
 
event-accessor-declarations
    :   add-accessor-declaration   remove-accessor-declaration
    |   remove-accessor-declaration   add-accessor-declaration
    ;

add-accessor-declaration
    :   ADD   block
    |   attributes   ADD   block
    ;

remove-accessor-declaration
    :   REMOVE   block
    |   attributes   REMOVE   block
    ;



indexer-declaration
    :   indexer-declarator   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = $1;
    }
    |   attributes   indexer-declarator   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $$ = $1;
    }
    |   modifiers   indexer-declarator   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $2["modifiers"] = $1;
        $$ = $2;
    }
    |   attributes   modifiers   indexer-declarator   OPEN_BRACE   accessor-declarations   CLOSE_BRACE
    {
        $3["modifiers"] = $2;
        $$ = $3;
    }
    ;

indexer-declarator
    :   type-with-interr   THIS   OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET
    {
        $$ = {
            "node": "indexer",
            "type": $1,
            "name": $2,
            "parameters": $4
        };
    }
    |   type-with-interr   member-name     OPEN_BRACKET   formal-parameter-list   CLOSE_BRACKET
    {
        $$ = {
            "node": "indexer",
            "type": $1,
            "name": $2,
            "parameters": $4
        };
    }
    ;



operator-declaration
    :   modifiers   operator-declarator   method-body
    { 
        $2["node"]= "operator";
        $2["modifiers"]= $1;
        $$= $2;
        
    }
    |   attributes   modifiers   operator-declarator   method-body 
    {
        $3["node"]= "operator";
        $3["modifiers"]= $2;
        $$= $3;
    }
    ;
 

operator-declarator
    :   unary-operator-declarator
    {
        $$ = $1;
    }
    |   binary-operator-declarator
    {
        $$ = $1;
    }
    |   conversion-operator-declarator
    {
        $$ = $1;
    }
    ;

unary-operator-declarator
    :   type-with-interr   OPERATOR   overloadable-operator   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS
    {
        $$ = {
            "type": $1,
            "operator": $3,
            "parameter": [{
                "type": $5,
                "name": $6
            }]
        };
    }
    ;

overloadable-operator
    :   overloadable-unary-operator
    {
        $$ = $1;
    }
    |   overloadable-binary-operator
    {
        $$ = $1;
    }
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
    {
        $$ = {
            "type": $1,
            "operator": $3,
            "parameter": [{
                "type": $5,
                "name": $6
            }, {
                "type": $8,
                "name": $9
            }]
        };
    }
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
    |   GT
    |   LT
    ;

conversion-operator-declarator
    :   IMPLICIT   OPERATOR   type-with-interr   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS
    {
        $$ = {
            "type": $3,
            "operator": "implicit",
            "parameter":[{
                "type": $5,
                "name": $6
            }]
        };
    }
    |   IMPLICIT   OPERATOR   type-with-interr   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_KEYWORD   CLOSE_PARENS
    {
        $$ = {
            "type": $3,
            "operator": "implicit",
            "parameter":[{
                "type": $5,
                "name": $6
            }]
        };
    }
    |   EXPLICIT   OPERATOR   type-with-interr   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_TEMPLATE   CLOSE_PARENS
    {
        $$ = {
            "type": $3,
            "operator": "explicit",
            "parameter":[{
                "type": $5,
                "name": $6
            }]
        };
    }
    |   EXPLICIT   OPERATOR   type-with-interr   OPEN_PARENS   type-with-interr   IDENTIFIER_WITH_KEYWORD   CLOSE_PARENS
    {
        $$ = {
            "type": $3,
            "operator": "explicit",
            "parameter":[{
                "type": $5,
                "name": $6
            }]
        };
    }
    ;


constructor-declaration
    :   constructor-declarator   method-body
    {
        $$ = $1;
    }
    |   attributes   constructor-declarator   method-body
    {
        $$ = $2;
    }
    |   modifiers   constructor-declarator   method-body
    {
        $2["modifiers"] = $1;
        $$ = $2;
    }
    |   attributes   modifiers   constructor-declarator   method-body
    {
        $3["modifiers"] = $2;
        $$ = $3;
    }
    ;
 
constructor-declarator
    :   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS
    {
        $$ = {
            "node": "constructor",
            "name": $1
        };
    }   
    |   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS
    {
        $$ = {
            "node": "constructor",
            "name": $1,
            "parameters": $3
        };
    }  
    |   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS   constructor-initializer
    {
        $$ = {
            "node": "constructor",
            "name": $1
        };
    }  
    |   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   formal-parameter-list   CLOSE_PARENS   constructor-initializer
    {
        $$ = {
            "node": "constructor",
            "name": $1,
            "parameters": $3
        };
    }  
    ;

constructor-initializer
    :   COLON   BASE   OPEN_PARENS   CLOSE_PARENS
    |   COLON   BASE   OPEN_PARENS   argument-list   CLOSE_PARENS
    |   COLON   THIS   OPEN_PARENS   CLOSE_PARENS
    |   COLON   THIS   OPEN_PARENS   argument-list   CLOSE_PARENS
    ;



static-constructor-declaration
    :   modifiers   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS   method-body
    {
        $$ = {
            "node": "constructor",
            "modifiers": $1,
            "name": $2
        };
    }
    |   attributes   modifiers   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS   method-body
    {
        $$ = {
            "node": "constructor",
            "modifiers": $2,
            "name": $3
        };
    }
    ;
 

destructor-declaration
    :   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    method-body
    {
        $$ = {
            "node": "destructor", 
            "name": $1 + "" + $2
        };
    }
    |   attributes   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    method-body
    {
        $$ = {
            "node": "destructor", 
            "name": $2 + "" + $3
        };
    }
    |   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    method-body
    {
        $$ = {
            "node": "destructor", 
            "extern": $1,
            "name": $2 + "" + $3
        };
    }
    |   attributes   EXTERN   TILDE   IDENTIFIER_WITH_TEMPLATE   OPEN_PARENS   CLOSE_PARENS    method-body
    {
        $$ = {
            "node": "destructor", 
            "extern": $2,
            "name": $3 + "" + $4
        };
    }
    ;
 

































