class ListTest extends org.scalatest.Suite {
  def testListEmpty() {
    val list = new java.util.ArrayList[Integer]
    assert(0 == list.size)
  }

  def testListAdd() {
    val list = new java.util.ArrayList[Integer]
    list.add(1)
    list add 4
    assert(2 == list.size)
  }
}

