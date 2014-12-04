import java.util._
import java.io._

var list1 = new ArrayList[Int]
var list2 = new ArrayList[Any]

var ref1 : Int = 1
var ref2 : Any = null

ref2 = ref1


def madMethod() = { throw new IllegalArgumentException ()}

def commentOnPractice(input: String) = {
  if (input == "test") Some("Good") else None
}



def max(values: Int*) = values.foldLeft(values(0)) { Math.max}
println(max(2,5,4,4,4,44))


def totalResultOverRange(number: Int, codeBlock: Int => Int) : Int = {
  var result = 0
  for (i <- 1 to number) {
    result += codeBlock(i)
  }
  result
}




println(totalResultOverRange(11, i => i))
println(totalResultOverRange(11, i => if (i % 2 == 0) 1 else 0))

def inject(arr: Array[Int], initial: Int) (operation: (Int, Int) => Int) : Int = {
  var carryOver = initial
  arr.foreach(element => carryOver = operation(carryOver,element))
  carryOver
}


class Equipment(val routine : Int => Int) {
  def simulate(input: Int) = {
    print("Running simulation...")
    routine(input)
  }
}


val calculator = {input : Int => println("calc with " + input); input}
val equipment1 = new Equipment(calculator)
val equipment2 = new Equipment(calculator)

equipment1.simulate(4)
equipment2.simulate(6)


val arr = Array(1,2,3,4,5,6)
println("Sum of all values in array is " + (0 /: arr) { (sum,elem) => sum + elem})
println("Sum of all values in array is " + (0 /: arr) { _ + _ } )

class Resource private() {
  println("Starting transaction...")
  private def cleanup() { println("Ending transaction...")}

  def op1 = println("Operation 1")
  def op2 = println("Operation 2")
  def op3 = println("Operation 3")
}

object Resource {
  def use(codeBlock: Resource => Unit) {
    val resource = new Resource
    try {
      codeBlock(resource)
    }
    finally {
      resource.cleanup()
    }
  }
}

Resource.use { resource =>
  resource.op1
  resource.op2
  resource.op3
  resource.op1
}


def writeToFile(fileName: String)(codeBlock : PrintWriter => Unit) = {
  val writer = new PrintWriter(new File(fileName))
  try { codeBlock(writer) } finally {writer.close()}
}



writeToFile("output.txt") { writer =>
  writer write "hello from scla"
}


def log( date: Date, message: String) {
  println(date + "-----" + message)
}

val date = new Date
log(date, "message1")
log(date, "message2")
log(date, "message3")
log(date, "message4")
log(date, "message5")

val logWithDateBound = log(new Date, _ : String)
logWithDateBound("message1")
logWithDateBound("message2")
logWithDateBound("message3")
logWithDateBound("message4")
logWithDateBound("message5")
