import java.util._


class CreditCard(val numbder : Int, var creditLimit: Int)

class Person(val firstName : String, val lastName : String) {
  private var position : String = _
  println("Creating " + toString())

  def this (firstName : String, lastName : String, positionHeld : String) {
    this (firstName, lastName)
    position = positionHeld
  }

  override def toString() : String = {
    firstName + " " + lastName + " holds " + position + " position"
  }
}

val john = new Person("John", "Smith", "Analyst")
println(john)
val bill = new Person("Bill", "Walker")
println(bill)


class Vehicle(val id: Int, val year: Int) {
  override def toString() : String = "ID: " + id + "Year: " + year
}

class Car(override val id: Int, override val year: Int, val fuelLevel: Int)
    extends Vehicle(id,year) {
  override def toString() : String = super.toString() + " Fuel Level: " + fuelLevel
}

var car = new Car(1, 2009, 100)
println(car)


class Marker private (val color: String) {
  println("Creating " + this)
  override def toString() : String = "markder color " + color
}

object Marker {
  private val markers = Map(
    "red" -> new Marker("red"),
    "blue" -> new Marker("blue"),
    "green" -> new Marker("green")
  )

  def getMarker(color: String) =
    if (markers.contains(color)) markers(color) else null
}

println(Marker getMarker "red")
println(Marker getMarker "blue")
println(Marker getMarker "blue")
println(Marker getMarker "red")
println(Marker getMarker "yellow")

var year : Int = 2009
var anotherYear = 2009
var greet= "Hello there"
var builder = new StringBuilder("hello")

println(builder.getClass())


var list1 : List[Int] = new ArrayList[Int]
var list2 = new ArrayList[Int]

list2 add 1
list2 add 2

var total = 0

for (val index <- 0 until list2.size()) {
  total += list2.get(index)
}

println("Total is " + total)
