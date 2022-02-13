module sums_and_pairs_cbn.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (inl E) (sum T1 T2) :- typeOf E T1.

typeOf (inr E) (sum T1 T2) :- typeOf E T2.

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (case EE R1 R2) T :- typeOf EE (sum T1 T2), (pi x\ typeOf x T1 => typeOf (R1 x) T), (pi x\ typeOf x T2 => typeOf (R2 x) T).

typeOf (pair E1 E2) (times T1 T2) :- typeOf E1 T1, typeOf E2 T2.

typeOf (fst E) T1 :- typeOf E (times T1 T2).

typeOf (snd E) T2 :- typeOf E (times T1 T2).
step (app (abs T R) V) (R V).

step (case (inl V) R1 R2) (R1 V) :- value V.

step (case (inr V) R1 R2) (R2 V) :- value V.

step (fst (pair E1 E2)) E1.

step (snd (pair E1 E2)) E2.
value (abs E1 E2).

value (inl E1) :- value E1.

value (inr E1) :- value E1.

value (pair E1 E2) :- value E2, value E1.
step (inl E1) (inl E1') :- step E1 E1'.

step (inr E1) (inr E1') :- step E1 E1'.

step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (app E1 E2) (app E1 E2') :- step E2 E2', value E1.

step (case E1 E2 E3) (case E1' E2 E3) :- step E1 E1'.

step (pair E1 E2) (pair E1' E2) :- step E1 E1'.

step (pair E1 E2) (pair E1 E2') :- step E2 E2', value E1.

step (fst E1) (fst E1') :- step E1 E1'.

step (snd E1) (snd E1') :- step E1 E1'.
step (inl E1) E1 :- error E1.

step (inr E1) E1 :- error E1.

step (app E1 E2) E1 :- error E1.

step (app E1 E2) E2 :- error E2, value E1.

step (case E1 E2 E3) E1 :- error E1.

step (pair E1 E2) E1 :- error E1.

step (pair E1 E2) E2 :- error E2, value E1.

step (fst E1) E1 :- error E1.

step (snd E1) E1 :- error E1.
