import java.net.InetAddress;

public class EnvironmentCheck {
    public static void main(String[] args) {
        System.out.println("result: " + InetAddress.getLoopbackAddress());
    }
}
