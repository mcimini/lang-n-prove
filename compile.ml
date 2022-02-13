open Batteries
open Option
open List
open Lnp
open Language
open Substitution

(* 
	takes fpl_cbv and a theorem schema.
    on fpl_cbv: goes to the 3rd category, which is Value, takes the 3rd operator, which is "pair" 
	and sets the name of the theorem as "pair"
*)
let unusedVar = "_unused_"

let rec langConstructor_to_LNPConstructor (termFromLanguage : term) : evaluatedExpression = match termFromLanguage with 
	| Constr(cname, ts) -> Constructor(cname, List.map langConstructor_to_LNPConstructor ts) 
	| LangVar(var) -> Var(var)
	| Abs(t) -> langConstructor_to_LNPConstructor t (* Here you miss (X)e and just display e *)
	| AbsType(t) -> langConstructor_to_LNPConstructor t 
	| Substitution(t1,t2,t3) -> Constructor("substitution", [])
	(* | _ -> raise(Failure(dump termFromLanguage))*)

type eval_result = 
	| Term of evaluatedExpression
	| ListOfTerms of evaluatedExpression list
	| Number of int 
	| Boolean of bool


let eval_getTerm (Term(evaluatedExpression)) : evaluatedExpression = evaluatedExpression
let eval_getNumber (Number(n)) : int = n
let eval_getBoolean (Boolean(b)) : bool = b
let eval_getListOfTerms (ListOfTerms(l)) = l 
	
