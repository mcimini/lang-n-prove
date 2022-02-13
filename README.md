# Lang-n-Prove

Author: Matteo Cimini (matteo_cimini@uml.edu)
	<br />
# <a name="instructions"></a>Instructions 
<br />

Requirements: 
<br />
<ul>
<li> To compile and run: Ocaml with the Batteries and Menhir packages is required.
<li> To test the output of Lang-n-Prove: the <a href="http://abella-prover.org">Abella proof assistant</a> is required.  
</ul>

Quick usage: 
<br />
<ul>
<li> make 
<li> ./lnp
</ul>
What it does:  <br />
<ul>
<li> loads the following lnp proofs in the folder of the project:
	<ul>
	<li>canonical.lnp (to generate canonical form lemmas) 
	<li> progress-op.lnp (to generate operator-specific progress theorems) 
	<li> progress.lnp (to generate the progress theorem) 
	<li> preservation.lnp (to generate the type preservation theorem) 
	</ul>

<li> loads all the languages with extension .lan in the folder "repo"
	
<li> applies the lnp proofs to the languages, and generates the Abella proof assistant files in the repo "generated" 
</ul>

To test the results of ./lnp (i.e. to test the proofs that Lang-n-Prove has generated): 
<br />
<ul>
<li> ./testAll <br />
	This is a bash script. The command "abella" must be in the $PATH. <br />
	The script runs the command "abella" on all the Abella proofs (.thm files) in the folder "generated". <br />
	The script prints a success message, or points out the Abella proof files that failed. 	
<li> Alternatively, users can manually run Abella on the Abella proofs they are interested to check. Example: "abella generated/fpl_cbv.thm" 
</ul>

To clean: <br />
<ul>
<li> make clean 
	<br /> (removes compilation files and executable) 
	<br /> (removes Abella files in "generated") 
</ul>
<br />

# <a name="examples"></a>Substitution Lemmas. 

We do not support substitution lemmas at the moment. 
<br />
The Lang-n-Prove proof preservation.lnp generates "skip" where substitution lemmas should be applied. 
<br />
That is, some .thm files have "skip." in proof of theorem Type-preservation. 
<br />
<br />

To complete those proofs, replace the "skip." instruction in 
<ul>
<li> Mapp case with: Hyp1 : case Hyp1(keep). CutHyp : assert ({typeOf E2 T1}). ToCut : inst Hyp3 with n1 = E2. cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.
<li> MappT case with:  Hyp1 : case Hyp1(keep). inst Hyp2 with n1 = X. search.
<li> Mlet case with: CutHyp : assert ({typeOf E T1}). ToCut : inst Hyp2 with n1 = E. cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.
<li> Mcase, the first "skip.", with: Hyp1 : case Hyp1(keep). CutHyp : assert ({typeOf E T1}). ToCut : inst Hyp2 with n1 = E. cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.
<li> Mcase, the second "skip.", with: Hyp1 : case Hyp1(keep). CutHyp : assert ({typeOf E T2}). ToCut : inst Hyp3 with n1 = E. cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.
<li> Mletrec case with: CutHyp : assert ({typeOf (fix (abs T1 R1)) T1}). ToCut : inst Hyp2 with n1 = (fix (abs T1 R1)). cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.
</ul>

Example: Lang-n-Prove generates stlc_cbv.thm with the following Type Preservation theorem: 
<br />
<br />

Theorem Type-preservation: forall e1, forall e2, forall typ, {typeOf e1 typ} -> {step e1 e2} -> {typeOf e2 typ}. 
IH0 : induction on 1. intros Main Step. Typing0: case Main.  
<br />
Mabs: case Step.   
<br />
<mark>Mapp: case Step.  skip.</mark>  
<br />
apply IH0 to Typing0 Mapp.  search.  
<br />
apply IH0 to Typing1 Mapp.  search. 
<br />
backchain Error-types-all.  
<br />
backchain Error-types-all. 

Replace "skip." as shown below. 
<br />
<br />

Theorem Type-preservation: forall e1, forall e2, forall typ, {typeOf e1 typ} -> {step e1 e2} -> {typeOf e2 typ}. 
IH0 : induction on 1. intros Main Step. Typing0: case Main.  <br />
Mabs: case Step.   
<br />
<mark>Mapp: case Step.  Hyp1 : case Hyp1(keep). CutHyp : assert ({typeOf E2 T1}). ToCut : inst Hyp3 with n1 = E2. cut ToCut with CutHyp. clear CutHyp. clear ToCut. search.</mark>  <br />
apply IH0 to Typing0 Mapp.  search.  
<br />
apply IH0 to Typing1 Mapp.  search.  
<br />
backchain Error-types-all.
<br />
backchain Error-types-all. 





