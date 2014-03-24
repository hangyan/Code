let message = "Hello"
let hello ()  = print_endline message;;


class statck_of_ints = 
	object (self)
		val mutable the_list = ([] : int list)
		method push x = 
			the_list <- x :: the_list
		method pop = 
			let result = List.hd the_list in 
			the_list <- List.tl the_list;
			result
		method peek = 
			List.hd the_list
		method size = 
			List.length the_list
	end;;