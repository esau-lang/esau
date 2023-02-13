module LdChar;


import std.format: format;
import std.algorithm.iteration: each;


import LdObject;


class _Decode: LdOBJECT {
    LdChr x;
    this(LdChr x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(cast(string)x._chars);
    }

    override string __str__() { return "length (b'' object method)"; }
}

class _Add: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	char[] y;
    	args.each!(n => y ~= n.__chars__);

        return new LdChr(y);
    }

    override string __str__() { return "add (static bytes object method)"; }
}
