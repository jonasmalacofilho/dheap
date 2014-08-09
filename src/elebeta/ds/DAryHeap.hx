package elebeta.ds;

import haxe.ds.Vector;


/**
    A generic D-ary heap.

    Such heaps are used, for instance, for implementing priority queues.

    Weather it will be a min-heap or a max-heap and the key computation for
    complex objets depends on the heap property implicitly defined by the
    `checkProperty` function.

    In a min-heap, the root is the element with the smallest key; otherwise, in
    a max-heap, the root is element with largest key.

    Using arity greater than 2 allows decrease priority operations to be
    performed more quickly, at the expense of slower delete minimum operations.
    (wiki/check)

**/
//@:generic
class DAryHeap<A> {

    /**
        Number of elements.
    **/
    public
    var length(default, null) : Int;

    public
    function new(conf : { checkProperty : A -> A -> Bool }, ?arity=2) {
        // maybe: move arity to @:genericBuild
        this.arity = arity;
        length = 0;
        // to do: configure
        checkProperty = conf.checkProperty;
    }

    /**
        Return if the heap is empty.
    **/
    public inline
    function isEmpty() {
        return length == 0;
    }

    /**
        Peek at the root.

        If there are no elements in the heap, fail with "EmptyHeap".
    **/
    public
    function peek() : A {
        if (isEmpty())
            throw "Empty heap";
        return get(0);
    }

    /**
        Remove and return the root.

        If there are no elements in the heap, fail with "EmptyHeap".
    **/
    public
    function extractRoot() : A {
        var root = peek();
        deleteRoot();
        return root;
    }

    /**
        Remove the root, if one exists.
        
        Return if any item was removed.
    **/
    public
    function deleteRoot() : Bool {
        // if empty, there is nothing to do
        if (isEmpty())
            return false;

        // swap the root by the last item and heapify downwards;
        // this will temporarily save index = length -1 to the former root, but
        // it should not matter
        swap(0, --length);  // it does not matter if length was 1
        fixDown(0);
        clearPosition(get(length));  // length already decremented
        return true;
    }

    /**
        Insert an element.
    **/
    public
    function insert(item : A) {
        fitForInsertion();
        set(length, item);
        fixUp(length++);
    }

    /**
        Notify of an update to `item` or optionally replace it.
    **/
    public
    function update(item : A, ?with : Null<A>) {
        var pos = getPosition(item);
        if (item != get(pos))
            throw "No valid position found for item";

        if (with != null) {
            clearPosition(item);
            set(pos, with);
        }

        var fup = fixUp(pos);
        // if no upwards change was necessary, a downwards one might be needed
        if (fup == pos)
            fixDown(pos);
    }

    // to do: (fast) heapify
    // maybe: merge, meld

    // Heap configuration

    var arity : Int;

    // alocated length := internal.length
    var internal : Vector<A>;

    // check if `parent` and `child` respect the heap property;
    // implicitly sets the heap property and the key computation from elements;
    // also used to find the best child to swap with on a fixDown
    dynamic
    function checkProperty(parent : A, child : A) : Bool {
        throw "Heap property undefined";
    }

    // position not necessary equal to index (only in this particular
    // implementation)

    dynamic
    function getPosition(item : A) : Int {
        // defaults to a linear search
        var pos = 0;
        while (pos < internal.length) {
            if (get(pos) == item)
                return pos;
            pos++;
        }
        throw "Item not found";
    }

    dynamic
    function savePosition(item : A, pos : Int) : Int {
        // defaults to noop
        return pos;
    }

    dynamic
    function clearPosition(item : A) : Void {
        // defaults to saving -1
        savePosition(item, -1);
    }

    dynamic
    function contains(item : A) : Bool {
        // defaults to linear search
        return false;  // to do
    }

    // Wrapper around internal data structure

    inline
    function get(pos) {
        return internal.get(pos);
    }

    inline
    function set(pos, item) {
        savePosition(item, pos);
        return internal.set(pos, item);
    }

    function fitForInsertion() {
        if (length == 0) {
            internal = new Vector(arity);
        }
        else if (length == internal.length) {
            var dest = new Vector(internal.length*2);
            Vector.blit(internal, 0, dest, 0, length);
            internal = dest;
        }
    }
    
    // Basic stuff

    inline
    function parent(pos : Int) {
        // fails if pos == 0
        // maybe: optimize for arity == 2^p, based on @:genericBuild
        return Std.int((pos - 1)/arity);
    }

    inline
    function child(pos, no) {
        return pos*arity + no;
    }

    inline
    function swap(posa, posb) {
        var a = get(posa), b = get(posb);
        set(posa, b);
        set(posb, a);
    }

    // Fix heap/heapify methods

    // fix the heap upwards (torwards the parents and the root) from `pos`;
    // return the final (possibly updated) position
    function fixUp(pos) {
        while (pos > 0 && !checkProperty(get(parent(pos)), get(pos))) {
            swap(pos, parent(pos));
            pos = parent(pos);
        }
        return pos;
    }

    // fix the heap downwards (torwards the children) from `pos`;
    // return the final (possibly updated) position
    function fixDown(pos) {
        while (true) {
            var change = pos;
            var someChild = child(pos, 1), lastChild = child(pos, arity);
            while (someChild <= lastChild && someChild < length ) {
                // update when `someChild` is more parentish than `change`
                if (checkProperty(get(someChild), get(change))) 
                    change = someChild;
                someChild++;
            }
            if (change == pos)
                return pos;  // done
            swap(pos, change);
            pos = change;
        }
        return pos;
    }

}

