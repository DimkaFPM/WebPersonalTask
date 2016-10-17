import com.wolfram.jlink.*;

public class Main {

    public static void main(String[] args) throws MathLinkException, ExprFormatException {
        KernelLink kernelLink = createKernelLink();

       testTestArrayPackage(kernelLink);
        testEquationPackage(kernelLink);
        testLabs23SolverPackage(kernelLink);
    }

    private static KernelLink createKernelLink() throws MathLinkException {
        //TODO fix path according to your computer
        String path = "-linkmode launch -linkname 'C:/Program Files/Wolfram Research/Mathematica/9.0/MathKernel'";
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

    private static void testEquationPackage(KernelLink kernelLink) throws MathLinkException {
        kernelLink.evaluate("<<" + "EquationPackage.m");//подключаем пакет
        kernelLink.discardAnswer();// дожидаемся загрузки

        kernelLink.putFunction("EvaluatePacket", 1);
            kernelLink.putFunction("getEquation", 2);
                kernelLink.put(getLeftPartsParameters());
                kernelLink.putSymbol("x");

        kernelLink.endPacket();
        kernelLink.waitForAnswer();
        System.out.println(kernelLink.getExpr());
    }

    private static void testLabs23SolverPackage(KernelLink kernelLink) throws MathLinkException, ExprFormatException {
        kernelLink.evaluate("<<" + "Labs23Solver.m");//подключаем пакет
        kernelLink.discardAnswer();// дожидаемся загрузки

        kernelLink.putFunction("EvaluatePacket", 1);
            kernelLink.putFunction("Export", 2);
                kernelLink.put("result.nb");
                kernelLink.putFunction("TestSolve", 10);
                    kernelLink.putSymbol("x");
                    kernelLink.putSymbol("y");
                    kernelLink.put(ks);
                    kernelLink.put(is);
                    kernelLink.put(createU());
                    kernelLink.put(createUt());
                    kernelLink.put(createUc());
                    kernelLink.put(createA());
                    kernelLink.put(getLeftPartsParameters());
                    kernelLink.put(createRightParts());
        kernelLink.endPacket();
        kernelLink.waitForAnswer();
        Expr expr = kernelLink.getExpr();
        System.out.println(expr.asString());
    }

    public static final int ks = 4;
    public static final int is = 6;

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

    private static int[][][] getLeftPartsParameters() {
        return new int[][][]{
                {{4, 1, 1, 3}, {2, 1, 2, 1}, {6, 1, 2, 6}, {7, 1, 3, 4}, {3, 1, 3, 6}, {4, 1, 4, 6}, {5, 1, 5, 4},
                        {6, 1, 6, 5}, {3, 2, 1, 3}, {7, 2, 1, 4}, {2, 2, 1, 5}, {3, 2, 1, 6}, {7, 2, 2, 6}, {7, 2, 3, 2},
                        {10, 2, 3, 4}, {9, 2, 4, 6}, {7, 3, 1, 3}, {5, 3, 1, 5}, {7, 3, 2, 1}, {1, 3, 2, 6}, {10, 3, 4, 6},
                        {3, 3, 5, 2}, {6, 3, 5, 4}, {4, 3, 6, 5}, {8, 4, 1, 4}, {8, 4, 1, 5}, {2, 4, 1, 6}, {8, 4, 2, 1},
                        {1, 4, 2, 6}, {2, 4, 3, 2}, {2, 4, 3, 4}, {2, 4, 3, 6}, {9, 4, 4, 6}, {1, 4, 5, 4}},
                {{3, 1, 1, 3}, {7, 1, 2, 1}, {7, 1, 2, 6}, {3, 1, 3, 4}, {2, 1, 3, 6}, {5, 1, 4, 6}, {6, 1, 5, 4},
                        {8, 1, 6, 5}, {9, 2, 1, 3}, {6, 2, 1, 4}, {7, 2, 1, 5}, {8, 2, 1, 6}, {7, 2, 2, 6}, {8, 2, 3, 2},
                        {8, 2, 3, 4}, {3, 2, 4, 6}, {5, 3, 1, 3}, {9, 3, 1, 5}, {4, 3, 2, 1}, {7, 3, 2, 6}, {8, 3, 4, 6},
                        {4, 3, 5, 2}, {3, 3, 5, 4}, {2, 3, 6, 5}, {4, 4, 1, 4}, {2, 4, 1, 5}, {4, 4, 1, 6}, {8, 4, 2, 1},
                        {7, 4, 2, 6}, {10, 4, 3, 2}, {3, 4, 3, 4}, {2, 4, 3, 6}, {2, 4, 4, 6}, {2, 4, 5, 2}, {7, 4, 5, 4}},
                {{1, 1, 1, 3}, {1, 2, 1, 3}, {1, 3, 1, 3}},
                {{1, 2, 1, 5}, {1, 3, 1, 5}, {1, 4, 1, 5}},
                {{1, 1, 5, 4}, {1, 3, 5, 4}, {1, 4, 5, 4}}
        };
    }

    private static int[] createRightParts() {
        return new int[]{853, 908, 11, 17, 15};
    }
}
