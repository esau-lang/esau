module LdHash;


import std.format: format;

import LdObject;


class _Copy: LdOBJECT {
    LdHsh x;
    this(LdHsh x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdHsh(x.hash.dup);
    }

    override string __str__() { return "copy ({} object method)"; }
}
