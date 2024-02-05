open Batteries
open Option
open List

let explicit_tenv = true

type term = 
	| Constr of string * (term list)
	| LangVar of string
	| BoundVar 
	| BoundTypeVar 
	| Abs of term
	| AbsType of term
	| Substitution of term * term * term 

type grammarLine = GrammarLine of string * (string option) * ((term list) option)

type formula = Formula of string * (term list)

type rule = Rule of (formula list) * formula

type language = Language of (grammarLine list) * (rule list) 

let grammarLine_getCategory (GrammarLine(cname, _, _)) = cname
let grammarLine_getMetavarOption (GrammarLine(_, metavarOption, _)) = metavarOption
let grammarLine_getItemsOption (GrammarLine(_, _, itemsOption)) = itemsOption

let term_getCNAME (Constr(cname,_)) = cname 
let term_getArguments (Constr(_,ts)) = ts 

(* let term_getCNAME t = match t with 
	| Constr(cname,_) -> cname
	| _ -> raise(Failure(dump t))
*)

let term_isConstr t = match t with 
	| Constr(cname,_) -> true
	| _ -> false

let termLan_list_mem t listOfTerms : bool =
    if term_isConstr t then
        List.mem (term_getCNAME t) (List.map term_getCNAME (List.filter term_isConstr listOfTerms))
    else
        false

let termLan_list_mem_map_version listOfTerms t = termLan_list_mem t listOfTerms

let list_difference a b = let notpresent x = not (List.mem x b) in List.filter notpresent a
	
let compareConstructors t1 t2 = termLan_list_mem t1 [t2]

let language_getGrammar (Language(grammar, _)) = grammar
let language_getRules (Language(_, rules)) = rules
let language_addRules (Language(grammar, rest)) rules = Language(grammar, rest @ rules)

let rule_getInputOfConclusion (Rule(_,Formula(predname,ts))) =
    if predname = "typeOf" || predname = "typeOfA" then List.nth ts 1 else List.hd ts
let rule_getOutputOfConclusion (Rule(_,Formula(_,ts))) = List.last ts
let rule_getPremises (Rule(premises,_)) = premises
let rule_getConclusion (Rule(_,conclusion)) = conclusion
let rule_getConclusionPredname (Rule(_,Formula(predname,_))) = predname

let formula_getArguments (Formula(predname,ts)) = ts
let formula_getPredname (Formula(predname,_)) = predname


(* let rule_isOf t (Rule(_,Formula(_,ts))) = true compareConstructors t (List.hd ts) *)
let rule_ProvesOp t (Rule(_,Formula(_,ts))) = compareConstructors t (List.last ts)
let language_getRulesOfOp lan cname = List.filter (fun r -> compareConstructors (rule_getInputOfConclusion r) (Constr(cname,[]))) (language_getRules lan)

let rule_isPredname predname (Rule(_,Formula(predname2,_))) = predname = predname2

let rec term_subst t1 var term =
    let subst t = term_subst t var term in
    match t1 with
	| Constr(cname, args) -> Constr(cname, List.map subst args)
    | LangVar(v) when v = var -> term
    | LangVar(v) -> t1
	| BoundVar -> BoundVar
	| BoundTypeVar -> BoundTypeVar
	| Abs(t1) -> Abs(subst t1)
	| AbsType(t1) -> AbsType(subst t1)
	| Substitution(t1, t2, t3) -> Substitution(subst t1, subst t2, subst t3)

let formula_subst (Formula(pred, args)) var term =
    let subst t = term_subst t var term in
    Formula(pred, List.map subst args)

let rule_substitution (Rule(premises, conclusion)) var term =
    let subst f = formula_subst f var term in
    Rule(List.map subst premises, subst conclusion)

let language_getTypingRules lan = List.filter (rule_isPredname "typeOf") (language_getRules lan)
let language_getReductionRules lan = List.filter (rule_isPredname "step") (language_getRules lan)

let numbers_to_metavariables (Constr(cname,ts)) = 
	let insert_number_to_var i t = (match t with 
			| LangVar(var) -> LangVar(var ^ (string_of_int (i+1))) 
			| Abs(LangVar(var)) -> Abs(LangVar(var ^ (string_of_int (i+1))))
			| AbsType(LangVar(var)) -> AbsType(LangVar(var ^ (string_of_int (i+1))))
			| _ -> t) 
	 in Constr(cname, List.mapi insert_number_to_var ts)

let language_grammarCatagoryExists lan cname : bool =
	 let grammarLine = List.filter (fun grLine -> cname = (grammarLine_getCategory grLine)) (language_getGrammar lan) in 
     not (grammarLine = [])

