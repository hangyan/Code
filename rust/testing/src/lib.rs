pub fn add_three_times_four(x: int) -> int {
    (x + 3 ) * 4
}

fn add_three(x: int) -> int { x + 3 }
fn times_four(x: int) -> int { x * 4 }

#[cfg(test)]
mod test {
    use super::add_three;
    use super::times_four;

    #[test]
    fn test_add_three() {
        let result = add_three(5i);
        assert_eq!(8i, result);
    }

    #[test]
    fn test_times_four() {
        let result= times_four(5i);
        assert_eq!(20i, result);
    }
}
