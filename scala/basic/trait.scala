// class Human(val name: String) {
//   def listen() = println("Your friend " + name + " is listening")
// }

// class Man(override val name: String) extends Human(name)
// class Woman(override val name: String) extends Human(name)


trait Friend {
  val name: String
  def listen() = println("Your Friend " + name + " is listening")
}


class Human(val name: String) extends Friend
class Man(override val name: String) extends Human(name)
class Woman(override val name: String) extends Human(name)

class Animal
class Dog(val name: String) extends Animal with Friend {
  override def listen = println(name + "'s listening")
}

val john = new Man("John")
val sara = new Woman("Sara")
val comet = new Dog("Comet")

john.listen
sara.listen
comet.listen

val mansBestFriend : Friend = comet
mansBestFriend.listen

def helpAsFriend(friend: Friend) = friend listen

helpAsFriend(sara)
helpAsFriend(comet)


abstract class Check {
  def check() : String = "Checked Application Details..."
}


trait CreditCheck extends Check {
  override def check() : String = "Checked Credit..." + super.check()
}

trait EmploymentCheck extends Check {
  override def check() : String = "Checked Employment..." + super.check()
}

trait CriminalRecordCheck extends Check {
  override def check() : String = "Check Criminal Records..." + super.check()
}

val apartmentApplication = new Check with CreditCheck with CriminalRecordCheck


println(apartmentApplication check)



