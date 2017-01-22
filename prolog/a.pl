likes(alice,bob).
likes(bob,carol).
likes(james,mary).
likes(mary,james).
love_compatible(X, Y) :- likes(X, Y), likes(Y, X).


mother(alice,lea).
mother(john,julia).
mother(lea,alberta).
father(james,alfred).
father(lea,john).


parent(X, Y) :- father(X, Y).
parent(X, Y) :- mother(X, Y).
grandparent(X, Y) :- parent(X, Z), parent(Z, Y).
