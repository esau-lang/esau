module LdString;


import std.stdio;


import std.format: format;

import std.array: array, split, join, replace, replicate;

import std.uni;
import std.string;

import std.algorithm.iteration: map, each;
import std.algorithm.searching: endsWith, startsWith, count, canFind;

import LdObject;



class oStr: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "add": new _Add(),

            "strip": new _Strip(),
            "lstrip": new _LStrip(),
            "rstrip": new _RStrip(),

            "center": new _Center(),
            "ljust": new _Ljust(),
            "rjust": new _Rjust(),

            "replace": new _Replace(),
            "translate": new _Translate(),

            "split": new _Split(),
            "encode": new _Encode(),

            "join": new _Join(),
            "repeat": new _Repeat(),

            "upper": new  _Upper(),
            "lower": new  _Lower(),

            "isupper": new  _IsUpper(),
            "islower": new  _IsLower(),

            "capitalize": new _Capital(),

            "startswith": new _StartsWith(),
            "endswith": new _EndsWith(),

            "count": new _Count(),
            "isnumeric": new _IsNumeric(),

            "find": new _Find(),
            "format": new _Format(),

            "index": new _Index(),

            "isalpha": new _IsAlpha(),
            "isalnum": new _IsAlnum(),

            "isdigit": new _IsDigit(),
            "isprintable": new _IsPrintable(),
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


class _Repeat: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(replicate(args[0].__str__, cast(size_t)args[1].__num__));
    }
    override string __str__() { return "str.repeat (method)"; }
}

class _Strip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            return new LdStr(strip(args[0].__str__, args[1].__str__));
        
        return new LdStr(strip(args[0].__str__));
    }
    override string __str__() { return "str.strip (method)"; }
}

class _LStrip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            return new LdStr(stripLeft(args[0].__str__, args[1].__str__));
        
        return new LdStr(stripLeft(args[0].__str__));
    }
    override string __str__() { return "str.lstrip (method)"; }
}

class _RStrip: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            return new LdStr(stripRight(args[0].__str__, args[1].__str__));
        
        return new LdStr(stripRight(args[0].__str__));
    }
    override string __str__() { return "str.rstrip (method)"; }
}

class _Replace: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr((args[0].__str__).replace(args[1].__str__, args[2].__str__));
    }

    override string __str__() { return "str.replace (method)"; }
}

class _Translate: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        string[dchar] transTable;

        foreach(k, v; args[1].__hash__)
            transTable[k[0]] = v.__str__;

        if(args.length > 2)
            return new LdStr(translate(args[0].__str__, transTable, args[2].__str__));

        return new LdStr(translate(args[0].__str__, transTable));
    }

    override string __str__() { return "str.translate (method)"; }
}

class _Center: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 2)
            return new LdStr(center(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(center(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "str.center (method)"; }
}

class _Ljust: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 2)
            return new LdStr(leftJustify(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(leftJustify(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "str.ljust (method)"; }
}

class _Rjust: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 2)
            return new LdStr(rightJustify(args[0].__str__, cast(size_t)args[1].__num__, args[2].__str__[0]));

        return new LdStr(rightJustify(args[0].__str__, cast(size_t)args[1].__num__));
    }

    override string __str__() { return "str.rjust (method)"; }
}

class _Encode: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdChr(cast(char[])args[0].__str__);
    }

    override string __str__() { return "str.encode (method)"; }
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

class _Join: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 1)
            return new LdStr(args[0].__array__.map!(i => i.__str__).join(args[1].__str__));

        return new LdStr(args[0].__array__.map!(i => i.__str__).join);
    }

    override string __str__() { return "str.join (method)"; }
}

class _Upper: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(toUpper(args[0].__str__));
    }
    override string __str__() { return "str.upper (method)"; }
}

class _Lower: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(toLower(args[0].__str__));
    }
    override string __str__() { return "str.lower (method)"; }
}

class _Capital: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(capitalize(args[0].__str__));
    }
    override string __str__() { return "str.capitalize (method)"; }
}

class _IsNumeric: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(isNumeric(args[0].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "str.isnumeric (method)"; }
}

class _StartsWith: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if((args[0].__str__).startsWith(args[1].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "str.startswith (method)"; }
}

class _EndsWith: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if((args[0].__str__).endsWith(args[1].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "str.endswith (method)"; }
}

class _Count: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(count(args[0].__str__, args[1].__str__));
    }
    override string __str__() { return "str.count (method)"; }
}

class _Find: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        if(canFind(args[0].__str__, args[1].__str__))
            return RETURN.B;

        return RETURN.C;
    }
    override string __str__() { return "str.find (method)"; }
}

class _Index: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(indexOf(args[0].__str__, args[1].__str__));
    }
    override string __str__() { return "str.index (method)"; }
}

class _Format: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        auto s = split(args[0].__str__, "{}");
        string gen;

        for(size_t i; i < s.length-1; i++)
            gen ~= s[i] ~ args[i+1].__str__;

        gen ~= s[s.length-1];

        return new LdStr(gen);
    }
    override string __str__() { return "str.format (method)"; }
}

class _IsAlpha: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(!isAlpha(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isalpha (method)"; }
}

class _IsAlnum: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(!isNumber(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isalnum (method)"; }
}

// C Functions
import core.stdc.ctype: isdigit, isprint, isspace, isupper, islower;

class _IsLower: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(isupper(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.islower (method)"; }
}

class _IsUpper: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(islower(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isupper (method)"; }
}

class _IsDigit: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(!isdigit(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isdigit (method)"; }
}

class _IsPrintable: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(!isprint(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isprintable (method)"; }
}

class _IsSpace: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        foreach(dchar i; args[0].__str__)
            if(!isspace(i))
                return RETURN.C;

        return RETURN.B;
    }
    override string __str__() { return "str.isspace (method)"; }
}


