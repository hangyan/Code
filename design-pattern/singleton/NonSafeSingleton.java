// In RMI,you will get another instantce.
public final class NonSafeSingleton implements Serializable {
  private static final NonSafeSingleton INSTANCE = new NonSafeSingleton();
  private NonSafeSingleton() {}
  public static NonSafeSingleton getInstance() {
	return INSTANCE;
  }
  // Solution 1: readResolve (jdk < 4)
  protected Object readResolve() throws ObjectStreamException {
	return INSTANCE;
  }
										
										
}


// solution 2: (JDK_VERSION > 5)
public enum SafeException implements Serializable {
  INSTANCE;
}
									 
									 
// consider multithread
public class SingletonInitiOnDemand {
  private SingletonInitiOnDemand() {
  };

  private static class SingletonHolder {
	private static final SingletonInitiOnDemand INSTANCE = new SingletonInitiOnDemand();
  }

  public static SingletonInitiOnDemand getInstance() {
	return SingletonHolder.INSTANCE;
	System.out.
  }
  
}
