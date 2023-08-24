open Batteries
open List
open Option
open Lnp
open Pretty_printer
open Language

let rec abella_evalExp t = match t with 
	| Var(var) -> var
	| Name(cname) -> cname
	| Constructor(cname, ts) -> if cname = "expBinding" then
                        "(" ^ abella_evalExp (List.hd ts) ^ " x)"
                else
                        "(" ^ cname ^ if ts = [] then ")" else " " ^ (String.concat " " (List.map abella_evalExp ts)) ^ ")"
	| EqualTerm(t1, t2) -> abella_evalExp t1 ^ " = " ^ abella_evalExp t2
	| Num(n) -> "UNRECOGNIZED: Integer not inserted as string in a term"
	| ValuesOf(t) -> "UNRECOGNIZED"
	| ValueArgs(t) -> "UNRECOGNIZED"
	| EvaluationOrder(t) -> "UNRECOGNIZED"
	| GetArgs(t1, t2) -> "UNRECOGNIZED"
	| IsEliminationForm(t) -> "UNRECOGNIZED"
	| IsErrorHandler(t) -> "UNRECOGNIZED"
	| GetArgType(t1, t2) -> "UNRECOGNIZED"
	| InList(t1, t2) -> "UNRECOGNIZED"

let rec abella_evalExp_noBinding t = match t with 
	| Constructor(cname, ts) -> if cname = "expBinding" then
                        abella_evalExp_noBinding (List.hd ts)
                else
                        "(" ^ cname ^ if ts = [] then ")" else " " ^ (String.concat " " (List.map abella_evalExp_noBinding ts)) ^ ")"
	| EqualTerm(t1, t2) -> abella_evalExp_noBinding t1 ^ " = " ^ abella_evalExp_noBinding t2
    | _ -> abella_evalExp t

let abella_lnp_name lnp_name = match lnp_name with 
	| String s -> s
	| _ -> "UNRECOGNIZED: code generation requires a resolved lnp_name"

let rec abella_formula formula = match formula with 
	| Top -> "true"
	| Bottom -> "false"
	(* Formula are not given a name in the theorem, formulae also come from .mod so they are around brackets { and }  *)
	| Formula(lnp_name, predname, ts) -> begin
        match predname with
        | "typeOf" -> begin
            let gamma = if explicit_tenv then " " ^ abella_evalExp (List.nth ts 0) else "" in
            match List.hd ts with
            | (Constructor("gammaAddx", [e])) -> "(nabla (x: term), {typeOf x " ^ (abella_evalExp e) ^ " => " ^
                predname ^ gamma ^ " (" ^ (abella_evalExp (List.nth ts 1)) ^ " x) " ^ (abella_evalExp (List.nth ts 2)) ^ "})"
            | (Constructor("gammaAddX", _)) -> "(nabla (X: typ), {" ^
                predname ^ gamma ^ " (" ^ (abella_evalExp (List.nth ts 1)) ^ " X) (" ^ (abella_evalExp (List.nth ts 2)) ^ " X)})"
            | _ -> "{" ^ predname ^ gamma ^ " " ^ (String.concat " " (List.map abella_evalExp_noBinding (List.tl ts))) ^ "}"
        end
        | "subtype" when List.length ts = 3 ->
            "(nabla (X: typ), {subtype (" ^
            abella_evalExp (List.nth ts 0) ^ " X) (" ^
            abella_evalExp (List.nth ts 1) ^ " X)})"
        | _ ->
            let plainFormula = predname ^ " " ^ (String.concat " " (List.map abella_evalExp_noBinding ts)) in 
            if predname = "progresses" then plainFormula else "{" ^ plainFormula ^ "}"
    end
	| Forall(var, formula) -> "forall " ^ var ^ ", " ^ abella_formula formula
	| Exists(var, formula) -> "exists " ^ var ^ ", " ^ abella_formula formula
	| EqualFormula(t1, t2) -> abella_evalExp t1 ^ " = " ^ abella_evalExp t2
	| Imply(formula1, formula2) -> abella_formula formula1 ^ " -> " ^ abella_formula formula2
	| And(formula1, formula2) -> "(" ^ abella_formula formula1 ^ ") /\\ (" ^ abella_formula formula2 ^ ")"
	| Or(formula1, formula2) -> "(" ^ abella_formula formula1 ^ ") \\/ (" ^ abella_formula formula2 ^ ")"
	| ForallVars(t, formula) -> "UNRECOGNIZED: ForallVars in theorem"
	| ExistsVars(t, formula) -> "UNRECOGNIZED: ExistsVars in theorem"
	| OrMacro(var, t, formula) -> "UNRECOGNIZED: OrMacro in theorem"
	| AndMacro(var, t, formula) -> "UNRECOGNIZED: AndMacro in theorem"
	| ImplyMacro(var, t, formula) -> "UNRECOGNIZED: ImplyMacro in theorem"

