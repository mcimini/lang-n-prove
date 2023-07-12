OCAML=ocamlfind ocamlc -w "-8-10-11-14-25-26" -g -package menhirLib -package batteries -linkpkg -thread
OUTPUT=lnp
PARSERLAN=parserLan.mli parserLan.ml lexerLan.ml 
GENERATEDDIR=generated/

default:
	ocamllex lexer.mll 2> dump.txt
	menhir parser.mly 2> dump.txt
	ocamllex lexerLan.mll 2> dump.txt
	menhir parserLan.mly 2> dump.txt
	rm dump.txt
	$(OCAML) language.ml lnp.ml parser.mli parser.ml lexer.ml $(PARSERLAN) pretty_printer.ml declarationsToRules.ml pretty_printerLan.ml abella.ml substitution.ml compile.ml main.ml -o $(OUTPUT)

clean:
	rm *.cmo
	rm *.cmi
	rm $(OUTPUT)
	rm $(GENERATEDDIR)*.mod
	rm $(GENERATEDDIR)*.thm

