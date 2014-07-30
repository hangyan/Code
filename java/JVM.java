/* @(#)JVM.java
 */
/**
 * 
 *
 * @author <a href="mailto:yayu@Hangs-MacBook-Air.local">Hang Yan</a>
 */

public class JVM
{
    private static final int _1MB = 1024 * 1024;

    /*
      JVM args: -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails
      -XX:Survivoratio=8
     */
    public static void testAllocation() {
        byte[] allocation1,allocation2,allocation3,allocation4;
        allocation1 = new byte[2*_1MB];
        allocation2 = new byte[2*_1MB];
        allocation3 = new byte[2*_1MB];
        allocation4 = new byte[4*_1MB];
    }
    /*
       JVM args: -verbose:gc -Xms20M -Xmx20M -Xmn10M -XX:+PrintGCDetails
       -XX:Survivoratio=8 -XX:PretenureSizeThreshold=3145728
     */

    public static void testPretenureSizeThreshold() {
        byte[] allocation;
        allocation = new byte[4*_1MB];
    }

    public static void main(String[] args) {
        //testAllocation();
        testPretenureSizeThreshold();
    }
}
