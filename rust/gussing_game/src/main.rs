use std::io;
use std::rand;

fn main() {
    println!("Guess the number!");

    let secret_number = (rand::random::<uint>() % 100u) + 1u;

    println!("The secret number is : {}", secret_number);
    
    println!("Please input your guess.");

    let input = io::stdin().read_line()
        .ok()
        .expect("failed to read line");
    println!("Your guessed : {}", input);

    let input_num: Option<uint> = from_str(input.as_slice());
    

    println!("input num is : {}", input_num);
    
    let num = match input_num {
        Some(num) => num,
        None => {
            println!("Please input a number!!!");
            return;
        }
    };

    
    match cmp(num, secret_number) {
        Less => println!("Too small!"),
        Greater => println!("Too big"),
        Equal => println!("You win"),
    }
}

fn cmp(a: uint, b: uint) -> Ordering {
    if a < b { Less }
    else if a > b { Greater }
    else { Equal }
}
