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
