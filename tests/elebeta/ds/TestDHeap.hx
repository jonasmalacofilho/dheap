package elebeta.ds;

import elebeta.ds.DHeap;
import utest.Assert;

@:access(elebeta.ds.DHeap)
@:forward
private abstract DebugDHeap<A>(DHeap<A>) {

    function get_arity() return this.arity;
    public var arity(get, never):Int;

    public function new(conf, arity:Null<Int>)
    {
        this = new DHeap<A>(conf, arity);
    }

    public function dump()
    {
        return fullDump().slice(0, this.length);
    }

    public function fullDump()
    {
        return this.internal.toArray();
    }

}

private typedef Element = {
    key : Int,
    ?pos : Int  // position on heap
}

class TestDHeap {

    // simple min int heap usage
    public function test_01_MinSimpleHeap()
    {
        function prop(parent:Int, child:Int)
            return parent <= child;

        var heap = new DebugDHeap({ checkProperty : prop }, 2);
        var x:Int;

                                                Assert.equals(0, heap.length);
        heap.insert(3);                         Assert.same([3], heap.dump());
        heap.insert(2);                         Assert.same([2,3], heap.dump());
        heap.insert(5);                         Assert.same([2,3,5], heap.dump());
        heap.insert(9);                         Assert.same([2,3,5,9], heap.dump());
        heap.insert(1);                         Assert.same([1,2,5,9,3], heap.dump());
                                                Assert.equals(5, heap.length);
        heap.update(5,4);                       Assert.same([1,2,4,9,3], heap.dump());
        heap.update(2,10);                      Assert.same([1,3,4,9,10], heap.dump());
                                                Assert.equals(5, heap.length);
        x = heap.peek();                        Assert.equals(1, x);
        x = heap.extractRoot();                 Assert.equals(1, x);
                                                Assert.same([3,9,4,10], heap.dump());
        x = heap.peek();                        Assert.equals(3, x);
        x = heap.extractRoot();                 Assert.equals(3, x);
                                                Assert.same([4,9,10], heap.dump());
                                                Assert.equals(3, heap.length);
    }

    // simple max int heap usage
    public function test_02_MaxSimpleHeap()
    {
        function prop(parent:Int, child:Int)
            return parent >= child;

        var heap = new DebugDHeap({ checkProperty : prop }, 2);
        var x:Int;

                                                Assert.equals(0, heap.length);
        heap.insert(3);                         Assert.same([3], heap.dump());
        heap.insert(4);                         Assert.same([4,3], heap.dump());
        heap.insert(1);                         Assert.same([4,3,1], heap.dump());
        heap.insert(-3);                        Assert.same([4,3,1,-3], heap.dump());
        heap.insert(5);                         Assert.same([5,4,1,-3,3], heap.dump());
                                                Assert.equals(5, heap.length);
        heap.update(1,2);                       Assert.same([5,4,2,-3,3], heap.dump());
        heap.update(4,-4);                      Assert.same([5,3,2,-3,-4], heap.dump());
                                                Assert.equals(5, heap.length);
        x = heap.peek();                        Assert.equals(5, x);
        x = heap.extractRoot();                 Assert.equals(5, x);
                                                Assert.same([3,-3,2,-4], heap.dump());
        x = heap.peek();                        Assert.equals(3, x);
        x = heap.extractRoot();                 Assert.equals(3, x);
                                                Assert.same([2,-3,-4], heap.dump());
                                                Assert.equals(3, heap.length);
    }

    // efficient (non-linear) updates thanks to external position storage
    // checks if getPosition and savePosition work as expected
    // assumes testMinSimpleHeap will also be run
    public function test_03_ComplexHeap()
    {
        var cfg = {
            checkProperty:  function (parent:Element,child:Element) return parent.key <= child.key,
            getPosition:    function (el:Element) return el.pos,
            savePosition:   function (el:Element, pos:Int) return el.pos = pos
         // clearPosition:  automatically computed from savePosition (pos == -1 => invalid)
         // contains:       defaults to a linear search for equality (==)
        };

        function assertOk(exp:Array<Int>, rec:Array<Element>, ?pos:haxe.PosInfos)
        {
            var exp = Lambda.array(Lambda.mapi(exp, function (i, x) return { key : x, pos : i }));
            Assert.same(exp, rec, pos);
        }

        var heap = new DebugDHeap(cfg, 2);
        var x:Element, xs:Array<Element>;

        xs = [];
        heap.insert(xs[3] = { key : 3 });       assertOk([3], heap.dump());
        heap.insert(xs[2] = { key : 2 });       assertOk([2,3], heap.dump());
        heap.insert(xs[5] = { key : 5 });       assertOk([2,3,5], heap.dump());
        heap.insert(xs[9] = { key : 9 });       assertOk([2,3,5,9], heap.dump());
        heap.insert(xs[1] = { key : 1 });       assertOk([1,2,5,9,3], heap.dump());
        xs[5].key = 4; heap.update(xs[5]);      assertOk([1,2,4,9,3], heap.dump());
        xs[2].key = 10; heap.update(xs[2]);     assertOk([1,3,4,9,10], heap.dump());
        x = heap.peek();                        Assert.equals(xs[1], x);
        x = heap.extractRoot();                 Assert.equals(xs[1], x);
        x = heap.peek();                        Assert.equals(xs[3], x);
        x = heap.extractRoot();                 Assert.equals(xs[3], x);
                                                assertOk([4,9,10], heap.dump());
    }

    // make sure it works with checkProperty functions that always
    // return true or false (independently of its inputs) or that
    // are not deterministic
    public function test_04_UnusualProperties()
    {
        function cp1(parent:Int, child:Int) return true;
        function cp2(parent:Int, child:Int) return false;
        function cp3(parent:Int, child:Int) return Math.random() > .5;

        function test(cp:Int->Int->Bool)
        {
            var cfg = { checkProperty : cp };
            var heap = new DebugDHeap(cfg, 2);
            var vals = [3,2,5,9,1];
            for (v in vals)
                heap.insert(v);
            Assert.equals(vals.length, heap.length);
            for (v in vals)
                heap.extractRoot();
            Assert.equals(0, heap.length);
            return true;
        }
        Assert.isTrue(test(cp1));
        Assert.isTrue(test(cp2));
        Assert.isTrue(test(cp3));
    }

    public function test_05_Arity()
    {
        function prop(parent:Int, child:Int)
            return parent <= child;

        function test(arity)
        {
            var x:Int;
            var heap = new DebugDHeap({ checkProperty : prop }, arity);
                                                    Assert.equals(arity, heap.arity);
                                                    Assert.equals(0, heap.length);
            for (v in [3,2,5,9,1])
                heap.insert(v);
                                                    Assert.equals(5, heap.length);
            heap.update(5,4);
            heap.update(2,10);
                                                    Assert.equals(5, heap.length);
            x = heap.peek();                        Assert.equals(1, x);
            x = heap.extractRoot();                 Assert.equals(1, x);
            x = heap.peek();                        Assert.equals(3, x);
            x = heap.extractRoot();                 Assert.equals(3, x);
                                                    Assert.equals(3, heap.length);
        }

        test(1);
        test(2);
        test(3);
        test(4);
        test(16);

        Assert.raises(test.bind(0));
        Assert.raises(test.bind(-1));
    }

    public function test_06_DefaultArityValue()
    {
        var heap = new DebugDHeap({ checkProperty : function (a,b) return true }, null);
        Assert.equals(2, heap.arity);
    }

    public function new() {}
}

