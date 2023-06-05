open Batteries
open Unix
open Filename
open Language
open Lnp
open Pretty_printer
open Pretty_printerLan
open Abella
open Compile
(*
open LanguageDef
open Expr_evaluator
open Theorem_evaluator
open Macro_expander
*)
open Lexing

let get_positions lexbuf = let pos = lexbuf.lex_curr_p in pos.pos_fname ^ ":" ^ string_of_int pos.pos_lnum  ^ ":" ^ string_of_int (pos.pos_cnum - pos.pos_bol + 1)

let languagesFromRepo = 
	let dir = "repo/" in 
	let contents = Array.to_list (Sys.readdir dir) in
	(* let contents = List.rev_map (Filename.concat dir) contents in *)
	let files =
	  List.fold_left (fun (files) f ->
	       match (stat (dir ^ f)).st_kind with
		   | S_REG -> if String.ends_with f ".lan" then files @ [f] else files (* Regular file *)
	   	   | _ -> files)
		   [] contents in 
		   files

let repoOfSchemas = 
	[
	"./canonical.lnp"
	;
	"./progress-op.lnp"
	;
	"./progress.lnp" 
	;
	"./preservation.lnp" 
	]

let parseOneLanguage filename =
  (* Parse the language, lan is the parsed language *)
  let dir = "./repo/" in 
  let input = (open_in (dir ^ filename)) in
  let filebuf = Lexing.from_input input in
  let unusedVar = print_endline ("Reading the language: " ^ filename) in 
  let lan = try (ParserLan.fileLan LexerLan.token filebuf) with
						    | LexerLan.Error msg -> raise(Failure("Lexer error: " ^ get_positions filebuf ^ " with message: " ^ msg))
						    | ParserLan.Error -> raise(Failure("Parser error: " ^ get_positions filebuf)) in
   let unusedVar = IO.close_in input; in 
      lan

let parseTheSchema filename = 
   (* Parse the theorem&proof schema, schema is the var of the parsed schema *)
   let inputSchema = (open_in filename) in
   let filebuf = Lexing.from_input inputSchema in
   let schema = try (Parser.file Lexer.token filebuf) with
 						    | Lexer.Error msg -> raise(Failure("Lexer error: " ^ get_positions filebuf ^ " with message: " ^ msg))
 						    | Parser.Error -> raise(Failure("Parser error: " ^ get_positions filebuf)) in

   let unusedVar = IO.close_in inputSchema; in 
       schema

let parseAllLanguages _ = 
	let _ = List.map parseOneLanguage languagesFromRepo in 
	print_endline "Successfully parsed all languages."

let applySchemaToOneLang schema filenameLan = 
	let lan = parseOneLanguage filenameLan in 
		compile lan schema

let applySchemaToAllLanguages filenameSchema = 	
	let schema = parseTheSchema filenameSchema in 
		List.map (applySchemaToOneLang schema) languagesFromRepo 

let progressesDefinition = "Define progresses : term -> prop by\n\t progresses E := {value E} ;\n\t progresses E := {error E} ;\n\t progresses E := exists E', {step E E'}.\n\n"
let errorTypesAllTheorem lan = 
	let proofWhenThereAreNoErrors = "Theorem Error-types-all: forall E T1 T2, {typeOf E T1} -> {error E} -> {typeOf E T2}.\n intros Hyp1 Error. case Error. " in 
	if language_grammarLookupByCategory lan "Error" = [] then proofWhenThereAreNoErrors ^ "\n\n" else proofWhenThereAreNoErrors ^ "case Hyp1. search. \n\n"

let applyAllSchemasToOneLanguages_to_file filenameLan = 	
	let schemas = List.map parseTheSchema repoOfSchemas in 
	let lan = parseOneLanguage filenameLan in 
	let result = List.concat (List.map (compile lan) schemas) in (* concat, so result is a list of theorem&proof *)
	let nameOfLanguage = Filename.chop_extension filenameLan in 
	(* generate Abella proof .thm *)
	let thm_file = open_out ("./generated/" ^ nameOfLanguage ^ ".thm") in
	output_string thm_file ("Specification \"" ^ nameOfLanguage ^ "\". \n\n"); 
	output_string thm_file (progressesDefinition); 
	output_string thm_file (errorTypesAllTheorem lan); 
	List.map (output_string thm_file) (List.map abella_thrAndProof result); 
    close_out thm_file;
	(* generate language definition .mod *)
	let mod_file = open_out ("./generated/" ^ nameOfLanguage ^ ".mod") in
	output_string mod_file ("module " ^ nameOfLanguage ^ ".\n\n"); 
	output_string mod_file (language_prettyPrintRules lan); 
    close_out mod_file;
    print_endline ("Proofs generated in ./generated/" ^ nameOfLanguage ^ ".thm");;
	
let () = List.hd (List.map applyAllSchemasToOneLanguages_to_file languagesFromRepo);;

(*	
	List.hd (List.map applyAllSchemasToOneLanguages_to_file languagesFromRepo);;

	abella_thrAndProof
	let lan = parseOneLanguage "iff.lan" in 
  	let schema = parseTheSchema "./progress-op.lnp" in 
	print_string (print_list_of_schemas (compile lan schema));;

To print expressions in the order they appean in typing rules: 
	print_string (newExpressionGrammar "stlc_lists_filter.lan")

To test thast all languages parse: parseAllLanguages ();;

	let lan = parseOneLanguage "./fpl_cbv.lan" in 

	print_string (print_schema (testManipulation lan schema));;

  let filename = "./fpl_cbv.lan" in
		  
  let filename = "./progress.lnp" in
  let filename = "./canonical.lnp" in
  let filename = "./progress-op.lnp" in

*)
