module lDict;


import std.algorithm;
import std.array;
import std.range;

import LdObject;



class oDict: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "copy": new _Copy(),
            "keys": new _Keys(),

            "get": new _Get(),
            "values": new _Values(),

            "clear": new _Clear(),
            "pop": new _Pop(),

            "update": new _Update(),
            "rehash": new _Rehash(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdHsh(assocArray(zip(args[0].__array__.map!(i => i.__str__), args[1].__array__)));
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "dict (native module)"; }
}


class _Clear: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        clear(args[0].__hash__);
        return RETURN.A;
    }
    override string __str__() { return "dict.clear (method)"; }
}

class _Get: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return args[0].__hash__[args[1].__str__];
    }
    override string __str__() { return "dict.get (method)"; }
}

class _Pop: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        auto pop = args[0].__hash__[args[1].__str__];
        (args[0].__hash__).remove(args[1].__str__);

        return pop;
    }

    override string __str__() { return "dict.pop (method)"; }
}

class _Update: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        auto dt = args[0].__hash__;
        args[1].__hash__.keys().each!(i => dt[i] = args[1].__hash__[i]);
        
        rehash(dt);
        return RETURN.A;
    }

    override string __str__() { return "dict.update (method)"; }
}

class _Copy: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdHsh(args[0].__hash__.dup);
        return RETURN.A;
    }

    override string __str__() { return "dict.copy (method)"; }
}

class _Keys: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdArr(cast(LdOBJECT[])(args[0].__hash__.keys).map!(a => new LdStr(a)).array);
    }

    override string __str__() { return "dict.keys (method)"; }
}

class _Values: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdArr(args[0].__hash__.values());
    }

    override string __str__() { return "dict.values (method)"; }
}

class _Rehash: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        rehash(args[0].__hash__);
        return RETURN.A;
    }

    override string __str__() { return "dict.rehash (method)"; }
}