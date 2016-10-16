import com.wolfram.jlink.KernelLink;
import com.wolfram.jlink.MathLinkException;
import com.wolfram.jlink.MathLinkFactory;

public class Main {

    public static void main(String[] args) throws MathLinkException {
        KernelLink kernelLink = createKernelLink();

        testWorkWithTestArrayPackage(kernelLink);
        testWorkWithLabs23SolverPackage(kernelLink);
    }

    private static KernelLink createKernelLink() throws MathLinkException {
        //TODO fix path according to your computer
        String path = "-linkmode launch -linkname 'D:/Wolfram Research/Mathematica/9.0/MathKernel'";
        KernelLink kernelLink = MathLinkFactory.createKernelLink(path);// подключаем ядро
        kernelLink.discardAnswer();//дожидаемся загрузки

        return kernelLink;
    }

    private static void testWorkWithTestArrayPackage(KernelLink kernelLink) throws MathLinkException {
        kernelLink.evaluate("<<" + "TestArray.m");//подключаем пакет
        kernelLink.discardAnswer();// дожидаемся загрузки

        kernelLink.putFunction("EvaluatePacket", 1);

        kernelLink.putFunction("SumArray", 1);
        kernelLink.put(new int[]{1, 2, 3});

        kernelLink.endPacket();
        kernelLink.waitForAnswer();

        int result = kernelLink.getInteger();
        System.out.println(String.format("Sum: %d", result));
    }

    private static void testWorkWithLabs23SolverPackage(KernelLink kernelLink) throws MathLinkException {
        kernelLink.evaluate("<<" + "Labs23Solver.m");//подключаем пакет
        kernelLink.discardAnswer();// дожидаемся загрузки

        kernelLink.putFunction("EvaluatePacket", 1);

        kernelLink.endPacket();
        kernelLink.waitForAnswer();
    }

}
