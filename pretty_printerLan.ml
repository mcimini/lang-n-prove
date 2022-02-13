open Batteries
open List
open Option
open Language
open DeclarationsToRules

let generateModPreamble tsName = "module " ^ tsName ^ ".\n\n"

let rec language_prettyPrintTerm t hypotheticalFlag = match t with 
	| Constr(cname, ts) -> "(" ^ cname ^ if ts = [] then ")" else " " ^ (String.concat " " (List.map (language_prettyPrintTerm_map_version hypotheticalFlag) ts)) ^ ")"
	| LangVar(var) -> if hypotheticalFlag && (String.starts_with var "R") then "(" ^ var ^ " x)" else var
	| BoundVar -> "x"
	| BoundTypeVar -> if hypotheticalFlag then "x" else "X"
	| Abs(t) -> "(x)" ^ (language_prettyPrintTerm t hypotheticalFlag)
	| AbsType(t) -> "(x)" ^ (language_prettyPrintTerm t hypotheticalFlag)
	| Substitution(t1,t2,t3) ->  "(" ^ (language_prettyPrintTerm t1 hypotheticalFlag) ^ " " ^ (language_prettyPrintTerm t2 hypotheticalFlag) ^ ")"
and language_prettyPrintTerm_map_version hypotheticalFlag t = language_prettyPrintTerm t hypotheticalFlag

let language_prettyPrintHypotheticalWrap predname arguments = 
	let typeEnv = List.nth arguments 0 in 
	let argsWithoutTypeEnv = List.tl arguments in 
	if term_isConstr typeEnv 
		then let plainFormula = predname ^ " " ^ (String.concat " " (List.map (language_prettyPrintTerm_map_version true) argsWithoutTypeEnv)) in 
				match typeEnv with 
					    | (Constr("gammaAddx", [t])) -> "(pi x\\ typeOf x " ^ (language_prettyPrintTerm t true) ^ " => " ^ plainFormula ^ ")"
						| (Constr("gammaAddX", [])) -> "(pi x\\ " ^ plainFormula ^ ")"
		else predname ^ " " ^ (String.concat " " (List.map (language_prettyPrintTerm_map_version false) argsWithoutTypeEnv))

let language_prettyPrintFormula formula = 
	let predname = formula_getPredname formula in 
	let arguments = formula_getArguments formula in 
	if formula_getPredname formula = "typeOf" 
		then language_prettyPrintHypotheticalWrap predname arguments 
		else predname ^ " " ^ (String.concat " " (List.map (language_prettyPrintTerm_map_version false) arguments))

let language_prettyPrintRule rule = 
	let conclusion = rule_getConclusion rule in 
	let premises = rule_getPremises rule in
	let displayPremises = if premises = [] then "" else " :- " ^ (String.concat ", " (List.map language_prettyPrintFormula premises)) in 
	           (language_prettyPrintFormula conclusion) ^ displayPremises ^ ".\n"

let language_prettyPrintRules lan = 
	(* create a map: op -> its typing rule *)
	let allTypingRules = language_getTypingRules lan in
	let mapOpToTypingRule = List.map (fun rule -> (term_getCNAME (rule_getInputOfConclusion rule), rule)) allTypingRules in 
	let expressionCNAMES = List.map term_getCNAME (language_grammarLookupByCategory lan "Expression") in 
	(* print typing rules as they appear in Expression *)
		String.concat "\n" (List.map (fun e -> language_prettyPrintRule (List.assoc e mapOpToTypingRule)) expressionCNAMES)
		^ let allReductionRules = language_getReductionRules lan in
		String.concat "\n" (List.map language_prettyPrintRule allReductionRules)
		^ String.concat "\n" (List.map language_prettyPrintRule (language_declarationsAsRules lan "Value"))
		^ String.concat "\n" (List.map language_prettyPrintRule (language_declarationsAsRules lan "Error"))
		^ String.concat "\n" (List.map language_prettyPrintRule (language_declarationsAsRules lan "Context"))
		^ String.concat "\n" (List.map language_prettyPrintRule (language_declarationsAsRules lan "ErrorContext"))

let language_prettyPrintExpressions_in_TypingRules_order lan = 
	let allTypingRules = language_getTypingRules lan in
	let expressions = List.map rule_getInputOfConclusion allTypingRules in 
	let grammarItems = List.map (language_prettyPrintTerm_map_version false) expressions  in 
		"Expression E ::= x | " ^ (String.concat " | " grammarItems) ^ "\n"

