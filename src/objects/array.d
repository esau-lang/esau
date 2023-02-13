module LdArray;

import std.array: join, array, insertInPlace;
import std.algorithm.iteration: map;
import std.algorithm.mutation: remove;

import LdObject;



class _Append: LdOBJECT {
    LdArr x;
    this(LdArr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
    	if(args.length)
    		x.arr~=args[0];

        return new LdNone();
    }

    override string __str__() { return "append ([] object method)"; }
}

class _Pop: LdOBJECT {
    LdArr x;
    this(LdArr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){

    	auto index = x.arr.length - 1;
		LdOBJECT popped;

		if (args.length)
			index = cast(int)args[0].__num__;

		popped = x.arr[index];
		x.arr = remove(x.arr, index);

		return popped;
    }

    override string __str__() { return "pop ([] object method)"; }
}

class _Clear: LdOBJECT {
    LdArr x;
    this(LdArr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
    	x.arr.length = 0;

		return new LdNone();
    }

    override string __str__() { return "clear ([] object method)"; }
}

class _Copy: LdOBJECT {
    LdArr x;
    this(LdArr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
		return new LdArr(x.arr.dup);
    }

    override string __str__() { return "copy ([] object method)"; }
}

class _Insert: LdOBJECT {
    LdArr x;
    this(LdArr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
    	if (args.length > 1)
    		insertInPlace(x.arr, cast(int)args[0].__num__, args[1]);
		
		return new LdNone();
    }

    override string __str__() { return "insert ([] object method)"; }
}