let rec eval lan evaluatedExpression : eval_result = match evaluatedExpression with 
	| Var(var2) -> Term(Var(var2)) (* Vars of LNP should already been substituted, but formula's such as forall e, .. (value e) are still there)) *)
	| Num(n) -> Number(n)
	| Name(cname) -> ListOfTerms (List.map langConstructor_to_LNPConstructor (language_grammarLookupByCategory lan cname))
	| Constructor(cname, ts) -> Term (Constructor(cname, ts)) (* no need to have nested terms, just variables suffice. List.map eval_getTerm (List.map (eval lan) ts)) *)
	| ValuesOf(t) -> ListOfTerms (List.map langConstructor_to_LNPConstructor (language_getValuesByType lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| ValueArgs(t) -> ListOfTerms (List.map langConstructor_to_LNPConstructor (language_getValueArgs lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| OfType(t) -> Term (langConstructor_to_LNPConstructor (language_getTypeByOp lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| IsVar(t) -> Boolean (term_isVar (eval_getTerm (eval lan t)) || term_isSubstitution (eval_getTerm (eval lan t)))
	| IsSingleValue(t) -> Boolean (List.length (eval_getListOfTerms (eval lan (ValuesOf(t)))) <= 1)
	| TargetV(t) -> ListOfTerms (List.map langConstructor_to_LNPConstructor (language_getTargetValuesFromVars lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| TargetOp(t) -> ListOfTerms (List.map langConstructor_to_LNPConstructor (language_getTargetValuesFromOp lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| ContainsSub(t) -> Boolean (term_constains_substitution (eval_getTerm (eval lan t)))
	| EvaluationOrder(t) -> ListOfTerms (List.map numberToNumTerm (language_getEvaluationOrderForOp lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| ContextualArgs(t) -> ListOfTerms (List.map numberToNumTerm (language_getContextualArgs lan (term_getConstructorName (eval_getTerm (eval lan t)))))
	| GetArgs(t1, t2) -> Term (term_getNthArg (eval_getTerm (eval lan t1)) (eval_getNumber (eval lan t2)))
	| IsEliminationForm(t) -> Boolean (language_isEliminationForm lan (term_getConstructorName (eval_getTerm (eval lan t))))
	| IsErrorHandler(t) -> Boolean (language_isErrorHandler lan (term_getConstructorName (eval_getTerm (eval lan t))))
	| GetArgType(t1, t2) -> let typeTermFromLanguage = (language_getTypeOfNthArg lan (term_getConstructorName (eval_getTerm (eval lan t1))) (eval_getNumber (eval lan t2)))
								in Term (langConstructor_to_LNPConstructor typeTermFromLanguage)
	| InList(t1, t2) -> Boolean (term_list_mem (eval_getTerm (eval lan t1)) (eval_getListOfTerms (eval lan t2)))
	| IS(t1, t2) -> (Boolean (term_list_mem_upToNumbers (eval_getTerm (eval lan t1)) (eval_getListOfTerms (eval lan t2))))  
	| EqualTerm(t1, t2) -> (match (eval lan t1),(eval lan t2)  with 
							| Term(Constructor(cname1, _)), Term(Constructor(cname2, _)) -> Boolean (cname1 = cname2)
							| Number(n1), Number(n2) -> Boolean (n1 = n2) 
							| _ -> Boolean false )
	| OrTerm(t1, t2) -> Boolean (eval_getBoolean (eval lan t1) || eval_getBoolean (eval lan t2))
	| AndTerm(t1, t2) -> Boolean (eval_getBoolean (eval lan t1) && eval_getBoolean (eval lan t2))

let compile_lnp_name lan lnp_name = match lnp_name with 
	| SuffixedString(str, evaluatedExpression) -> let suffix = (match eval lan evaluatedExpression with 
														| Term((Constructor(cname, ts))) -> cname
														| Number(n) -> string_of_int n
														| _ -> "Wrong term computed as suffix to append to a name")
													in String (str ^ suffix)
	| _ -> lnp_name
	
let rec compile_formula lan formula = match formula with 
	| Top -> Top
	| Bottom -> Bottom
	| Formula(lnp_name, predname, ts) -> Formula(compile_lnp_name lan lnp_name, predname, List.map eval_getTerm (List.map (eval lan) ts))
	| Forall(var2, formula) -> Forall(var2, compile_formula lan formula)
	| Exists(var2, formula) -> Exists(var2, compile_formula lan formula)
	| ForallVars(t, formula) -> makeForall (term_getVars (eval_getTerm (eval lan t))) (compile_formula lan formula)
	| ExistsVars(t, formula) -> makeExists (term_getVars (eval_getTerm (eval lan t))) (compile_formula lan formula)
	| EqualFormula(t1, t2) -> EqualFormula(eval_getTerm (eval lan t1), eval_getTerm (eval lan t2))
	| OrMacro(var2, t, formula) -> let formulaeInstantiated = List.map (substitution_formula formula var2) (eval_getListOfTerms (eval lan t)) in makeOr (List.map (compile_formula lan) formulaeInstantiated)
	| AndMacro(var2, t, formula) -> let formulaeInstantiated = List.map (substitution_formula formula var2) (eval_getListOfTerms (eval lan t)) in makeAnd (List.map (compile_formula lan) formulaeInstantiated)
	| ImplyMacro(var2, t, formula) -> let formulaeInstantiated = List.map (substitution_formula formula var2) (eval_getListOfTerms (eval lan t)) in makeImply (List.map (compile_formula lan) formulaeInstantiated)
	| Imply(formula1, formula2) ->  if compile_formula lan formula2 = Top then compile_formula lan formula1 else Imply(compile_formula lan formula1, compile_formula lan formula2)
	| And(formula1, formula2) -> if compile_formula lan formula2 = Top then compile_formula lan formula1 else And(compile_formula lan formula1, compile_formula lan formula2)
	| Or(formula1, formula2) -> if compile_formula lan formula2 = Bottom then compile_formula lan formula1 else Or(compile_formula lan formula1, compile_formula lan formula2)
	
let rec compile_proof lan names proof = match proof with 
| Intros -> Intros
| Search -> Search
| NoOp -> NoOp
| Skip -> Skip
| Case(lnp_name1, lnp_name2) -> Case(compile_lnp_name lan lnp_name1, compile_lnp_name lan lnp_name2)
| CaseStar(lnp_name1, lnp_name2, proof) -> NoOp
| Induction(lnp_name1, lnp_name2) -> Induction(compile_lnp_name lan lnp_name1,compile_lnp_name lan lnp_name2)
| InductionStar(lnp_name1, lnp_name2, proof) -> NoOp
| Apply(lnp_name1, lnp_name2, lnp_names) -> Apply(compile_lnp_name lan lnp_name1, compile_lnp_name lan lnp_name2, List.map (compile_lnp_name lan) lnp_names)
| Backchain(lnp_name) -> Backchain(compile_lnp_name lan lnp_name)
| If(t, proof1, proof2) -> if eval_getBoolean (eval lan t) then compile_proof lan names proof1 else compile_proof lan names proof2
| ForEachProof(var, t, proof) -> makeSeq (List.map (compile_proof lan names) (List.map (substitution_proof proof var) (eval_getListOfTerms (eval lan t))))
| Seq(proof1, proof2) -> if compile_proof lan names proof1 = NoOp then compile_proof lan names proof2 else Seq(compile_proof lan names proof1, compile_proof lan names proof2)

let compileInstantiated lan schema = 
	ForEachThm(None, compile_lnp_name lan (schema_getTheoremName schema), compile_formula lan (schema_getTheorem schema), compile_proof lan (map_names_formulae_in_theorem (schema_getTheorem schema)) (schema_getProof schema))
	
let compile lan schema : schema list = 
	let (var, substList) : (string * (evaluatedExpression list)) = 
		if is_none (schema_getIteration schema) then (unusedVar, [Var "Just one element list"]) (* This is an ineffectul substitution, will create ONE version of the theorem *)
			else let (var, t) =  get (schema_getIteration schema) in (var, (eval_getListOfTerms (eval lan t)))
														(* substitution_schema also removes the Iteration part of the theorem (for each ...)  *)
		in List.map (compileInstantiated lan) (List.map (substitution_schema schema var) substList)
	
	
let testManipulation lan schema = 
	match lan with Language(g1 :: g2 :: g3 :: rest, _) -> 
		match schema with ForEachThm(ite, lnp_name, formula, proof) -> 
			match g3 with GrammarLine(category, metavar, items) -> 
				match List.nth (Option.get items) 2 with Constr(opname,ts) -> 
					ForEachThm(ite, String opname, formula, proof) 

	(*	| Imply(formula1, formula2) ->  Imply(compile_formula lan formula1, compile_formula lan formula2)
		| And(formula1, formula2) -> And(compile_formula lan formula1, compile_formula lan formula2)
		| Or(formula1, formula2) -> Or(compile_formula lan formula1, compile_formula lan formula2)
	*)
