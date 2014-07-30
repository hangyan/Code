class Rational(n: Int,d: Int) {
  require(d != 0)
  val numer: Int = n
  val denom: Int = d

  override def toString = numer + "/" + denom

  def add(that: Rational):Rational =
    new Rational (
      numer * that.denom + that.numer * denom,
      denom * that.denom
    )

  def lessThan(that: Rational) =
    this.numer * that.denom < that.numer * this.denom

}

