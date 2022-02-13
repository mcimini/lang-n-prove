module recursive_withMore_cbn.

typeOf (abs R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (fold E R) (mu R) :- typeOf E (R (mu R)).

typeOf (cons E1 E2) (list T) :- typeOf E1 T, typeOf E2 (list T).

typeOf (emptyList ) (list T).

typeOf (ff ) (bool ).

typeOf (tt ) (bool ).

typeOf (excValue ) (excType ).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

step (app (abs R) EE) (R EE).

typeOf (unfold E') (R (mu R)) :- typeOf E' (mu R).

step (unfold (fold E R)) E :- value E.

typeOf (head E) T :- typeOf E (list T).

step (head (emptyList )) (raise (excValue )).

step (head (cons E1 E2)) E1.

typeOf (tail E) (list T) :- typeOf E (list T).

step (tail (emptyList )) (raise (excValue )).

step (tail (cons E1 E2)) E2.

typeOf (if E1 E2 E3) T :- typeOf E1 (bool ), typeOf E2 T, typeOf E3 T.

step (if (tt ) E1 E2) E1.

step (if (ff ) E1 E2) E2.

typeOf (letrec R1 R2) T2 :- (pi x\ typeOf x T1 => typeOf (R1 x) T1), (pi x\ typeOf x T1 => typeOf (R2 x) T2).

step (letrec R1 R2) (R2 (fix (abs R1))).

typeOf (fix E) T :- typeOf E (arrow T T).

step (fix V) (app V (fix V)) :- value V.

typeOf (try E1 E2) T :- typeOf E1 T, typeOf E2 (arrow (excType ) T).

step (try E1 E2) E1 :- value E1.

step (try (raise E) E2) (app E2 E).

value (abs R1).

value (fold E1 U2) :- value E1.

value (cons E1 E2) :- value E1, value E2.

value (emptyList ).

value (ff ).

value (tt ).

value (excValue ).

step (fold E1 U2) (fold E1' U2) :- step E1 E1'.

step (cons E1 E2) (cons E1' E2) :- step E1 E1'.

step (cons E1 E2) (cons E1 E2') :- step E2 E2', value E1.

step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (unfold E1) (unfold E1') :- step E1 E1'.

step (head E1) (head E1') :- step E1 E1'.

step (tail E1) (tail E1') :- step E1 E1'.

step (if E1 E2 E3) (if E1' E2 E3) :- step E1 E1'.

step (fix E1) (fix E1') :- step E1 E1'.

step (try E1 E2) (try E1' E2) :- step E1 E1'.

step (raise E1) (raise E1') :- step E1 E1'.

error (raise E1).

typeOf (raise E) T :- typeOf E (excType ).

step (fold E1 U2) E1 :- error E1.

step (cons E1 E2) E1 :- error E1.

step (cons E1 E2) E2 :- error E2.

step (app E1 E2) E1 :- error E1.

step (unfold E1) E1 :- error E1.

step (head E1) E1 :- error E1.

step (tail E1) E1 :- error E1.

step (if E1 E2 E3) E1 :- error E1.

step (fix E1) E1 :- error E1.

step (raise E1) E1 :- error E1.

nstep E E.

nstep E1 E3 :- step E1 E2, nstep E2 E3.

