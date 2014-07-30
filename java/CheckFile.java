/* @(#)CheckFile.java
 */
/**
 *  Example of java native method.
 *
 * @author <a href="mailto:yayu@Hangs-MacBook-Air.local">Hang Yan</a>
 */
 
public class CheckFile {
    public native void displayHelloWorld();
    static {
        System.out.println(System.getProperty("java.library.path"));
        System.loadLibrary("test");
    }

    public static void main(String[] args) {
        new CheckFile().displayHelloWorld();
    }
}

