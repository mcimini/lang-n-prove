module stlc_cbn_recursive.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (fold E R) (mu R) :- typeOf E (R (mu R)).

typeOf (unfold E) (R (mu R)) :- typeOf E (mu R).
step (app (abs T R) E) (R E).

step (unfold (fold V R)) V :- value V.
value (abs E1 E2).

value (fold E1 E2) :- value E1.
step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (fold E1 E2) (fold E1' E2) :- step E1 E1'.

step (unfold E1) (unfold E1') :- step E1 E1'.
step (app E1 E2) E1 :- error E1.

step (fold E1 E2) E1 :- error E1.

step (unfold E1) E1 :- error E1.