let rec abella_proof (names: (string * int) list) proof = match proof with 
	(* Intros Main Value. where names come from the theorem in names = list of strings  *)
	| Intros -> "intros " ^ (String.concat " " (List.map fst names)) ^ ". "
	| Search -> "search" ^ ". "
	| NoOp -> "" (* NoOp are ignored *)
	| Skip -> "skip"  ^ ". "
	(* If the name of new hypothesis is not given, then just prints "case Hyp" rather than Hyp1: case Hyp2  *)
	| Case(lnp_name1, lnp_name2) -> 
		let plainInstr = "case " ^ abella_lnp_name lnp_name2 ^ ". "in 
		if print_lnp_name lnp_name1 = "_" then plainInstr else abella_lnp_name lnp_name1 ^ ": " ^ plainInstr 
	(* If the name of new hypothesis is not given, then just prints "indiction on Hyp ..." rather than Hyp1: indiction on Hyp2 ... *)
	| Induction(lnp_name1, lnp_name2) -> 
		let hypothesisMiddle = if print_lnp_name lnp_name1 = "_" then "" else abella_lnp_name lnp_name1 ^ ": " in 
		  "IH0 : induction on 1. " ^ (abella_proof names Intros) ^ hypothesisMiddle ^ "case " ^ abella_lnp_name lnp_name2 ^ ". " (* to be computed. Always 1 for now. "induction on " ^ abella_lnp_name lnp_name2 in *)		
	| MutualInduction(lnp_name1, lnp_name2, lnp_name3, proof1, proof2) -> 
        let [name1; name2; name3] = List.map abella_lnp_name [lnp_name1; lnp_name2; lnp_name3] in
        let case n2 = (abella_proof names Intros) ^ "\n" ^ (abella_proof names (Case(lnp_name1, n2))) in
        "IH0 : induction on " ^ string_of_int (List.assoc name2 names) ^ " " ^ string_of_int (List.assoc name3 names) ^ ". split.\n" ^ case lnp_name2 ^ "\n" ^ (abella_proof names proof1) ^ "\n" ^ case lnp_name3 ^ "\n" ^ (abella_proof names proof2) ^ "\n"
	(* If the name of new hypothesis is not given, then just prints "apply Hyp ..." rather than Hyp1: apply Hyp2 ... *)
	| Apply(lnp_name1, lnp_name2, lnp_names, inst) -> 
        let with_clause = match inst with
        | None -> ""
        | Some (var1, var2) -> " with " ^ var1 ^ " = " ^ var2
        in
		let plainInstr = "apply " ^ abella_lnp_name lnp_name2 ^
            begin if lnp_names = [] then "" else
                " to " ^ (String.concat " " (List.map abella_lnp_name lnp_names)) end ^ with_clause ^ "." in 
		if print_lnp_name lnp_name1 = "_" then plainInstr else abella_lnp_name lnp_name1 ^ ": " ^ plainInstr 
    (*
	| Apply(lnp_name1, lnp_name2, lnp_names, Some (var1, var2)) ->
        abella_proof names (Apply(lnp_name1, lnp_name2, lnp_names, None)) ^ " with " ^ var1 ^ " = " ^ var2
    *)
	| Backchain(lnp_name) -> "backchain " ^ abella_lnp_name lnp_name ^ ". "
	| Seq(proof1, proof2) -> abella_proof names proof1 ^ " " ^ abella_proof names proof2
	| CaseStar(lnp_name1, lnp_name2, proof) -> "UNRECOGNIZED: compile-time case*"
	| InductionStar(lnp_name1, lnp_name2, proof) -> "UNRECOGNIZED: compile-time induction*"
	| If(t, proof1, proof2) -> "UNRECOGNIZED: if-then-else in proof"
	| ForEachProof(var, t, proof) -> "UNRECOGNIZED: for-each iteration in proof"

	(* names_in_theorem returns a map from the names in the theorem to thier indicies.
	   (map_names_formulae_in_theorem formula is the list (name, theorem)).
	*)
let names_in_theorem formula: (string * int) list = List.mapi (fun i pair -> (fst pair, i + 1)) (map_names_formulae_in_theorem formula)
	
let abella_thrAndProof (ForEachThm(iterationOption, lnp_name, formula, proof)) =
	if is_some iterationOption then "UNRECOGNIZED: for each theorem" else "Theorem " ^ abella_lnp_name lnp_name ^ ": " ^ abella_formula formula ^ ". \n" ^ abella_proof (names_in_theorem formula) proof ^ "\n\n\n"

	(*
		old induction code: 		
		let plainInstr = "induction on 1" ^ ". " in (* to be computed. Always 1 for now. "induction on " ^ abella_lnp_name lnp_name2 in *)
		if print_lnp_name lnp_name1 = "_" then plainInstr else abella_lnp_name lnp_name1 ^ ": " ^ plainInstr 

	*)
