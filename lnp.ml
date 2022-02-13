open Batteries
open String 

type var = string
type name = string
type predname = string
type cname = string

type lnp_name = 
	| String of string
	| SuffixedString of string * evaluatedExpression
and evaluatedExpression =
  | Var of var
  | Num of int 
  | Name of cname 
  | Constructor of cname * evaluatedExpression list
  | ValuesOf of evaluatedExpression 
  | ValueArgs of evaluatedExpression 
  | OfType of evaluatedExpression 
  | IsVar of evaluatedExpression (* not in use *)
  | IsSingleValue of evaluatedExpression 
  | TargetV of evaluatedExpression 
  | TargetOp of evaluatedExpression 
  | ContainsSub of evaluatedExpression 
  | EvaluationOrder of evaluatedExpression
  | ContextualArgs of evaluatedExpression
  | GetArgs of evaluatedExpression * evaluatedExpression
  | IsEliminationForm of evaluatedExpression
  | IsErrorHandler of evaluatedExpression
  | GetArgType of evaluatedExpression * evaluatedExpression
  | InList of evaluatedExpression * evaluatedExpression
  | EqualTerm of evaluatedExpression * evaluatedExpression  
  | IS of evaluatedExpression * evaluatedExpression
  | OrTerm of evaluatedExpression * evaluatedExpression  
  | AndTerm of evaluatedExpression * evaluatedExpression  
  
type formula =
  | Top
  | Bottom
  | Formula of lnp_name * predname * evaluatedExpression list
  | Forall of var * formula
  | Exists of var * formula
  | ForallVars of evaluatedExpression * formula
  | ExistsVars of evaluatedExpression * formula
  | EqualFormula of evaluatedExpression * evaluatedExpression
  | OrMacro of var * evaluatedExpression * formula
  | AndMacro of var * evaluatedExpression * formula
  | ImplyMacro of var * evaluatedExpression * formula
  | Imply of formula * formula
  | And of formula * formula
  | Or of formula * formula


type proof =
  | Intros
  | Search
  | NoOp
  | Skip
  | Case of lnp_name * lnp_name 
  | CaseStar of lnp_name * lnp_name * proof (* not in use *)
  | Induction of lnp_name * lnp_name 
  | InductionStar of lnp_name * lnp_name * proof (* not in use *)
  | Apply of lnp_name * lnp_name * lnp_name list
  | Backchain of lnp_name 
  | If of evaluatedExpression * proof * proof
  | ForEachProof of var * evaluatedExpression * proof
  | Seq of proof * proof


type schema = ForEachThm of ((var * evaluatedExpression) option) * lnp_name * formula * proof 

let schema_getIteration schema = match schema with ForEachThm(iterationOption, lnp_name, formula, proof) -> iterationOption
let schema_getTheoremName schema = match schema with ForEachThm(iterationOption, lnp_name, formula, proof) -> lnp_name 
let schema_getTheorem schema = match schema with ForEachThm(iterationOption, lnp_name, formula, proof) -> formula 
let schema_getProof schema = match schema with ForEachThm(iterationOption, lnp_name, formula, proof) -> proof 

let rec makeForall vars formula = match vars with
  | [] -> formula
  | (var::rest) -> Forall(var, makeForall rest formula)

let rec makeExists vars formula = match vars with
  | [] -> formula
  | (var::rest) -> Exists(var, makeExists rest formula)

let rec makeOr formulas = match formulas with
  | [] -> Bottom
  | (f::rest) -> if rest = [] then f else Or(f, makeOr rest)

let rec makeImply formulas = match formulas with
  | [] -> Top
  | (f::rest) -> if rest = [] then f else Imply(f, makeImply rest)

let rec makeAnd formulas = match formulas with
  | [] -> Top
  | (f::rest) -> if rest = [] then f else And(f, makeAnd rest)

let rec makeSeq proofs = match proofs with
  | [] -> NoOp
  | (proof::rest) -> if rest = [] then proof else Seq(proof, makeSeq rest)

let term_isVar exp = match exp with | Var(_) -> true | _ -> false
let term_isSubstitution exp = match exp with
	  	| Constructor(cname, evaluatedExpressions) -> cname = "substitution"
		| _ -> false

let term_getConstructorName exp = match exp with
  | Constructor(cname, evaluatedExpressions) -> cname
  | _ -> raise(Failure(dump exp))

let term_getArguments exp = match exp with
	| Constructor(cname, evaluatedExpressions) -> evaluatedExpressions
	| _ -> raise(Failure(dump exp))

let rec term_getVars exp = match exp with
  | Var(name) -> [name]
  | Constructor(cname, evaluatedExpressions) -> List.concat (List.map term_getVars evaluatedExpressions)

let term_getNthArg (Constructor(cname, ts)) n = List.nth ts n

let rec term_constains_substitution t : bool = match t with 
	| Constructor(cname,ts) -> if cname = "substitution" then true else List.exists term_constains_substitution ts
	| _ -> false

	
let term_list_mem exp listOfexps : bool = List.mem (term_getConstructorName exp) (List.map term_getConstructorName listOfexps)
let term_list_mem_upToNumbers exp listOfexps : bool = 
	let foundItem = List.filter (fun t -> term_list_mem exp [t]) listOfexps in 
	if foundItem = [] then false else let foundItem = List.hd foundItem in 
	(* We also need to match E1 with R1.  *)
	let equalupToNumbers (Var(var1),Var(var2)) : bool = 
	(*	let t = raise(Failure("equalupToNumbers: " ^ var1 ^ (String.make 1 (String.get var1 0)) ^ var2 ^ (String.make 1 (String.get var2 0)) ^ (string_of_bool (String.starts_with var2 "R"))))  in 
String.get var1 0 = String.get var2 0 || String.get var1 0 = 'R' || String.get var2 1 = 'R') in *)
			(String.starts_with var1 "R" || String.starts_with var1 (String.make 1 (String.get var2 0)) || 
			 String.starts_with var2 "R" || String.starts_with var2 (String.make 1 (String.get var1 0))) in  
		List.for_all equalupToNumbers (List.combine (term_getArguments exp) (term_getArguments foundItem))

let numberToNumTerm n = Num n 

	(* map_names_formulae_in_theorem formula is the list (name, theorem) *)
let rec map_names_formulae_in_theorem formula = match formula with
	| Formula(String s, predname, ts) -> if s = "_" then [] else [(s, Formula(String s, predname, ts))]
	| Imply(formula1, formula2) -> map_names_formulae_in_theorem formula1 @ map_names_formulae_in_theorem formula2
	| Forall(var, formula) -> map_names_formulae_in_theorem formula
	| Exists(var, formula) -> map_names_formulae_in_theorem formula
	| _ -> []

