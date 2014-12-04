import scala.actors._
import Actor._
import scheduler._

trait SingleThreadActor extends Actor {
  override protected def scheduler() = new SingleThreadedScheduler
}


class MyActor1 extends Actor {
  def act() = println("Actor1 running in " + Thread.currentThread)
}

class MyActor2 extends SingleThreadActor {
  def act() = println("Actor2 running in " + Thread.currentThread)
}

println("Main Running in " + Thread.currentThread)
new MyActor1().start()
new MyActor2().start()

actor { println("Actor3 running in " + Thread.currentThread)}


receiveWithin(5000) { case _ => }
