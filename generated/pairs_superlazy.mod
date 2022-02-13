module pairs_superlazy.

typeOf (pair E1 E2) (times T1 T2) :- typeOf E1 T1, typeOf E2 T2.

typeOf (fst E) T1 :- typeOf E (times T1 T2).

typeOf (snd E) T2 :- typeOf E (times T1 T2).
step (fst (pair E1 E2)) E1.

step (snd (pair E1 E2)) E2.
value (pair E1 E2).
step (fst E1) (fst E1') :- step E1 E1'.

step (snd E1) (snd E1') :- step E1 E1'.
step (fst E1) E1 :- error E1.

step (snd E1) E1 :- error E1.
