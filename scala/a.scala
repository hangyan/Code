import scala.io.Source
import scala.collection.mutable.Map

if(args.length > 0) {
  for(line <- Source.fromFile(args(0)).getLines)
    print(line.length + " " + line + "\n")
}
else
  Console.err.println("Please enter filename")





