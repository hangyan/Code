

object HelloWorld {
  val times = 1
  times match {
    case 1 => "one"
    case 2 => "two"
    case _ => "some other number"
  }

  times match {
    case i if i == 1 => "one"
    case i if i == 2 => "two"
    case _ => "some other number"
  }

  def main(args: Array[String]) {
    println("hello,SBT")
  }

  val hp20b = Calculator("hp","20B")
  val hp30b = Calculator("hp","30B")

  def ourMap(numbers: List[Int],fn:Int => Int):List[Int] = {
    numbers.foldRight(List[Int]()) { (x: Int,xs: List[Int]) =>
      fn(x) :: xs
    }
  }


}

class Calculator(brand: String) {

  val color: String = if ( brand == "TI") {
    "blue"
  } else if ( brand == "HP") {
    "black"
  } else {
    "white"
  }

  def add(m: Int,n: Int): Int = m+n
}


def bigger(o: Any):Any = {
  o match {
    case i: Int if i < 0 => i-1
    case i: Int => i+1
    case d: Double if d < 0.0 => d-0.1
    case d: Double => d+0.1
    case text: String => text + "s"
  }
}





actor {
  var sum = 0
  loop {
    receive {
      case Data(bytes)
          case GetSum
