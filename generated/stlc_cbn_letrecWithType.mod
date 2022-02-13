module stlc_cbn_letrecWithType.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (fix E) T :- typeOf E (arrow T T).

typeOf (let E R) T2 :- typeOf E T1, (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (letrec T1 R1 R2) T2 :- (pi x\ typeOf x T1 => typeOf (R1 x) T1), (pi x\ typeOf x T1 => typeOf (R2 x) T2).
step (app (abs T R) E) (R E).

step (fix V) (app V (fix V)) :- value V.

step (let V R) (R V) :- value V.

step (letrec T R1 R2) (let (fix (abs T R1)) R2).
value (abs E1 E2).
step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (fix E1) (fix E1') :- step E1 E1'.

step (let E1 E2) (let E1' E2) :- step E1 E1'.
step (app E1 E2) E1 :- error E1.

step (fix E1) E1 :- error E1.

step (let E1 E2) E1 :- error E1.
