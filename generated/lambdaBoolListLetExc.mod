module lambdaBoolListLetExc.

typeOf (abs T1 R) (arrow T1 T2) :- (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (tt) (bool).

typeOf (ff) (bool).

typeOf (emptyList) (list T).

typeOf (cons E1 E2) (list T) :- typeOf E1 T, typeOf E2 (list T).

typeOf (app E1 E2) T2 :- typeOf E1 (arrow T1 T2), typeOf E2 T1.

typeOf (if E1 E2 E3) T :- typeOf E1 (bool), typeOf E2 T, typeOf E3 T.

typeOf (head E) T :- typeOf E (list T).

typeOf (tail E) (list T) :- typeOf E (list T).

typeOf (let E R) T2 :- typeOf E T1, (pi x\ typeOf x T1 => typeOf (R x) T2).

typeOf (try E1 E2) T :- typeOf E1 T, typeOf E2 (arrow (bool) T).

typeOf (raise E1) T :- typeOf E1 (bool).
step (app (abs T R) V) (R V) :- value V.

step (if (tt) E1 E2) E1.

step (if (ff) E1 E2) E2.

step (head (emptyList)) (raise (tt)).

step (head (cons E1 E2)) E1.

step (tail (emptyList)) (raise (ff)).

step (tail (cons E1 E2)) E2.

step (let V R) (R V) :- value V.

step (try E1 E2) E1 :- value E1.

step (try (raise E1) E2) (app E2 E1).
value (abs E1 E2).

value (tt).

value (ff).

value (emptyList).

value (cons E1 E2) :- value E2, value E1.
error (raise E1) :- value E1.
step (cons E1 E2) (cons E1' E2) :- step E1 E1'.

step (cons E1 E2) (cons E1 E2') :- step E2 E2', value E1.

step (app E1 E2) (app E1' E2) :- step E1 E1'.

step (app E1 E2) (app E1 E2') :- step E2 E2', value E1.

step (if E1 E2 E3) (if E1' E2 E3) :- step E1 E1'.

step (head E1) (head E1') :- step E1 E1'.

step (tail E1) (tail E1') :- step E1 E1'.

step (let E1 E2) (let E1' E2) :- step E1 E1'.

step (try E1 E2) (try E1' E2) :- step E1 E1'.

step (raise E1) (raise E1') :- step E1 E1'.
step (cons E1 E2) E1 :- error E1.

step (cons E1 E2) E2 :- error E2, value E1.

step (app E1 E2) E1 :- error E1.

step (app E1 E2) E2 :- error E2, value E1.

step (if E1 E2 E3) E1 :- error E1.

step (head E1) E1 :- error E1.

step (tail E1) E1 :- error E1.

step (let E1 E2) E1 :- error E1.

step (raise E1) E1 :- error E1.
