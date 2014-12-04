import scala.actors.Actor._

def sumOfFactors(number : Int) = {
  (0 /: (1 to number)) {(sum,i) => if (number % i ==0 ) sum +i else sum}
}

def isPerfect(candidate: Int) = 2 * candidate == sumOfFactors(candidate)

println("6 is perfect? " + isPerfect(6))




def sumOfFactorsInRange(lower: Int, upper: Int, number: Int) = {
  (0 /: (lower to upper)) { (sum,i) => if (number % i == 0) sum + i
  else sum }
}


def isPerfectConcurrent(candidate: Int) = {
  val RANGE = 100000
  val numberOfPartitions = (candidate.toDouble / RANGE).ceil.toInt
  val caller = self

  for(i <- 0 until numberOfPartitions) {
    val lower = i * RANGE + 1;
    val upper = candidate min (i+1) * RANGE

    actor {
      caller ! sumOfFactorsInRange(lower, upper, candidate)
    }
  }

  val sum = (0 /: (0 until numberOfPartitions)) { (partialSum, i) =>
    receive {
      case sumInRange : Int => partialSum + sumInRange
    }
  }

  2 * candidate == sum
}



println("33550336 is perfect?" + isPerfectConcurrent(33550336))



val startTime : Long = 0
val caller = self
