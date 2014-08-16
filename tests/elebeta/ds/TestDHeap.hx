package elebeta.ds;

import elebeta.ds.DHeap;
import utest.Assert;

@:publicFields
class TestDHeap {

    function new() {}

    function minIntHeap(parent : Int, child : Int) {
        return parent <= child;
    }

    function maxIntHeap(parent : Float, child : Float) {
        return parent >= child;
    }

    function testMinIntHeap() {
        var heap = DHeapMacro.createClass( (_ : Int), (_ : {
            override function checkProperty(parent:Int, child:Int) 
            {
                return parent <= child;
            }
        }));
        var heap = new DebugDHeap(heap);
        //var heap = new DebugDHeap({checkProperty : minIntHeap});
        heap.insert(3);
        Assert.same([3], heap.dump());
        heap.insert(2);
        Assert.same([2, 3], heap.dump());
        heap.insert(5);
        Assert.same([2, 3, 5], heap.dump());
        heap.insert(9);
        Assert.same([2, 3, 5, 9], heap.dump());
        heap.insert(1);
        Assert.same([1, 2, 5, 9, 3], heap.dump());
        heap.update(5, 4);
        Assert.same([1, 2, 4, 9, 3], heap.dump());
        heap.update(2, 10);
        Assert.same([1, 3, 4, 9, 10], heap.dump());
        Assert.equals(1, heap.peek());
        Assert.equals(1, heap.extractRoot());
        Assert.same([3, 9, 4, 10], heap.dump());
        Assert.equals(3, heap.peek());
        Assert.equals(3, heap.extractRoot());
        Assert.same([4, 9, 10], heap.dump());
    }

}

@:forward @:access(elebeta.ds.DHeap)
abstract DebugDHeap<A>(DHeap<A>) {

    public
    function new(conf) {
        this = conf;
    }

    public
    function dump() {
        return fullDump().slice(0, this.length);
    }

    public
    function fullDump() {
        return this.internal.toArray();
    }

}

