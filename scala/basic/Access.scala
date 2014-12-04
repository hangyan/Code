package society {
  package professional {
    class Excutive {
      private[professional] var workDetails = null
      private[society] var friends = null
      private[this] var secrets = null

      def help(another : Executive) {
        println(another.workDetails)
        println(another.secrets)
      }
    }
  }
}
