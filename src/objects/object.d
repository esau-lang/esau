module LdObject;

import std.conv: to;
import std.format: format;
import std.algorithm.iteration: map;
import std.array: join;


class LdOBJECT {
	LdOBJECT[string] hash, props;

	static long objects;

	this(){ objects++; }

	string __str__(){ return "null";}

	string __json__(){ return __str__; }

	double __num__(){ return 0; }

	bool __stop_iteration__(){ return true; }
	
	size_t __length__(){ return 0; }

	LdOBJECT[] __array__(){ return []; }

	LdOBJECT[string] __property__ (){ return hash; }

	LdOBJECT[string] __hash__ (){ return __props__; }

	LdOBJECT[string] __props__(){ return hash; }

	char[] __chars__() { return []; }

	LdOBJECT __index__(LdOBJECT arg) {return new LdOBJECT(); }

	LdOBJECT __getProp__(string prop) {
		return __props__[prop];
	}

	LdOBJECT __setProp__(string prop, LdOBJECT value){
		__props__[prop] = value;
        return new LdOBJECT();
    }

	LdOBJECT __super__(LdOBJECT self){ return new LdOBJECT(); }

	void __assign__(LdOBJECT index, LdOBJECT value){}

	LdOBJECT opCall(LdOBJECT[] args) { return new LdOBJECT(); }

	double __true__() { return 0; }
}

alias LdOBJECT[string] HEAP;


class LdTrue: LdOBJECT {
	override string __str__(){ return "true"; }

	override double __true__() { return 1; }
}


class LdFalse: LdOBJECT {
	override string __str__(){ return "true"; }
}


class LdNone: LdOBJECT {
	override string __str__(){ return "null"; }
}


class LdStop_Iterator: LdOBJECT {
	override string __str__(){ return "stop-Iterator (core method)"; }

	override bool __stop_iteration__() { return false; }
}


class LdStr: LdOBJECT {
	string _str;
    LdOBJECT[string] props;
	
	this(string _str){
		this._str = _str;
	}

	override string __str__(){
		return _str;
	}

	override LdOBJECT __index__(LdOBJECT arg){
		return new LdStr(to!string(_str[cast(size_t)arg.__num__]));
	}

    override size_t __length__(){
        return _str.length;
    }

	override double __true__(){
		return cast(double)_str.length;
	}

	override string __json__(){
		return format("'%s'", _str);
	}
}


class LdNum: LdObject.LdOBJECT {
	double num;
	
	this(double num){
		this.num = num;
	}

	override double __num__(){
		return this.num;
	}

	override string __str__(){
		return to!string(num);
	}

	override double __true__(){
		return this.num;
	}
}


class LdChr: LdOBJECT {
	char[] _chars;
	
	this(char[] _chars){
		this._chars = _chars;
	}

	override char[] __chars__(){
		return _chars;
	}

	override size_t __length__(){
        return _chars.length;
    }

	override string __str__(){
		return format("b'%s'", cast(string)_chars);
	}

	override double __true__(){
		return cast(double)_chars.length;
	}
}


class LdHsh: LdOBJECT
{
	LdOBJECT[string] hash;
	
	this(LdOBJECT[string] hash){
		this.hash = hash;
	}

	override LdOBJECT __index__(LdOBJECT arg){
		return hash[arg.__str__];
	}

	override void __assign__(LdOBJECT index, LdOBJECT value){
		this.hash[index.__str__] = value;
	}

	override double __true__(){
		return cast(double)hash.length;
	}

	override size_t __length__(){
        return hash.length;
    }

	override string __str__(){
		string view = "{";

		foreach(k, v; hash)
			view ~= format(" %s: %s,", k, v.__json__);

		return view ~ " }";
	}

	override LdOBJECT[string] __hash__(){ return hash; }
}


class LdDict: LdOBJECT
{
	string name; LdOBJECT[string] props;
	
	this(string name, LdOBJECT[string] props){
		this.name = name;
		this.props = props;
	}

	override HEAP __props__(){ return props; }

	override string __str__(){ return name; }
}


// ARRAYS
class LdArr: LdOBJECT {
	LdOBJECT[] arr;
	HEAP props;
	
	this(LdOBJECT[] arr){
		this.arr = arr;
		this.props = [
			"__iter__": new __array_iterator(this),
		];
	}

	override LdOBJECT[] __array__(){
		return this.arr;
	}

	override size_t __length__(){
        return arr.length;
    }

	override double __true__(){
		return cast(double)arr.length;
	}

	override LdOBJECT __index__(LdOBJECT arg){
		return this.arr[cast(ulong)arg.__num__];
	}

	override void __assign__(LdOBJECT index, LdOBJECT value){
		this.arr[cast(ulong)index.__num__] = value;
	}

	override string __str__(){
		return '[' ~ arr.map!(n => n.__json__).join(", ") ~ ']';
	}

	override HEAP __props__(){ return props; }
}


class __array_iterator: LdOBJECT {
    LdArr x;
    this(LdArr x) { this.x = x; }

	override LdOBJECT opCall(LdOBJECT[] args){
        return new _ArrayIterator(x);
    }

    override string __str__() { return "__iter__ (array object method)"; }
}

class _ArrayIterator: LdOBJECT {
    int y;
    LdArr x;
    LdOBJECT z;
	LdOBJECT[string] props;
    
    this(LdArr x) {
    	this.x = x;
    	this.props = [
    		"__next__": new __next__(this),
    	];
    }

    override LdOBJECT opCall(LdOBJECT[] args){
    	if (y < x.arr.length) {
        	z = x.arr[y];
        	y++;
        	return z;
    	}
        y = 0;
        return new LdStop_Iterator();
    }

    override HEAP __props__(){ return props; }

    override string __str__() { return "array (iterator)"; }
}

class __next__: LdOBJECT {
    _ArrayIterator x;
    this(_ArrayIterator x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args){
        return x(args);
    }

    override string __str__() { return "length ([] object method)"; }
}

