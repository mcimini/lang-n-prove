open Batteries
open List
open Option
open Language

(* List.mapi (newEnumbered -1) (term_getArguments t)) *)

let toValueByIndex n = Formula("value", [LangVar("E" ^ string_of_int (n+1))])
let toStepOrErrorByIndex category n = let var = "E" ^ string_of_int (n+1) in if category = "Context" then Formula("step", [LangVar(var) ; LangVar(var ^ "'")]) else Formula("error", [LangVar(var)])
let newEnumbered i t = LangVar("E" ^ string_of_int (i+1))
let newEnumberedWithTick n i t = if i = n then LangVar("E" ^ string_of_int (i+1) ^ "'") else LangVar("E" ^ string_of_int (i+1))

let language_declarationsAsRules lan category = 
	(* category ErrorContext does not exist in the grammar, we derive it from Context minus Error Handler *)
	let grammarItems = if category = "ErrorContext" then language_grammarLookupByCategory lan "Context" else language_grammarLookupByCategory lan category in 
	let grammarItems = if category = "ErrorContext" then List.filter (fun t -> not (language_isErrorHandler lan (term_getCNAME t))) grammarItems else grammarItems in 
	let valuesPositions ts = find_indexes_startsWith ts "V" "v" [] 0 in 
	let contextualPositions ts = find_indexes_startsWith ts "C" "C" [] 0 in 
	let createRule t = 
		let valuePremises = List.map toValueByIndex (valuesPositions (term_getArguments t)) in 
		let stepOrErrorPremises = List.map (toStepOrErrorByIndex category) (contextualPositions (term_getArguments t)) in 
		let termInput = Constr(term_getCNAME t, List.mapi (newEnumbered) (term_getArguments t)) in 
		(match category with 
		| "Value" -> Rule(stepOrErrorPremises @ valuePremises, Formula("value", [termInput]))
		| "Error" -> Rule(stepOrErrorPremises @ valuePremises, Formula("error", [termInput]))
		| "Context" -> 
			let indexToTick = List.hd (contextualPositions (term_getArguments t)) in 
			let termOutput = Constr(term_getCNAME t, List.mapi (newEnumberedWithTick indexToTick) (term_getArguments t)) in 
			Rule(stepOrErrorPremises @ valuePremises, Formula("step", [termInput ; termOutput]))
		| "ErrorContext" -> 
			let termOutput = LangVar ("E" ^ string_of_int (List.hd (contextualPositions (term_getArguments t)) + 1)) in 
			Rule(stepOrErrorPremises @ valuePremises, Formula("step", [termInput ; termOutput]))
		) in 
		List.map createRule grammarItems

let language_generateVarList (args: term list) (prefix: string) (suffix: string): term list =
    List.mapi (fun i _ -> LangVar (prefix ^ string_of_int (i + 1) ^ suffix)) args

let language_termToSubtypeRule (t: term): rule =
    let tname = term_getCNAME t in
    let targs = term_getArguments t in
    let new_vars = language_generateVarList targs "T" "" in
    let new_vars_prime = language_generateVarList targs "T" "'" in
    let conclusion = Formula("subtype", [Constr(tname, new_vars); Constr(tname, new_vars_prime)]) in
    let gen_premise i var =
        let args = match var with
        | LangVar("Cov") -> [List.nth new_vars i; List.nth new_vars_prime i]
        | LangVar("Contra") -> [List.nth new_vars_prime i; List.nth new_vars i]
        | LangVar("AbsCov") -> [List.nth new_vars i; List.nth new_vars_prime i; Constr("abs", [])]
        | LangVar("AbsContra") -> [List.nth new_vars_prime i; List.nth new_vars i; Constr("abs", [])]
        | _ -> raise (Failure(dump var))
        in
        Formula("subtype", args)
    in
    let premises = List.mapi gen_premise targs in
    Rule(premises, conclusion)

let language_subtypeDeclarationsAsRules (lan: language): rule list =
    if language_grammarCatagoryExists lan "Subtyping" then
        let grammarItems = language_grammarLookupByCategory lan "Subtyping" in (* assume all needed terms are present for now *)
        let subsumption_rule = Rule([Formula("typeOf", [LangVar("Gamma"); LangVar("E"); LangVar("S")]); Formula("subtype", [LangVar("S"); LangVar("T")])],
            Formula("typeOf", [LangVar("Gamma"); LangVar("E"); LangVar("T")])) in
        let transitivity_rule = Rule([Formula("subtype", [LangVar("T1"); LangVar("T2")]); Formula("subtype", [LangVar("T2") ; LangVar("T3")])],
            Formula("subtype", [LangVar("T1"); LangVar("T3")])) in
        let reflexivity_rule = Rule([], Formula("subtype", [LangVar("T"); LangVar("T")])) in
        let specific_rules = List.map language_termToSubtypeRule grammarItems in
        (* Later, we want to generate the top rule from the Top grammar line, instead of always "top". *)
        let top_rule = Rule([], Formula("subtype", [LangVar("T"); Constr("top", [])])) in
        top_rule :: specific_rules @ [subsumption_rule; reflexivity_rule; transitivity_rule]
    else []
