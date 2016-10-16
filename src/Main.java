import com.wolfram.jlink.KernelLink;
import com.wolfram.jlink.MathLinkException;
import com.wolfram.jlink.MathLinkFactory;

public class Main {

    public static void main(String[] args) throws MathLinkException {
        KernelLink kernelLink = createKernelLink();

        testTestArrayPackage(kernelLink);
        testLabs23SolverPackage(kernelLink);
    }

    private static KernelLink createKernelLink() throws MathLinkException {
        //TODO fix path according to your computer
        String path = "-linkmode launch -linkname 'D:/Wolfram Research/Mathematica/9.0/MathKernel'";
        KernelLink kernelLink = MathLinkFactory.createKernelLink(path);// подключаем ядро
        kernelLink.discardAnswer();//дожидаемся загрузки

        return kernelLink;
    }

    private static void testTestArrayPackage(KernelLink kernelLink) throws MathLinkException {
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

    private static void testLabs23SolverPackage(KernelLink kernelLink) throws MathLinkException {
        kernelLink.evaluate("<<" + "Labs23Solver.m");//подключаем пакет
        kernelLink.discardAnswer();// дожидаемся загрузки

        kernelLink.putFunction("EvaluatePacket", 1);

        kernelLink.putFunction("SolveLabs23", 8);
        kernelLink.put(4);//ks
        kernelLink.put(6);//is
        kernelLink.put(createU());
        kernelLink.put(createUt());
        kernelLink.put(createUc());
        kernelLink.put(createA());
        //TODO add leftParts as argument
        kernelLink.put(createRightParts());

        kernelLink.endPacket();
        kernelLink.waitForAnswer();

        //TODO result output
    }

    private static int[][][] createU() {
        return new int[][][]{
                {{1, 3}, {2, 1}, {2, 6}, {3, 4}, {3, 6}, {4, 6}, {5, 4}, {6, 5}},
                {{1, 3}, {1, 4}, {1, 5}, {1, 6}, {2, 6}, {3, 2}, {3, 4}, {4, 6}},
                {{1, 3}, {1, 5}, {2, 1}, {2, 6}, {4, 6}, {5, 2}, {5, 4}, {6, 5}},
                {{1, 4}, {1, 5}, {1, 6}, {2, 1}, {2, 6}, {3, 2}, {3, 4}, {3, 6}, {4, 6}, {5, 2}, {5, 4}}
        };

    }

    private static int[][][] createUt() {
        return new int[][][]{
                {{2, 1}, {2, 6}, {3, 4}, {4, 6}, {5, 4}},
                {{1, 3}, {1, 5}, {1, 6}, {2, 6}, {4, 6}},
                {{1, 3}, {1, 5}, {2, 6}, {4, 6}, {5, 2}},
                {{1, 4}, {1, 5}, {2, 6}, {3, 2}, {4, 6}}
        };

    }

    private static int[][][] createUc() {
        return new int[][][]{
                {},
                {{3, 4}},
                {{2, 1}, {5, 4}},
                {{3, 4}, {5, 2}}
        };
    }

    private static int[][] createA() {
        return new int[][]{
                {-3, 16, 9, -11, 3, -14},
                {26, 2, 6, -5, -6, -23},
                {7, 4, -1, -7, -2, -1},
                {5, 8, 11, -15, -2, -7}
        };
    }

    private static int[] createRightParts() {
        return new int[]{853, 908, 11, 17, 15};
    }
}
