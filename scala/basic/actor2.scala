import scala.actors._
import scala.actors.Actor._



val echoActor = actor {
  while (true) {
    receive {
      case msg =>
        println("received message: " + msg)
    }
  }
}


val intActor = actor {
  receive {
    case x: Int =>
      println("Got an Int: " + x)
  }
}



object NameResolver extends Actor {
  import java.net.{InetAddress, UnknownHostException}

  def act() {
    loop {
      react {
        case (name: String, actor: Actor) =>
          actor ! getIp(name)
        case msg =>
          println("Unhandled message: " + msg)
      }
    }
  }
 


  def getIp(name: String): Option[InetAddress] = {
    try {
      Some(InetAddress.getByName(name))
    } catch {
      case _: UnknownHostException => None
    }
  }
}


val sillyActor2 = actor {
  def emoteLater() {
    val mainActor = self
    actor {
      Thread.sleep(1000)
      mainActor ! "Emote"
    }
  }

  var emoted = 0
  emoteLater()

  loop {
    react {
      case "Emote" =>
        println("I'm acting")
        emoted += 1
        if (emoted < 5)
          emoteLater()
      case msg =>
        println("Received : " + msg)
    }
  }
}


sillyActor2 ! "hi there"

