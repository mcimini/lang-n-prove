%{
  open Lnp
%}

%token <string> VAR
%token <string> NAME
%token <int> INT

%token FOR
%token EACH
%token IN
%token INN
%token COMMA
%token THEOREM
%token UNDERSCORE
%token LPAREN
%token RPAREN
%token LSQUARE
%token RSQUARE
%token COLON
%token FORALLSTAR
%token FORALL
%token DOT
%token PREMISES
%token PREMISESIDX
%token RULE
%token TURNSTYLE
%token TURNSTYLEA
%token STEP
%token SUBTYPING
%token SUBTYPINGA
%token FORALLVARS
%token IMPLY
%token ORMACRO
%token EXISTSVARS
%token EQUAL
%token AND
%token ANDMACRO
%token VALUESOF
%token VALUEARGS
%token OFTYPE
%token ISSINGLEVALUE
%token TARGETV
%token TARGETOP
%token CONTAINSSUB
%token IMPLYMACRO
%token EVALORDER
%token CONTEXTARGS
%token GETARGS
%token PROOF
%token INTROS
%token SEARCH
%token CASE
%token CASESTAR
%token IF
%token THEN
%token ELSE
%token NOP
%token MUTUAL
%token INDUCTION
%token INDUCTIONSTAR
%token ON
%token FIRST
%token SECOND
%token ENDFOR
%token APPLY
%token TO
%token BACKCHAIN
%token ISELIM
%token ISDERIVED
%token ISERRORHANDLER
%token GETARGTYPE
%token OR
%token EXISTSTAR
%token EXISTS
%token ISVAR
%token IS
%token ORTERM
%token ANDTERM
%token ENDOR
%token ENDAND
%token ENDIMPLY
%token ENDIF
%token SKIP
%token LET
%token ALIGN
%token WHERE
%token APPEND
%token COVARIANT
%token REVERSEIMPLY
%token FIND
%token VARSOF
%token WITH
%token TARGETOFELIMFORM
%token TARGETOFERRORHANDLER

%left IMPLYMACRO

%token EOF

%start file
%type <Lnp.schema> file

%start mystring
%type <Lnp.schema> mystring

%%

file:
  | EOF
    { ForEachThm(None, String "", Bottom, NoOp) } /*    { Uninstantiated theorem } */
    /*    { [] } */
  | e = schema EOF
    { e }

mystring:
  | e = schema
    { e }
  | EOF
    { ForEachThm(None, String "", Bottom, NoOp) } /*    { Uninstantiated theorem } */
  | e = schema EOF
  	{ e }

schema:
  | FOR EACH var = VAR IN t = evalExp COMMA
        THEOREM name = lnp_name COLON 
		f = formula DOT
		PROOF DOT p = proof 
		{ ForEachThm(Some(var, t), name, f, p) } 
    | THEOREM name = lnp_name COLON 
  		f = formula DOT
        PROOF DOT p = proof 
  		{ ForEachThm(None, name, f, p) }

