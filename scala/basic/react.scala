import scala.actors.Actor._

def info(msg: String) = println(msg + " received by " + Thread.currentThread())

def receiveMessage(id : Int) {
  for(i <- 1 to 2) {
    receiveWithin(20000) {
      case msg : String => info("receive: " + id + msg)
    }
  }
}


def reactMessage(id : Int) {
  react {
    case msg : String => info("react:  " + id + msg)
      reactMessage(id)
  }
}

val actors = Array(
  actor { info("react: 1 "); reactMessage(1)},
  actor { info("react: 2 "); reactMessage(2)},
  actor { info("receive: 3"); receiveMessage(3)},
  actor { info("receive: 4"); receiveMessage(4)}
)


Thread.sleep(1000)
for(i <- 0 to 3) { actors(i) ! " hello"; Thread.sleep(2000)}
