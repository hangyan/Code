for (i <- 1 to 3) {
  print(i + ",")
}

println("Scala Rocks!!!")

for (i <- 1 until 3) {
  print(i + ",")
}

println("Scala Rocks!!!")




class ScalaInt {
  def playWithInt() {
    val capacity : Int = 10
    val list = new java.util.ArrayList[String]
    list.ensureCapacity(capacity)
  }
}

def getPersonInfo(primaryKey : Int) = {

  ("V", "S", "hehe")
}

val (firstName, lastName, emailAddress) = getPersonInfo(1)
println("First name is " + firstName)
println("Last Name is " + lastName)
println("Email Address is " + emailAddress)




class Complex(val real: Int, val imaginary: Int) {
  def +(operand: Complex) : Complex = {
    new Complex(real + operand.real, imaginary + operand.imaginary)
  }




  override def toString() : String = {
    real + (if (imaginary < 0) "" else "+") + imaginary + "i"
  }
}

val c1 = new Complex(1,2)
val c2 = new Complex(2,-3)
val sum = c1 + c2
println("(" + c1 + ") + (" + c2 + ") = " + sum)

val str1 = "hello"
val str2 = "hello"
val str3 = new String("hello")

println(str1 == str2)
println(str1 eq str2)
println(str1 == str3)
println(str1 eq str3)


class Microwave {
  def start() = println("started")
  def stop() = println("stopped")
  private def turnTable() = println("turning table")
}

val microwave = new Microwave
microwave.start()
//microwave.turnTable()


def check1() = true
def check2() : Boolean = return true
println(check1)
println(check2)
