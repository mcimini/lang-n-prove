module stlc_par.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.
step (app (abs T R) E) (R E).
value (abs E1 E2).
step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (app E1 E2) (app E1 E2') :- step E2 E2'.
step (app E1 E2) E1 :- error E1.

step (app E1 E2) E2 :- error E2.
