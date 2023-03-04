module lList;


import std.stdio;

import std.algorithm.mutation: remove, reverse;
import std.array: insertInPlace;

import LdObject;



class oList: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "add": new _Add(),
            "append": new _Append(),

            "clear": new _Clear(),
            "copy": new _Copy(),
            
            "insert": new _Insert(),
            "pop": new _Pop(),
            
            "reverse": new _Reverse(),
            "remove": new _Remove(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr("");
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "list (native module)"; }
}


class _Add: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	*(args[0].__ptr__) ~= args[1].__array__;
		return RETURN.A;
    }

    override string __str__() { return "list.add (method)"; }
}

class _Insert: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	auto x = args[0].__array__;
    	x.insertInPlace(cast(size_t)args[1].__num__, args[2]);
		
		return RETURN.A;
    }

    override string __str__() { return "list.insert (method)"; }
}

class _Append: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	LdOBJECT[] *l = args[0].__ptr__;
    	*l ~= args[1];

		return RETURN.A;
    }

    override string __str__() { return "list.append (method)"; }
}

class _Clear: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	auto l = args[0].__ptr__;
    	(*l).length = 0;

		return RETURN.A;
    }

    override string __str__() { return "list.clear (method)"; }
}

class _Copy: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
		return new LdArr(args[0].__array__.dup);
    }

    override string __str__() { return "list.copy (method)"; }
}

class _Reverse: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
		reverse(args[0].__array__);
		return RETURN.A;
    }

    override string __str__() { return "list.reverse (method)"; }
}

class _Pop: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	LdOBJECT[] *l = args[0].__ptr__;
    	int len = cast(int)((*l).length);

    	int i;

    	if (args.length > 1)
    		i = cast(int)args[1].__num__;
    	else
    		i = len-1;

		auto popped = (*l)[i];

		remove(*l, i);
		(*l).length--;// = len-1;
		
		return popped;
    }

    override string __str__() { return "list.pop (method)"; }
}

class _Remove: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        //LdOBJECT[] *l = args[0].__ptr__;

        //remove!("a.__str__ ==" ~ args[1].__str__)(*l);

        //(*l).length--;
        
        return RETURN.A;
    }

    override string __str__() { return "list.remove (method)"; }
}
