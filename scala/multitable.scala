def makeRowSeq(row: Int) =
  for (col <- 1 to 10) yield {
    val prod = (row * col).toString
    val padding = " " * (4 - prod.length)
    padding + prod
  }


def makeRow(row: Int) = makeRowSeq(row).mkString

def multiTable() = {
  
