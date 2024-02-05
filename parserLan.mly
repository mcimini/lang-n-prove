%{
  open Language
%}

%token <string> VARLEX
%token <string> VARTERM
%token <int> INT %token GRAMMARASSIGN
%token MID
%token COMMA
%token PROVIDED
%token COLON
%token TURNSTYLE
%token TURNSTYLEA
%token AND
%token LEFTPAR  
%token RIGHTPAR 
%token EMPTYCTX 
%token DOT 
%token STEP 
%token VALUECTX 
%token EXPCTX 
%token GAMMA 
%token VARX 
%token VARBIGX 
%token LEFTSQUARE 
%token RIGHTSQUARE 
%token SUBSTBAR 
%token VALUEPRED 
%token DIRECTIVE 
%token SUBTYPING 
%token SUBTYPINGA
%token JOIN
%token MEET
 

%left EXEC

%token EOF

%start fileLan
%type <Language.language> fileLan

%%

fileLan:
  | EOF
    { Language([], []) }
  | lan = language EOF
    { lan }

language :
	| grammar = list(grammarLine) rules = list(rule) 
  		{ Language(grammar, rules) }
 
term :  
  | LEFTPAR opname = VARLEX ts = list(term) RIGHTPAR	
    { Constr(opname, ts) } 
  | VARX
    { BoundVar }
  | VARBIGX
    { BoundTypeVar }
  | var = VARTERM
    { LangVar(var) }
  | LEFTPAR VARX RIGHTPAR t = term      
    { Abs(t) }  
  | LEFTPAR VARBIGX RIGHTPAR t = term     
  	{ AbsType(t) } 
  | VALUECTX
      { LangVar "v" } 
  | EXPCTX
      { LangVar "e" } 
  | t1 = term LEFTSQUARE t2 = term SUBSTBAR t3 = term RIGHTSQUARE
      { Substitution(t1,t2,t3) } 

rule : 
  | f = formula DOT
    { Rule([],f) }
  | f = formula PROVIDED premises = separated_list(AND, formula) DOT
    { Rule(premises,f) }

formula : 
  | gammaTerm = assumption TURNSTYLE t1 = term COLON t2 = term
    { Formula("typeOf", [gammaTerm ; t1 ; t2]) }
  | gammaTerm = assumption TURNSTYLEA t1 = term COLON t2 = term
    { Formula("typeOfA", [gammaTerm ; t1 ; t2]) }
  | t1 = term STEP t2 = term 
    { Formula("step", [t1 ; t2]) }
  | t1 = term SUBTYPINGA t2 = term 
    { Formula("subtypeA", [t1 ; t2]) }
  | VALUEPRED t = term 
	{ Formula("value", [t]) }
  | JOIN t1 = term t2 = term t3 = term
    { Formula("join", [t1; t2; t3]) }
  | MEET t1 = term t2 = term t3 = term
    { Formula("meet", [t1; t2; t3]) }

assumption : 
  | GAMMA 
    { LangVar "Gamma" }
  | GAMMA COMMA VARX COLON t = term
    { Constr("gammaAddx", [t]) }
  | GAMMA COMMA VARBIGX 
	{ Constr("gammaAddX", []) }

grammarLine : 
	| category = VARTERM metavar = option(VARTERM) GRAMMARASSIGN ts = option(separated_list(MID, term)) DOT
	{ GrammarLine(category,metavar, ts) }
	| category = VARTERM metavar = option(VARTERM) GRAMMARASSIGN EMPTYCTX MID ts = option(separated_list(MID, term)) DOT
	{ GrammarLine(category,metavar,ts) }

directives : 
	| DIRECTIVE list(tagInfo) DOT	
	{ true }
	| DIRECTIVE list(tagInfo) rule	
	{ true }

tagInfo : 
	| VARLEX	
	| VARTERM
	| INT	
	| COLON	
	{ true }
  
