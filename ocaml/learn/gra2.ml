let multiply n list =
	let f x = 
	n * x in 
	List.map f list;;


multiply 2 [1;2;3];;

