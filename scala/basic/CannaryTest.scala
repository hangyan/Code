class CanaryTest extends org.scalatest.Suite {
  def testOK() {
    assert(true)
  }
}

(new CanaryTest).execute()
