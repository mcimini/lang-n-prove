module listsIsNil_lazy.

typeOf (emptyList) (list T).

typeOf (cons E1 E2) (list T) :- typeOf E1 T, typeOf E2 (list T).

typeOf (tt) (bool).

typeOf (ff) (bool).

typeOf (head E) T :- typeOf E (list T).

typeOf (tail E) (list T) :- typeOf E (list T).

typeOf (isnil E) (bool) :- typeOf E (list T).

typeOf (if E1 E2 E3) T :- typeOf E1 (bool), typeOf E2 T, typeOf E3 T.

typeOf (myError) T.
step (head (emptyList)) (myError).

step (head (cons E1 E2)) E1.

step (tail (emptyList)) (myError).

step (tail (cons E1 E2)) E2.

step (isnil (emptyList)) (tt).

step (isnil (cons E1 E2)) (ff).

step (if (tt) E1 E2) E1.

step (if (ff) E1 E2) E2.
value (emptyList).

value (cons E1 E2).

value (tt).

value (ff).
error (myError).
step (head E1) (head E1') :- step E1 E1'.

step (tail E1) (tail E1') :- step E1 E1'.

step (isnil E1) (isnil E1') :- step E1 E1'.

step (if E1 E2 E3) (if E1' E2 E3) :- step E1 E1'.
step (head E1) E1 :- error E1.

step (tail E1) E1 :- error E1.

step (isnil E1) E1 :- error E1.

step (if E1 E2 E3) E1 :- error E1.
