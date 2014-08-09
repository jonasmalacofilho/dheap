package elebeta.ds;

import elebeta.ds.DAryHeap;
import utest.Assert;

using TestDAryHeap.DAryHeapHelpers;

@:publicFields
class TestDAryHeap {

    function new() {}

    function minIntHeap(parent : Int, child : Int) {
        return parent <= child;
    }

    function maxIntHeap(parent : Float, child : Float) {
        return parent >= child;
    }

    function testMinIntHeap() {
        var heap = new DAryHeap({checkProperty : minIntHeap});
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

    private
    function dumpHeap<A>(heap : DAryHeap<A>) {
        var length = heap.length;
        var internal = heap.fullDump();
        return 'Heap { len: $length, internal: ${internal.length}/${internal.toString()} }';
    }

}

@:publicFields
class DAryHeapHelpers {

    static function dump<A>(heap : DAryHeap<A>) {
        return heap.fullDump().slice(0, heap.length);
    }

    static function fullDump<A>(heap : DAryHeap<A>) {
        var internal : haxe.ds.Vector<A> = untyped heap.internal;
        return internal.toArray();
    }
    
}

