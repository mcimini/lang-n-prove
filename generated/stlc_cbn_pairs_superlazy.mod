module stlc_cbn_pairs_superlazy.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (pair E1 E2) (times T1 T2) :- typeOf E1 T1, typeOf E2 T2.

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (fst E) T1 :- typeOf E (times T1 T2).

typeOf (snd E) T2 :- typeOf E (times T1 T2).
step (app (abs T R) E) (R E).

step (fst (pair E1 E2)) E1.

step (snd (pair E1 E2)) E2.
value (abs E1 E2).

value (pair E1 E2).
step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (fst E1) (fst E1') :- step E1 E1'.

step (snd E1) (snd E1') :- step E1 E1'.
step (app E1 E2) E1 :- error E1.

step (fst E1) E1 :- error E1.

step (snd E1) E1 :- error E1.
