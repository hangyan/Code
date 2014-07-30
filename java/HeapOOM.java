/* @(#)HeapOOM.java
 */
/**
 * 
 *
 * @author <a href="mailto:yayu@Hangs-MacBook-Air.local">Hang Yan</a>
 */

import java.util.*;


public class HeapOOM
{
    static class OOMObject {

    }

    public static void main(String[] args) {
        List<OOMObject> list = new ArrayList<OOMObject>();

        while(true) {
            list.add(new OOMObject());
        }
    }
}
