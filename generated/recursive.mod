module recursive.

typeOf (fold E R) (mu R) :- typeOf E (R (mu R)).

typeOf (unfold E') (R (mu R)) :- typeOf E' (mu R).

step (unfold (fold E R)) E :- value E.

value (fold E1 U2) :- value E1.

step (fold E1 U2) (fold E1' U2) :- step E1 E1'.

step (unfold E1) (unfold E1') :- step E1 E1'.

nstep E E.

nstep E1 E3 :- step E1 E2, nstep E2 E3.

