import java.util.ArrayList
import org.junit.Test
import org.junit.Assert._

class SampleTest {
  @Test def listAdd() {
    var list = new ArrayList[String]
    list.add("Milk")
    list add "sugar"
    assertEquals(2, list.size())
  }
}
