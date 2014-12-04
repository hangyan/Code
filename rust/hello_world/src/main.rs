use std::io::stdin;

fn main() {
    println!("Hello,world!");
    let x = 5i;
    let y: int = if x == 5i {10i} else {15i};

    println!(" y is {}",y);
    print_number(5);
    print_sum(5,6);


    // tuple
    let (x, y) = next_two(5i);
    println!("x, y = {}, {}", x , y);

    // struct 
    let origin = Point { x: 0i, y: 0i };
    println!("The origin is at ({},{})",origin.x,origin.y);

    // mutable struct 
    let mut point = Point { x: 0i, y: 0i };
    point.x = 5;
    println!("The point is at ({},{})",point.x,point.y);

    // tulple struct 
    struct Inches(int);
    let length = Inches(10);
    let Inches(integer_length) = length;
    println!("length is {} inches", integer_length);


    // enum
    let x = 5i;
    let y = 10i;

    
    let ordering = cmp(x, y);
    if ordering == Less {
        println!("less");
    } else if ordering == Greater {
        println!("greater");
    } else if ordering == Equal {
        println!("equal");
    }

    

    // match
    let x = 5i;
    
    match x {
        1 => println!("one"),
        2 => println!("two"),
        3 => println!("three"),
        4 => println!("four"),
        5 => println!("five"),
        _ => println!("something else"),
    }

    // while
    let mut x = 5u;
    let mut done = false;

    while !done {
        x += x -3;
        println!("{}", x);
        if x % 5 == 0 { done = true ;}
    }

    // strings
    let mut s = "hello".to_string();
    println!("{}",s);

    s.push_str(",world.");
    println!("{}",s);

    let s = "hello".to_string();
    takes_slice(s.as_slice());

    // vec
    let vec = vec![1i, 2i, 3i];
    for i in vec.iter() {
        println!("{}", i);
    }

    //input
    println!("Type somethings!");
    let input = std::io::stdin().read_line().ok().expect("Failed to read line");
    println!("{}", input);
    
}


fn takes_slice(slice: &str) {
    println!("Got: {}", slice);
}


fn cmp(a: int, b: int) -> Ordering {
    if a < b { Less }
    else if a > b { Greater }
    else { Equal }
}



fn print_number(x: int) {
    println!("x is : {}", x)
}

fn print_sum(x: int, y: int) {
    println!("sum is : {}", x + y);
}


fn next_two(x: int) -> (int, int) { (x + 1i, x + 2i) }

struct Point {
    x: int,
    y: int,
}


