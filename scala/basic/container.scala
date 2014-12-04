val colors1 = Set("Blue", "Green", "Red")
var colors = colors1

println(colors)

colors += "black"
println(colors)
println(colors1)


class Cow {
  def ^(moon: Moon) = println("Cow jumped over the moon")

}

class Moon {
  def ^:(cow: Cow) = println("This cow jumped the moon too")
}

val cow = new Cow
val moon = new Moon


cow ^ moon
cow ^: moon

class Sample {
  def unary_+ = println("called unary +")
  def unary_- = println("called unary -")
  def unary_! = println("called unary !")
  def unary_~ = println("called unary ~")
}

val sample = new Sample
+sample
-sample
!sample
~sample


for (i <- 1 to 3) {println("ho...")}


val result = for(i <- 1 to 10)
yield i * 2

val result2 = (1 to 10).map(_ * 2)
println(result)
println(result2)

val doubleEven = for (i <- 1 to 10; if i % 2 == 0)
  yield i * 2
println(doubleEven)


for {
  i <-1 to 10
  if i % 2 == 0
}
yield i * 2


class Person(val firstName: String, val lastName: String)
object Person {
def apply(firstName: String, lastName: String) : Person =
  new Person(firstName, lastName)
}

val friends = List(Person("Brian", "Sletten"), Person("NN","HH"),
  Person("Scott", "Davis"), Person("Stuart", "halloway"))

val lastNames = for ( friend <- friends ; lastName = friend.lastName)
yield lastName
println(lastNames.mkString(","))


for ( i <- 1 to 3; j <- 4 to 6) {
  println("[" + i + "," + j + "]")
}
