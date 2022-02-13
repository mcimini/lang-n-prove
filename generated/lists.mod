module lists.

typeOf (emptyList) (list T).

typeOf (cons E1 E2) (list T) :- typeOf E1 T, typeOf E2 (list T).

typeOf (head E) T :- typeOf E (list T).

typeOf (tail E) (list T) :- typeOf E (list T).

typeOf (myError) T.
step (head (emptyList)) (myError).

step (head (cons E1 E2)) E1.

step (tail (emptyList)) (myError).

step (tail (cons E1 E2)) E2.
value (emptyList).

value (cons E1 E2) :- value E2, value E1.
error (myError).
step (cons E1 E2) (cons E1' E2) :- step E1 E1'.

step (cons E1 E2) (cons E1 E2') :- step E2 E2', value E1.

step (head E1) (head E1') :- step E1 E1'.

step (tail E1) (tail E1') :- step E1 E1'.
step (cons E1 E2) E1 :- error E1.

step (cons E1 E2) E2 :- error E2, value E1.

step (head E1) E1 :- error E1.

step (tail E1) E1 :- error E1.
