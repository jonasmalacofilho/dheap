import utest.Runner;
import utest.ui.Report;

class DHeapTests {

    static function main() {
        var runner = new Runner();

        runner.addCase(new elebeta.ds.TestDAryHeap());

        Report.create(runner);
        runner.run();
    }

}

