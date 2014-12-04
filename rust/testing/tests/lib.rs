extern crate testing;
use testing::add_three_times_four;


#[test]
fn foo() {
    assert!(true);
}

#[test]
fn math_checkes_out() {
    let result = add_three_times_four(5i);
    assert_eq!(32i, result);
}



