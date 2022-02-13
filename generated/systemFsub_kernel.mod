module systemFsub_kernel.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (absT T R2) (all T R) :- (pi x\ subtype x T => typeOf (R2 x) (R x)).

typeOf (topObj ) (top ).

typeOf (app E1 E2) T2' :- typeOf E1 (arrow T1' T2'), typeOf E2 T1'.

step (app (abs T1 R) V) (R V) :- value V.

typeOf (appT E X) (R' X) :- typeOf E (all T' R'), subtype X T'.

step (appT (absT T R2) X) (R2 X).

value (abs T1 R2).

value (absT T1 R2).

value (topObj ).

step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (app E1 E2) (app E1 E2') :- step E2 E2', value E1.

step (appT E1 T2) (appT E1' T2) :- step E1 E1'.

nstep E E.

nstep E1 E3 :- step E1 E2, nstep E2 E3.

subtype T (top ).

subtype (arrow T1 T2) (arrow T1' T2') :- subtype T1' T1, subtype T2 T2'.

subtype (all T R) (all T R') :- (pi x\ subtype x T => subtype (R x) (R' x)).

subtype T T.

subtype T1 T3 :- subtype T1 T2, subtype T2 T3.

typeOf E T :- typeOf E S, subtype S T.
