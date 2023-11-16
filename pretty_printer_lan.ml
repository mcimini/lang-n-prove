open Batteries
open Language

let rec print_term (term: Language.term): string =
    match term with
    | Constr (cname, args) -> "(" ^ cname ^ " " ^ (String.concat " " (List.map print_term args)) ^ ")"
    | LangVar name -> name
    | BoundVar -> "x"
    | BoundTypeVar -> "X"
    | Abs (term) -> "(x)" ^ print_term term
    | AbsType (term) -> "(X)" ^ print_term term
    | Substitution (t1, t2, t3) -> print_term t1 ^ "[" ^ print_term t2 ^ "/" ^ print_term t3 ^ "]"

let print_grammar_line (line: Language.grammarLine): string =
    let category = grammarLine_getCategory line in
    category ^ " " ^
    begin
        match grammarLine_getMetavarOption line with
        | None -> ""
        | Some m -> m ^ " "
    end ^
    "::= " ^
    (if category = "Context" then "[] | " else "") ^
    begin
        match grammarLine_getItemsOption line with
        | None -> ""
        | Some terms ->
            String.concat " | " (List.map print_term terms)
    end
    ^ ".\n"

let print_grammar (lan: Language.language): string =
    String.concat "" (List.map print_grammar_line (language_getGrammar lan))

let print_predname (predname: string): string =
    match predname with
    | "typeOf" -> "|-"
    | "typeOfA" -> "|a-"
    | "step" -> "-->"
    | "subtype" -> "<:"
    | "subtypeA" -> "<a"
    | _ -> predname

let print_typeof_formula (predname: string) (args: term list): string =
    let [assumption; t1; t2] = args in
    begin
        match assumption with
        | LangVar "Gamma" -> "Gamma"
        | Constr ("gammaAddx", [t]) -> "Gamma, x : " ^ print_term t
        | Constr ("gammaAddX", []) -> "Gamma, X"
    end ^ " " ^
    print_predname predname ^ " " ^ print_term t1 ^ " : " ^ print_term t2

let print_infix_formula (predname: string) (args: term list): string =
    let [t1; t2] = args in
    print_term t1 ^ " " ^
    print_predname predname ^ " " ^
    print_term t2

let print_default_formula (predname: string) (args: term list): string =
    print_predname predname ^ " " ^
    String.concat " " (List.map print_term args)

let print_formula (formula: Language.formula): string =
    let pred = formula_getPredname formula in
    let args = formula_getArguments formula in
    match pred with
    | "typeOf" | "typeOfA" -> print_typeof_formula pred args
    | "step" | "subtype" | "subtypeA" -> print_infix_formula pred args
    | _ -> print_default_formula pred args

let print_rule (rule: Language.rule): string =
    let conclusion = rule_getConclusion rule in
    if
        conclusion :: (rule_getPremises rule)
            |> List.exists (fun formula ->
                (formula_getPredname formula) = "subtype")
    then "" else
    print_formula conclusion ^
    let prems = rule_getPremises rule in
    (if prems <> [] then
        " <== " ^
        String.concat " /\\ " (List.map print_formula prems)
    else "") ^
    ".\n"

let print_rules (lan: Language.language): string =
    let builtinPrednames = [
        "typeOf"; "typeOfA";
        "step";
        "subtype"; "subtypeA";
        "join"; "meet";
        "value"; "error";
    ] in
    let only_predname_rules predname category =
        let cnames =
            List.map term_getCNAME (language_grammarLookupByCategory lan category)
        in
        (cnames |> List.map
            (fun cname ->
                let filtered =
                    (language_getRulesOfOp lan cname) |>
                    List.filter (rule_isPredname predname)
                in filtered
            ))
        |> List.concat
    in
    String.concat "" (List.map print_rule (only_predname_rules "typeOf" "Expression"))
    ^ String.concat "" (List.map print_rule (only_predname_rules "typeOfA" "Expression"))
    ^ String.concat "" (List.map print_rule (only_predname_rules "subtypeA" "Type"))
    ^ String.concat "" (List.map print_rule (only_predname_rules "join" "Type"))
    ^ String.concat "" (List.map print_rule (only_predname_rules "meet" "Type"))
    ^ String.concat "" (List.map print_rule (language_getReductionRules lan))
    ^ String.concat "" (List.map print_rule (
        language_getRules lan |> (List.filter (fun r ->
            not (List.mem (rule_getConclusionPredname r) builtinPrednames)))))

let add_extra_rules (lan: Language.language): Language.language = lan

let prettyPrintLan (lan: Language.language): string =
    print_grammar lan ^ "\n" ^
    print_rules (add_extra_rules lan)
