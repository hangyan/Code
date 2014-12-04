
fn main() {
    println!("hello?");

    
    // functions
    let c = Circle { x: 0.0, y: 0.0, radius: 2.0 };
    println!("{}", c.area());

    // closures
    let add_one = |x| { 1i + x };
    println!("The sum of 5 plus 1 is {}.", add_one(5i));

    // proc
    let x = 5i;
    let p = proc() { x * x };
    println!("{}", p());

    // adapter
    for i in std::iter::count(1i,5i).take(5) {
        println!("{}", i);
    }
    
    
}

struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
