import scala.actors._
import Actor._


val caller = self

val accumulator = actor {
  var continue = true
  var sum = 0

  loopWhile(continue) {
    reactWithin(500) {
      case number : Int => sum += number
      case TIMEOUT =>
        continue = false
        caller ! sum
    }
  }
}


accumulator ! 1
accumulator ! 7
accumulator ! 8

receiveWithin(1000) { case result => println("Total is " + result)}