(* cname is a grammar syntactic category, example: Expression, Type *)
let language_grammarLookupByCategory lan cname : term list = 
	 let grammarLine = List.filter (fun grLine -> cname = (grammarLine_getCategory grLine)) (language_getGrammar lan) in 
	 if grammarLine = [] then [] else 
	 if is_none (grammarLine_getItemsOption (List.hd grammarLine)) then [] else 
		 let grammarItems = List.filter term_isConstr (get (grammarLine_getItemsOption (List.hd grammarLine))) in 
	 	if cname = "Value" || cname = "Context" || cname = "Subtyping"  (* vars in Value are already numbered, Contexts and Subtyping do not need to get a number *)
			then grammarItems 
			else List.map numbers_to_metavariables grammarItems

(* cname is a type constructor, example: list, arrow *)
let language_getValuesByType lan cname : term list = 
	let allValues = language_grammarLookupByCategory lan "Value" in 
	let rulesThatProveCNAME = List.filter (rule_ProvesOp (Constr(cname,[]))) (language_getRules lan) in 
	let allOperatorsWithTypeCNAME = List.map rule_getInputOfConclusion rulesThatProveCNAME in 
	let allValuesWithTypeCNAME = List.filter (fun t -> termLan_list_mem t allValues) allOperatorsWithTypeCNAME in  (* only those that are in allValues *) 
	(* though we need to return values from Value, not rules, therefore here below *)
	  List.filter (fun t -> termLan_list_mem t allValuesWithTypeCNAME) allValues   

(* cname is an expression constructor which is in grammar Value, example: abs, pair *)
let language_getValueArgs lan cname : term list = 
	let allValues = language_grammarLookupByCategory lan "Value" in 
	let itemOfCNAME = List.hd (List.filter (fun t -> compareConstructors t (Constr(cname,[]))) allValues) in 
	(* let j = if cname = "pair" then raise(Failure(dump itemOfCNAME)) else 3 in *)  
	let isArg_a_value arg = (match arg with 
			| LangVar(var) -> (String.starts_with var "v" || String.starts_with var "V") 
			| _ -> false) in 
	  List.filter isArg_a_value (term_getArguments itemOfCNAME) 


let language_getTargetValuesFromVars lan cname : term list = 
	let stepRulesOfCname = List.filter (rule_isPredname "step") (language_getRulesOfOp lan cname) in 
	let principalArgAndTarget = List.map (fun rule -> (List.nth (term_getArguments (rule_getInputOfConclusion rule)) 0, (rule_getOutputOfConclusion rule))) stepRulesOfCname in 
	let pAndTonlyVars = List.filter (fun (arg,_) -> not (term_isConstr arg)) principalArgAndTarget in
	let res = List.map snd pAndTonlyVars in 
	res (*
		 if cname = "fix" then raise(Failure(dump res)) else res *)

let language_getTargetValuesFromOp lan cname : term list = 
	let stepRulesOfCname = List.filter (rule_isPredname "step") (language_getRulesOfOp lan cname) in 
	let principalArgAndTarget = List.map (fun rule -> (List.nth (term_getArguments (rule_getInputOfConclusion rule)) 0, (rule_getOutputOfConclusion rule))) stepRulesOfCname in 
	let pAndTonlyConstr = List.filter (fun (arg,_) -> term_isConstr arg) principalArgAndTarget in
	let res = List.map snd pAndTonlyConstr in 
	res (*
		 if cname = "fix" then raise(Failure(dump res)) else res *)
			


	  (* cname is an expression constructor which is in grammar Expression, example: abs, pair *)
let language_getTypeByOp lan cname : term =   
	let allRulesOfCNAME = language_getRulesOfOp lan cname in 
	let ruleOfCNAME = List.hd (List.filter (rule_isPredname "typeOf") allRulesOfCNAME) in 
	(* let j = if cname = "appT" then raise(Failure(dump (rule_getOutputOfConclusion ruleOfCNAME))) else 3 in  *)
	  rule_getOutputOfConclusion ruleOfCNAME

