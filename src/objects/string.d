module LdString;

import std.conv: to;
import std.format: format;

import std.string: strip;
import std.array: array, split, join;

import std.algorithm.iteration: map, each;


import LdObject;


class oStr: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "add": new _Add(),
            "strip": new _Strip(),

            "split": new _Split(),
            "encode": new _Encode(),

            "join": new _Join(),
        ];
    }

    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length)
            return new LdStr(args[0].__str__);
        
        return new LdStr("");
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__(){ return "str (native module)"; }
}



class _Encode: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdChr(cast(char[])args[0].__str__);
    }

    override string __str__() { return "str.encode (method)"; }
}

class _Strip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            return new LdStr(strip(args[0].__str__, args[1].__str__));
        
        return new LdStr(strip(args[0].__str__));
    }

    override string __str__() { return "str.strip (method)"; }
}

class _Split: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        string[] arr;

        if (args.length > 1)
            arr = split(args[0].__str__, args[1].__str__);
        else
            arr = (args[0].__str__).split;

        return new LdArr(cast(LdOBJECT[])arr.map!(n => new LdStr(n)).array);
    }
    override string __str__() { return "str.split (method)"; }
}

class _Add: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        string x;
        args.each!(i => x~=i.__str__);
        return new LdStr(x);
    }

    override string __str__() { return "str.add (method)"; }
}


import std.stdio;


class _Join: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 1)
            return new LdStr(args[0].__array__.map!(i => i.__str__).join(args[1].__str__));

        return new LdStr(args[0].__array__.map!(i => i.__str__).join);
    }

    override string __str__() { return "str.join  method)"; }
}