evalExp:
  | name = NAME
    { Name name }
  | var = VAR
    { Var var }
  | num = INT
    { Num num }
  | LPAREN opname = VAR es = list(evalExp) RPAREN /* (opname t1 ... tn)   opname is VAR */
    { Constructor(opname, es) }
  | VALUESOF LPAREN t = evalExp RPAREN
    { ValuesOf t }
  | VALUEARGS LPAREN t = evalExp RPAREN
      { ValueArgs t }
  | OFTYPE LPAREN t = evalExp RPAREN
      { OfType t }
  | ISVAR LPAREN t = evalExp RPAREN
      { IsVar t }
  | ISSINGLEVALUE LPAREN t = evalExp RPAREN
      { IsSingleValue t }
  | TARGETV LPAREN t = evalExp RPAREN
      { TargetV t }
  | TARGETOP LPAREN t = evalExp RPAREN
      { TargetOp t }
  | CONTAINSSUB LPAREN t = evalExp RPAREN
      { ContainsSub t }
  | EVALORDER LPAREN t = evalExp RPAREN
      { EvaluationOrder t }
  | CONTEXTARGS LPAREN t = evalExp RPAREN
      { ContextualArgs t }
  | GETARGS LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
      { GetArgs(t1, t2) }
  | ISELIM LPAREN t = evalExp RPAREN
      { IsEliminationForm t }
  | ISERRORHANDLER LPAREN t = evalExp RPAREN
      { IsErrorHandler t }
  | GETARGTYPE LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
	  { GetArgType(t1, t2) }
  | ALIGN t1 = evalExp TO t2 = evalExp WHERE var1 = VAR EQUAL var2 = VAR
      { Align(t1, t2, Var(var1), Var(var2)) }
  | APPEND LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
      { Append(t1, t2) }
  | COVARIANT LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
      { Covariant(t1, t2) }
  | FIND t1 = evalExp IN t2 = evalExp
      { FindVarInPremises(t1, t2) }
  | VARSOF LPAREN t1 = evalExp RPAREN
      { VarsOf(t1) }
  | TARGETOFELIMFORM LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
      { TargetOfElimForm(t1, t2) }
  | TARGETOFERRORHANDLER LPAREN t1 = evalExp COMMA t2 = evalExp RPAREN
      { TargetOfErrorHandler(t1, t2) }
  | t1 = evalExp IN t2 = evalExp 
      { InList(t1,t2) }
  | var = VAR IS t = evalExp 
      { IS(Var var,t) }
  | LPAREN var = VAR EQUAL t = evalExp RPAREN
      { EqualTerm(Var var, t) }
  | t1 = evalExp DOT PREMISES
      { Dot(t1, Premises(None)) }
  | t1 = evalExp DOT PREMISESIDX LSQUARE r = relation RSQUARE
      { Dot(t1, PremisesIdx(r)) }
  | t1 = evalExp DOT PREMISES LSQUARE r = relation RSQUARE
      { Dot(t1, Premises(Some(r))) }
  | t1 = evalExp DOT t2 = VAR
      { Dot(t1, Var(t2)) }
  | t1 = evalExp DOT RULE LSQUARE r = relation RSQUARE
      { Dot(t1, Relation(r)) }
  | t1 = evalExp ORTERM t2 = evalExp 
      { OrTerm(t1,t2) }
  | t1 = evalExp ANDTERM t2 = evalExp 
      { AndTerm(t1,t2) }

relation:
    | TURNSTYLE
        {"typeOf"}
    | TURNSTYLEA
        {"typeOfA"}
    | STEP
        {"step"}
    | SUBTYPING
        {"subtype"}
    | SUBTYPINGA
        {"subtypeA"}
    | predname = VAR
        {predname}

lnp_name:
	| UNDERSCORE
  		{String "_" }
	| name = NAME
	  {String name }
 	| name = NAME UNDERSCORE LPAREN t = evalExp RPAREN
      {SuffixedString(name,t) }
    | LPAREN name = NAME args = list(hypParam) RPAREN
      {Function(name, args)}
    | LPAREN name = NAME REVERSEIMPLY t = evalExp RPAREN
      {ApplyFromList(name, t)}

hypParam:
    | UNDERSCORE
        {Var("_")}
    | e = evalExp
        {e}



formula:
	| LPAREN name = lnp_name COLON predname = VAR es = list(evalExp) RPAREN
    	{ Formula(name, predname, List.map names_to_vars es) }  
    | FORALLSTAR COMMA f = formula
        { ForallStar(f) }
    | EXISTSTAR COMMA f = formula
        { ExistStar(f) }
    | FORALL var = VAR COMMA f = formula
        { Forall(var, f) }
	| FORALLVARS LPAREN t = evalExp RPAREN COMMA f = formula
	    { ForallVars(t,f) }
  	| EXISTSVARS LPAREN t = evalExp RPAREN COMMA f = formula
  	    { ExistsVars(t,f) }
    | ORMACRO LPAREN var = VAR IN t = evalExp RPAREN COLON f = formula option(ENDOR)
  	    { OrMacro(var,t,f) }
    | ORMACRO LPAREN var = NAME IN t = evalExp RPAREN COLON f = formula option(ENDOR)
  	    { OrMacro(var,t,f) }
    | ANDMACRO LPAREN var = VAR IN t = evalExp RPAREN COLON f = formula option(ENDAND)
    	{ AndMacro(var,t,f) }
    | ANDMACRO LPAREN var = NAME IN t = evalExp RPAREN COLON f = formula option(ENDAND)
    	{ AndMacro(var,t,f) }
    | IMPLYMACRO LPAREN var = VAR IN t = evalExp RPAREN COLON f = formula option(ENDIMPLY)
    	{ ImplyMacro(var,t,f) }
    | IMPLYMACRO LPAREN var = NAME IN t = evalExp RPAREN COLON f = formula option(ENDIMPLY)
    	{ ImplyMacro(var,t,f) }
    | LPAREN var = VAR EQUAL e2 = evalExp RPAREN
        { EqualFormula(Var(var),e2) }
    | LET var = VAR EQUAL t = evalExp INN f = formula
        { Let (var, t, f) }
	| LPAREN var = NAME RPAREN
        { FVar(var) }
    | f1 = formula IMPLY f2 = formula
        { Imply(f1, f2) }
    | f1 = formula AND f2 = formula
        { And(f1, f2) }
    | LPAREN f1 = formula RPAREN AND LPAREN f2 = formula RPAREN
        { And(f1, f2) }

