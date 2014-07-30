import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;


public class MapMemeryBuffer {
    public static void main(String[] args) throws Exception {
        ByteBuffer byteBuf = ByteBuffer.allocate(1024*14*1024);
        byte[] bbb = new byte[14*1024*1024];
        FileInputStream fis = new FileInputStream("data/test");
        FileOutputStream fos = new FileOutputStream("data/test.out");
        FileChannel fc = fis.getChannel();

        long timeStart = System.currentTimeMillis();
        fc.read(byteBuf);
        long timeEnd = System.currentTimeMillis();
        System.out.println("Read Time:" + (timeEnd - timeStart) + "ms");

        timeStart = System.currentTimeMillis();
        fos.write(bbb);

        timeEnd = System.currentTimeMillis();
        System.out.println("write time:" + (timeEnd - timeStart) + "ms");
        fos.flush();
        fc.close();
        fis.close();
    }
}
        


