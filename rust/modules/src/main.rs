fn main() {
    println!("Hello, world!");
    hello::print_hello();
}


mod hello {
    pub fn print_hello() {
        println!("Hello world!");
        
    }
}
