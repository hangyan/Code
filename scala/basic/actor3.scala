import scala.actors._
import Actor._

val fortuneTeller = actor {
  for (i <- 1 to 4) {
    Thread.sleep(1000)
    receive {
      case _ => sender ! "your day will rock!" + i
    }
  }
}

println( fortuneTeller !? (2000,"What's ahead"))
println( fortuneTeller !? (500, "What's ahead"))


val aPrinter = actor {
  receive { case msg => println("Ah, fortune message for you - " + msg)}
}

fortuneTeller.send("What's up", aPrinter)

fortuneTeller ! "How's my future"

Thread.sleep(3000)
receive { case msg : String => println("Recevied: " + msg)}

println("Let's get that lost message")
receive { case !(channel,msg) => println("Received blated massge" + msg)}

