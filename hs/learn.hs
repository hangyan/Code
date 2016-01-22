bmiTell :: (RealFloat a) => a -> String
bmiTell bmi
  | bmi <= 18.5 = "underweight"
  | bmi <= 25.0 = "normal"
  | bmi <= 30.0 = "fat"
  | otherwise = "whale"



bmiTell2 :: (RealFloat a)  => a -> a -> String
bmiTell2 weight height
  | weight / height ^ 2 <= 18.5 = "underweight"
  | weight / height ^ 2 <= 25.0 = "nomal"
  | weight / height ^ 2 <= 30.0 = "fat"
  | otherwise = "whale"




max' :: (Ord a) => a -> a -> a
max' a b
  | a > b = a
  | otherwise = b


myCompare :: (Ord a) => a -> a -> Ordering
a `myCompare` b
| a > b = GT
| a == b = EQ
| otherwise = LT



