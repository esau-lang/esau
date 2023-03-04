module LdChar;


import std.format: format;
import std.algorithm.iteration: each;


import LdObject;


class oByte: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "add": new _Add(),
            "decode": new _Decode(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args){
        return RETURN.A;
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "byte (native module)"; }
}


class _Decode: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(cast(string)(args[0].__chars__));
    }
    override string __str__() { return "byte.decode (method)"; }
}

class _Add: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	char[] y;
    	args.each!(n => y ~= n.__chars__);

        return new LdChr(y);
    }

    override string __str__() { return "byte.add (method)"; }
}
