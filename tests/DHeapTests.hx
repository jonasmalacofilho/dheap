import utest.*;
import utest.ui.Report;

class DHeapTests {

    static function main() {
        var runner = new Runner();

        runner.addCase(new elebeta.ds.TestDHeap());

        Report.create(runner);

#if sys
        var res:TestResult = null;
        runner.onProgress.add(function (o) if (o.done == o.totals) res = o.result);
        runner.run();
        Sys.exit(res.allOk() ? 0 : 1);
#else
        runner.run();
#end
    }

}

