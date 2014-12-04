def activity(day: String) {
  day match {
    case "Sunday" => print("Eat, Sleep,repeat...")
    case "Saturday" => print("Hangout with friends...")
    case "Monday" => print("...code for fun...")
    case "Friday" => print("...read a good book...")
  }
}

List("Monday", "Sunday", "Saturday").foreach { activity}
println()


sealed abstract  class Trade()
case class Sell(stockSymbol: String, quantity: Int) extends Trade
case class Buy(stockSymbol: String, quantity: Int) extends Trade
case class Hedge(stockSymbol: String, quantity: Int) extends Trade

class TradeProcessor {
  def processTransaction(request : Trade) {
    request match {
      case Sell(stock, 1000) => println("selling 1000-units of " + stock)
      case Sell(stock, quantity) =>
        printf("selling %d units of %s\n", quantity, stock)
      case Buy(stock,quantity) if (quantity > 2000) =>
        printf("Buying %d (large) units of %s\n", quantity,stock)
      case Buy(stock, quantity) =>
        printf("Buying %d units of %s\n", quantity, stock)
    }
  }
}

val tradeProcessor = new TradeProcessor
tradeProcessor.processTransaction(Sell("GOOG",500))
tradeProcessor.processTransaction(Buy("GOOG",700))
tradeProcessor.processTransaction(Sell("GOOG", 1000))
tradeProcessor.processTransaction(Buy("GOOG", 3000))

object StockService {
  def process(input : String) {
    input match {
      case Symbol() => println("Look up price for valid symbol " + input)
      case ReceiveStockPrice(symbol @ Symbol(), price) =>
        printf("Received price %f for symbol %s\n", price, symbol)
      case _ => println("Invalid input " + input)
    }
  }
}

object Symbol  {
  def unapply(symbol : String) : Boolean = symbol == "GOOG" || symbol == "IBM"
}

object ReceiveStockPrice {
  def unapply(input: String) : Option[(String, Double)] = {
    try {
      if (input contains ":") {
        val splitQuote = input split ":"
        Some(splitQuote(0), splitQuote(1).toDouble)
      }
      else {
        None}
    }
    catch {
      case _  : NumberFormatException => None
    }
  }
}

StockService process "GOOG"
StockService process "GOOG:310.84"
StockService process "GOOG:BUY"
StockService process "ERR:12.21"

val pattern = "(S|s)cala".r
val str = "Scala is scalable and cool"
println((pattern findAllIn str).mkString(", "))

println("cool".r replaceFirstIn(str, "awesome"))





def process(input : String) {
  val MatchStock = """^(.+):(\d*\.\d+)""".r
  input match {
    case MatchStock("GOOG",price) => println("Price of GOOG is " + price)
    case MatchStock("IBM",price) => println("IBM's trading at " + price)
    case MatchStock(symbol,price) => println("Price of %s is %s \n",symbol,price)
    case _ => println("not processing " + input)
  }
}


process("GOOG:310.84")
process("IBM:84.01")
process("GE:15.96")

