import java.util._

abstract class Writer {
  def writeMessage(message: String)
}

trait UpperCaseWriter extends Writer {
  abstract override def writeMessage(message: String) = {
    super.writeMessage(message.toUpperCase)
  }
}

trait ProfanityFilteredWriter extends Writer {
  abstract override def writeMessage(message: String) =
    super.writeMessage(message.replace("stupid","s-----"))
}


class StringWriterDelegate extends Writer {
  val writer = new java.io.StringWriter
  def writeMessage(message: String) = writer.write(message)
  override def toString() : String = writer.toString
}


val myWriterProfanityFirst =
  new StringWriterDelegate with UpperCaseWriter with ProfanityFilteredWriter

myWriterProfanityFirst writeMessage "There is no sin except stupidity"
println(myWriterProfanityFirst)



class DateHelper(number: Int) {
  def days(when: String) : Date = {
    var date = Calendar.getInstance()
    when match{
      case DateHelper.ago => date.add(Calendar.DAY_OF_MONTH,-number)
      case DateHelper.from_now => date.add(Calendar.DAY_OF_MONTH, number)
      case _ => date
    }
    date.getTime()
  }
}

object DateHelper {
  val ago = "ago"
  val from_now = "from_now"
  implicit def convertInt2DateHelper(number: Int) = new DateHelper(number)
}


val pst = 2 days ago
val appointment = 5 days from_now
println(pst)
println(appointment)



