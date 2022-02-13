open Batteries
open List
open Option
open Lnp


let rec print_evalExp t = match t with 
	| Var(var) -> var
	| Num(n) -> string_of_int n
	| Name(cname) -> cname
	| Constructor(cname, ts) -> "(" ^ cname ^ " " ^ (String.concat " " (List.map print_evalExp ts)) ^ ")"
	| ValuesOf(t) -> "valuesOf" ^ "(" ^ print_evalExp t ^ ")"
	| ValueArgs(t) -> "valueArgs" ^ "(" ^ print_evalExp t ^ ")"
	| OfType(t) -> "ofType" ^ "(" ^ print_evalExp t ^ ")"
	| EvaluationOrder(t) -> "evaluationOrder" ^ "(" ^ print_evalExp t ^ ")"
	| GetArgs(t1, t2) -> "getArgs" ^ "(" ^ print_evalExp t1 ^ ", " ^ print_evalExp t2 ^ ")"
	| IsEliminationForm(t) -> "isEliminationForm" ^ "(" ^ print_evalExp t ^ ")"
	| IsErrorHandler(t) -> "isErrorHandler" ^ "(" ^ print_evalExp t ^ ")"
	| GetArgType(t1, t2) -> "getArgType" ^ "(" ^ print_evalExp t1 ^ ", " ^ print_evalExp t2 ^ ")"
	| InList(t1, t2) -> print_evalExp t1 ^ " in " ^ print_evalExp t2
	| EqualTerm(t1, t2) -> print_evalExp t1 ^ " = " ^ print_evalExp t2

let print_lnp_name lnp_name = match lnp_name with 
	| String s -> s
	| SuffixedString(s, t) -> s ^ "_(" ^  print_evalExp t ^ ")"

let rec print_formula formula = match formula with 
	| Top -> "Top"
	| Bottom -> "Bottom"
	| Formula(lnp_name, predname, ts) -> "(" ^ print_lnp_name lnp_name ^ ": " ^ predname ^ " " ^ (String.concat " " (List.map print_evalExp ts)) ^ ")"
	| Forall(var, formula) -> "forall " ^ var ^ ", " ^ print_formula formula
	| Exists(var, formula) -> "exists " ^ var ^ ", " ^ print_formula formula
	| ForallVars(t, formula) -> "forallVars" ^ "(" ^ print_evalExp t ^ ")" ^ ", " ^ print_formula formula
	| ExistsVars(t, formula) -> "existsVars" ^ "(" ^ print_evalExp t ^ ")" ^ ", " ^ print_formula formula
	| EqualFormula(t1, t2) -> print_evalExp t1 ^ " = " ^ print_evalExp t2
	| OrMacro(var, t, formula) -> "OR" ^ "(" ^ var ^ " in " ^ print_evalExp t ^ ")" ^ ": " ^ print_formula formula
	| AndMacro(var, t, formula) -> "AND" ^ "(" ^ var ^ " in " ^ print_evalExp t ^ ")" ^ ": " ^ print_formula formula
	| ImplyMacro(var, t, formula) -> "IMPLY" ^ "(" ^ var ^ " in " ^ print_evalExp t ^ ")" ^ ": " ^ print_formula formula
	| Imply(formula1, formula2) -> print_formula formula1 ^ " -> " ^ print_formula formula2
	| And(formula1, formula2) -> print_formula formula1 ^ " /\\ " ^ print_formula formula2
	| Or(formula1, formula2) -> print_formula formula1 ^ " \\/ " ^ print_formula formula2

let rec print_proof proof = match proof with 
	| Intros -> "intros"
	| Search -> "search"
	| NoOp -> "noOp"
	| Skip -> "skip"
	| Case(lnp_name1, lnp_name2) -> print_lnp_name lnp_name1 ^ ": " ^ "case " ^ print_lnp_name lnp_name2
	| CaseStar(lnp_name1, lnp_name2, proof) -> print_lnp_name lnp_name1 ^ ": " ^ "case* " ^ print_lnp_name lnp_name2 ^ " in " ^ print_proof proof
	| Induction(lnp_name1, lnp_name2) -> print_lnp_name lnp_name1 ^ ": " ^ "induction on " ^ print_lnp_name lnp_name2
	| InductionStar(lnp_name1, lnp_name2, proof) -> print_lnp_name lnp_name1 ^ ": " ^ "induction* on" ^ print_lnp_name lnp_name2 ^ " in " ^ print_proof proof
	| Apply(lnp_name1, lnp_name2, lnp_names) -> print_lnp_name lnp_name1 ^ ": " ^ "apply " ^ print_lnp_name lnp_name2 ^ " to " ^ (String.concat " " (List.map print_lnp_name lnp_names))
	| Backchain(lnp_name) -> "backchain on " ^ print_lnp_name lnp_name
	| If(t, proof1, proof2) -> "if " ^ print_evalExp t ^ " then " ^ print_proof proof1 ^ " else " ^ print_proof proof2
	| ForEachProof(var, t, proof) -> "for each " ^ var ^ " in " ^ print_evalExp t ^ ": " ^ print_proof proof ^ " endfor"
	| Seq(proof1, proof2) -> print_proof proof1 ^ ". " ^ print_proof proof2
 
let print_foreach_preamble iterationOption = 
    if is_some iterationOption then 
		let (var, t) = (get iterationOption) in 
	      "for each " ^ var ^ " in " ^ print_evalExp t ^ ", "
	else "" 

let print_schema (ForEachThm(iterationOption, lnp_name, formula, proof)) =
	let for_each_preamble = print_foreach_preamble iterationOption in 
	for_each_preamble ^ "Theorem " ^ print_lnp_name lnp_name ^ ": " ^ print_formula formula ^ ". \nProof.\n" ^ print_proof proof

let print_list_of_schemas schemas = String.concat "\n\n" (List.map print_schema schemas)