proof:
  | INTROS 
    { Intros }
  | SEARCH 
    { Search }
  | NOP 
    { NoOp }
  | SKIP
    { Skip }
  | name1 = lnp_name COLON CASE name2 = lnp_name 
    { Case(name1, name2) }
  | name1 = lnp_name COLON CASESTAR name2 = lnp_name IN p = proof
    { CaseStar(name1, name2, p) }
  | name1 = lnp_name COLON INDUCTION ON name2 = lnp_name 
    { Induction(name1, name2) }
  | name1 = lnp_name COLON MUTUAL INDUCTION ON name2 = lnp_name name3 = lnp_name DOT FIRST COLON p1 = proof SECOND COLON p2 = proof
    { MutualInduction(name1, name2, name3, p1, p2) }
  | name1 = lnp_name COLON INDUCTIONSTAR ON name2 = lnp_name IN p = proof
      { InductionStar(name1, name2, p) }
  | name1 = lnp_name COLON APPLY name2 = lnp_name TO names = list(lnp_name) instantiation = option(WITH var1 = VAR EQUAL var2 = VAR { (var1, var2) })
      { Apply(name1, name2, names, instantiation) }
  | BACKCHAIN ON name = lnp_name 
      { Backchain(name) }
  | IF t = evalExp THEN p1 = proof ELSE p2 = proof option(ENDIF)
	  { If(t, p1, p2) }
  | FOR EACH var = VAR IN t = evalExp COLON p = proof ENDFOR
      { ForEachProof(var, t, p) }
  | p1 = proof DOT p2 = proof
      { Seq(p1, p2) }

	/*
  | CASE ANALYSIS ON hname = HYPNAME DOT cbs = list(caseBranch)
    { CaseAnalysis(String hname, cbs) }
  | CASE e = hypothesis_complex DOT
    { Case(e) }

hypothesis_complex:
  | hname = HYPNAME
    {String hname}
  | hname = HYPNAME LBRACKET e = evalExp RBRACKET
    {match e with String(suffix) -> String(hname ^ suffix)}

caseBranch:
  | DASH LBRACKET be = bexp RBRACKET COLON listOfproofs = list(proof)
    { (be, makeSeq listOfproofs) }

bexp:
  | e = evalExp IN l = evalExp
    { ListMember(e,l) }
  | e = evalExp IS VAR
    { IsVar e }
  | e = evalExp IS VALUE
    { IsValue e }
  | e = evalExp IS DERIVED
    { IsDerived e }
  | e = evalExp IS ERROR
    { IsError e }
  | e1 = evalExp EQUAL e2 = evalExp
    { EqualBExp(e1,e2) }

(*
  | x = VARLEX
    { VarLO x }
  | e1 = expr UNION e2 = expr
	{ Union(e1, e2) }
  | e = expr EXEC terms = list(term)
    { Exec(e, Constructor(configuration, terms)) }
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr
    { If (e1, e2, e3) }
  | REMOVE LPAREN r = rule RPAREN FROM e = expr
  	{ Remove(r, e) }
  | TRUE
    { TT }
  | FALSE
    { FF }
  | LSQUARE elements = separated_list(CONSLO, expr) RSQUARE
    { makeCons elements }
  | LETREC var = VARLEX typ = typeGrammar VARLEX args = list(typedVar) EQUAL e1 = expr IN e2 = expr
    { if args = [] then LetLO (var, e1, e2) else LetrecLO(var, typ, makeAbstraction args e1, e2) }
  | HEAD e = expr
    { HeadLO(e)}
  | TAIL e = expr
    { TailLO(e)}
  | LPAREN e = expr RPAREN
    { e }
  | LPAREN e1 = expr e2 = expr RPAREN
    { AppLO (e1, e2) }
  | v = valueGr
    { v }

term :
  | LPAREN op = VARLEX termList = list(term) RPAREN
    { Constructor(op, termList) }
  | varname = VARTERM
    { Var(varname) }
  | op = VARLEX
    { detect_var_or_op op }
  | BIND varname = VARLEX t = term
    { Abs(varname,t) }
  | term1 = term LSQUARE term2 = term SUBST
    { Application(term1,term2) }
  | LPAREN SWITCH n = option(INT) e = expr EXEC t = term RPAREN
    { Switch(InheritState (option_to_number n), e, t) }
  | term1 = term COLON term2 = term
    { Constructor(colon, [term1 ; term2]) }
    | NIL
      { Constructor(nil, []) }
    | LSQUARE term1 = termOrColon MID term2 = termOrColon RSQUARE
      { Constructor(cons, [term1 ; term2]) }
    | LSQUARE term1 = termOrColon RSQUARE
        { Constructor(cons, [term1]) }

rule :
  | f = formula
    { Rule([], f) }
  | f = formula PROVIDED formulaList = separated_list(AND, formula)
    { Rule(formulaList, f) }
  | DECLARATIVESUB varianceOpt = option(COLON myvariance = separated_list(MID, variance) { myvariance })
  { let args = option_to_list varianceOpt in Rule([], Formula(declarativeSubtyping, args)) }

formula :
  | f = prefixedFormula
    { f }
  | f = simple_formula
    { f }

prefixedFormula :
  | context = list(term) TURNSTYLE term1 = term COLON term2 = term output_context = list(term)
    { Formula(typing, [Var "GammaLO"] @ context @ [term1 ; term2] @ output_context) }
  | terms1 = list(term) STEP terms2 = list(term)
    { Formula(step, [Constructor(configuration, terms1) ; Constructor(configuration, terms2)]) }
  | term1 = term SUBTYPING term2 = term
    { Formula(subtyping, [term1 ; term2]) }
  | term1 = term IN term2 = term
    { Formula(member, [term1 ; term2]) }

simple_formula :
  | LPAREN pred = VARLEX termList = list(term) RPAREN
    { Formula(pred, termList) }

syntax_category :
	| RELATION GRAMMARASSIGN formulaList = separated_list(MID, formula)
    { ("Relation", ("", embedInSwitch formulaList)) }
	| STARTCALL GRAMMARASSIGN formulaList = separated_list(MID, formula)	 DOT
    { ("StartingCall", ("", embedInSwitch formulaList)) }
  	| category = VARTERM grammarvar = anyvar GRAMMARASSIGN termList = separated_list(MID, term)
    { (category, (grammarvar, termList)) }

rules :
  | ruleList = separated_list(COMMA, rule)
    { ruleList }
alsoRules :
  | COMMA ruleList = rules
    { ruleList }

termOrColon :
  | t = term
    { t }
  | term1 = term COLON term2 = term
    { Constructor(colon, [term1 ; term2]) }
  | NIL
    { Constructor(nil, []) }
  | term1 = termOrColon CONS term2 = termOrColon
    { Constructor(cons, [term1 ; term2]) }

anyvar : | grammarvar = VARLEX { grammarvar } | grammarvar = VARTERM { grammarvar }

stateflag :
  | NEWSTATE { NewState }
  | COPYSTATE n = INT { CopyState n}
  | INHERITSTATE n = INT { InheritState n}

typedVar :
  | var = VARLEX COLON typ = typeGrammar
    { (var, typ) }
  | ACCENT var = VARLEX
    { (var, TVar(var)) }

typeGrammar :
  | t1 = typeGrammar ARROW t2 = typeGrammar
    { TArrow(t1, t2) }
  | STRATEGYTYPE
    { TStrategy }
  | BOOL
    { TBool }
  | myvar = option(ACCENT var = VARLEX UNION { var }) mainLan = language lanToRemove = option(MINUS lanToRemove = language { lanToRemove})
    { TLanguage(language_getSyntax mainLan, language_getRules mainLan, toConstraints myvar lanToRemove) }
  | LPAREN t = typeGrammar RPAREN
    { t }

variance :
  | CONTRA var = VARLEX position = INT
    { (Constructor(contravariant, [Var var ; Var (string_of_int position)] )) }
  | INVAR var = VARLEX position = INT
    { (Constructor(invariant, [Var var ; Var (string_of_int position)] )) }
term:
  | constantOrVar = NAME
    { String constantOrVar }
  | var = HYPNAME
    { VarOfFormula var }
  | LBRACKET e = evalExp RBRACKET
    { e }
  | LPAREN cname = NAME es = list(term) RPAREN
    { Constructor(cname, es) }


*/
