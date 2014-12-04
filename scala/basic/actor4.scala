import scala.actors._
import Actor._

class AnsweringService(val folks: String*) extends Actor {
  def act() {
    while(true) {
      receive {
        case (caller : Actor, name : String, msg : String) =>
          caller ! (
            if (folks.contains(name))
              String.format("Hey it's %s got message %s",name,msg)
            else
              String.format("hey there's no one with the name %s here",name)
          )
        case "ping" => println("ping!")
        case "quit" => println("exiting actor")
          exit

      }
    }
  }
}

val answeringService1 = new AnsweringService("Sara","Kara","John")
answeringService1 ! (self, "Sara", "In town")
answeringService1 ! (self, "Kara", "Go shoppng?")

answeringService1.start()

answeringService1 ! (self, "John", "Bug fixed")
answeringService1 ! (self, "Bill", "What's up")

for(i <- 1 to 4) {receive { case msg => println(msg)}}

answeringService1 ! "ping"
answeringService1 ! "quit"
answeringService1 ! "ping"

Thread.sleep(2000)
println("The last ping was not processed")



