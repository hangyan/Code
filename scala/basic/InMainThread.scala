import scala.actors._
import Actor._
import scheduler._

if(args.length > 0 && args(0) == "Single") {
  println("command-line argument Single found")
  Scheduler.impl = new SingleThreadedScheduler
}

println("Main running in " + Thread.currentThread)
actor { println("Actor1 running in " + Thread.currentThread) }
actor { println("Actor2 running in " + Thread.currentThread) }

receiveWithin(3000) { case _ => }
