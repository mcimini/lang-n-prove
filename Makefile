OCAML=ocamlfind ocamlc -w "-3-8-10-11-14-25-26" -g -package menhirLib -package batteries -linkpkg -thread
OUTPUT=lnp
PARSERLAN=parserLan.mli parserLan.ml lexerLan.ml
GENERATEDDIR=generated/

.PHONY:
default:
	ocamllex lexer.mll 2> dump.txt
	menhir parser.mly 2> dump.txt
	ocamllex lexerLan.mll 2> dump.txt
	menhir parserLan.mly 2> dump.txt
	rm dump.txt
	$(OCAML) language.ml lnp.ml parser.mli parser.ml lexer.ml $(PARSERLAN) pretty_printer_lnp.ml declarationsToRules.ml pretty_printer_mod.ml pretty_printer_thm.ml substitution.ml compile.ml pretty_printer_lan.ml main.ml -o $(OUTPUT)

.PHONY:
clean:
	rm -f lexer.ml
	rm -f parser.ml
	rm -f parser.mli
	rm -f $(PARSERLAN)
	rm -f *.cmo
	rm -f *.cmi
	rm -f $(OUTPUT)
	rm -f $(GENERATEDDIR)*.lan
	rm -f $(GENERATEDDIR)*.mod
	rm -f $(GENERATEDDIR)*.thm