let removeDuplicates(list') =
	let rec removeDuplicatesHelper(list) = match List.rev(list) with
		| []->[]
		| (head :: tail) -> if List.mem head tail then
		                removeDuplicatesHelper(List.rev(tail))
		               else [head]@removeDuplicatesHelper(List.rev(tail))
	in List.rev(removeDuplicatesHelper(list'));;

exception Contexts_are_cyclic
let rec topo_aux wholegraph path visited currentnode = 
	if List.mem currentnode path 
		then raise Contexts_are_cyclic (* Found a cycle *)
		else try let eds = List.assoc currentnode wholegraph in (currentnode :: (List.fold_left (topo_aux wholegraph (currentnode :: path)) visited eds)) with Not_found -> visited
and dfs wholegraph visited node = topo_aux wholegraph [] visited node
and topo_compute_order graph = 
let callaux visited pair = dfs graph visited (fst pair) in  
		removeDuplicates (List.rev (List.fold_left callaux [] graph))

let rec find_indexes l el indexes n = if l = [] then indexes else if List.hd l = el then find_indexes (List.tl l) el (n :: indexes) (n+1) else find_indexes (List.tl l) el indexes (n+1)  
let rec find_indexes_startsWith l el1 el2 indexes n = if l = [] then indexes else let LangVar(var) = (List.hd l) in if String.starts_with var el1 || String.starts_with var el2 then find_indexes_startsWith (List.tl l) el1 el2 (n :: indexes) (n+1) else find_indexes_startsWith (List.tl l) el1 el2 indexes (n+1) 

let ctx_oneCTX_toEdge (Constr(_,ts)) = 
		(List.hd (find_indexes ts (LangVar("C")) [] 0), (find_indexes ts (LangVar("v")) [] 0))

let language_getGraphOfCTX lan cname = 
	let allCTXs = List.filter term_isConstr (language_grammarLookupByCategory lan "Context") in 
	let ctxsOfCNAME = List.filter (fun t -> compareConstructors t (Constr(cname,[]))) allCTXs in 
	 	List.map ctx_oneCTX_toEdge ctxsOfCNAME  

			(* cname is an expression constructor, example: app, pair *)
let language_getEvaluationOrderForOp lan cname : int list = 
	(* raise(Failure(dump (topo_compute_order [(0,[]) ; (1,[0]) ; (2,[0;1])]))) *)
	  topo_compute_order (language_getGraphOfCTX lan cname)

let language_getContextualArgs lan cname : int list = 
		List.map fst (language_getGraphOfCTX lan cname)
	
(* cname is an expression constructor, example: app, pair *)
let language_isEliminationForm lan cname : bool = 
	let allRulesOfCNAME = language_getRulesOfOp lan cname in 
	let rulesOfCNAME = List.filter (rule_isPredname "step") allRulesOfCNAME in 
	if rulesOfCNAME = [] then false else 
		let principalArguments = List.map List.hd (List.map term_getArguments (List.map rule_getInputOfConclusion rulesOfCNAME)) in 
			List.exists (termLan_list_mem_map_version (language_grammarLookupByCategory lan "Value")) (List.filter term_isConstr principalArguments)
				

(* cname is an expression constructor, example: app, pair *)
let language_isErrorHandler lan cname : bool = 
	let allRulesOfCNAME = language_getRulesOfOp lan cname in 
	let rulesOfCNAME = List.filter (rule_isPredname "step") allRulesOfCNAME in 
	if rulesOfCNAME = [] then false else 
		let principalArguments = List.map List.hd (List.map term_getArguments (List.map rule_getInputOfConclusion rulesOfCNAME)) in 
			List.exists (termLan_list_mem_map_version (language_grammarLookupByCategory lan "Error")) (List.filter term_isConstr principalArguments)

(* cname is an expression constructor, example: app, pair 
   returns the top-level type constructor as a string. 
*)
let language_getTypeOfNthArg lan cname n : term = 
	let allRulesOfCNAME = language_getRulesOfOp lan cname in 
	let ruleOfCNAME = List.hd (List.filter (rule_isPredname "typeOf") allRulesOfCNAME) in 
	let typingCallOfNTH = List.nth (rule_getPremises ruleOfCNAME) n in  
	 rule_getOutputOfConclusion (Rule([],typingCallOfNTH)) 
		 (* I reuse rule_getOutputOfConclusion, not to implement formula_getOutputOfConclusion *)

let tmp_name_fix lan (elim: string) (value: string) : term =
    let rules = List.filter (rule_isPredname "step") (language_getRulesOfOp lan elim) in
    let things = (List.filter
        (fun rule -> match (rule_getInputOfConclusion rule) with
            | Constr(_, Constr(cname,_) :: _) when cname = value -> true
            | _ -> false)
        rules) in
    if things = [] then raise (Failure(elim ^ " " ^ value)) else
    rule_getOutputOfConclusion (List.hd things)
(*

let language_getTypingRuleOfOp lan opname = List.filter (rule_isPredname "typeOf") (language_getRules lan)
*)
