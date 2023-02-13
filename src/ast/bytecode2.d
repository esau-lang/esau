module LdBytes2;


import std.conv;
import std.stdio;

import LdBytes;
import LdObject, LdNumber, LdString, LdArray;
import LdHash, LdType;


alias LdOBJECT[string] HEAP;



// NUMBERS 1  1.5 100_000

class Op_Num: LdByte {
	LdOBJECT _num;

	this(double number){
		this._num = new LdNum(number);
	}

	override LdOBJECT opCall(HEAP _heap) {
		return this._num;
	}
	override int type(){ return 1; }
}

class Op_Nadd: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdNum(left(_heap).__num__ + right(_heap).__num__);
	}
	override int type(){ return 1; }
}

class Op_Nminus: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdNum(left(_heap).__num__ - right(_heap).__num__);
	}
	override int type(){ return 1; }
}

class Op_Ntimes: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdNum(left(_heap).__num__ * right(_heap).__num__);
	}
	override int type(){ return 1; }
}

class Op_Ndivide: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdNum(left(_heap).__num__ / right(_heap).__num__);
	}
	override int type(){ return 1; }
}

class Op_Nremainder: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdNum(left(_heap).__num__ % right(_heap).__num__);
	}
	override int type(){ return 1; }
}

class Op_Nequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__str__ == right(_heap).__str__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_Nless: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__num__ < right(_heap).__num__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_Ngreat: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__num__ > right(_heap).__num__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_Nlequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__num__ <= right(_heap).__num__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_Ngequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__num__ >= right(_heap).__num__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_NNOTequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__str__ != right(_heap).__str__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}



// STRINGS 'hello', "world"

class Op_Str: LdByte {
	LdOBJECT _str;

	this(string st){
		this._str = new LdStr(st);
	}

	override LdOBJECT opCall(HEAP _heap) {
		return this._str;
	}
	override int type(){ return 2; }
}


class Op_Sadd: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdStr(left(_heap).__str__ ~ right(_heap).__str__);
	}
	override int type(){ return 2; }
}


import std.array: replicate;

class Op_Stimes: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdStr(replicate(left(_heap).__str__, cast(int)right(_heap).__num__));
	}

	override int type(){ return 2; }
}

class Op_Sequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__str__ == right(_heap).__str__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_SNOTequals: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if (left(_heap).__str__ != right(_heap).__str__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}




// ARRAYS [., ., .]

class Op_Array: LdByte {
	LdByte[] items;

	this(LdByte[] items){
		this.items = items;
	}

	override LdOBJECT opCall(HEAP _heap) {
		LdOBJECT[] arr;

		foreach(LdByte i; items)
			arr ~= i(_heap);

		return new LdArr(arr);
	}
	override int type(){ return 3; }
}


class Op_Aadd: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return new LdArr(left(_heap).__array__ ~ right(_heap).__array__);
	}

	override int type(){ return 3; }
}



// HASH  {.:.}

class Op_Hash: LdByte {
	string[] keys;
	LdByte[] values;

	this(string[] keys, LdByte[] values){
		this.keys = keys;
		this.values = values;
	}

	override LdOBJECT opCall(HEAP _heap) {
		LdOBJECT[string] hash;

		for(int i = 0; i < keys.length; i++)
			hash[keys[i]] = values[i](_heap);

		return new LdHsh(hash);
	}

	override int type(){ return 3; }
}



// INDEXING [1,'a'][1]  x[2] = 1

class Op_Pindex: LdByte {
	LdByte value, index;

	this(LdByte value, LdByte index){
		this.value = value;
		this.index = index;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return value(_heap).__index__(index(_heap));
	}
}


class Op_PiAssign: LdByte {
	LdByte key, index, value;

	this(LdByte key, LdByte index, LdByte value){
		this.key = key;
		this.index = index;
		this.value = value;
	}

	override LdOBJECT opCall(HEAP _heap) {
		key(_heap).__assign__(index(_heap), value(_heap));
		return new LdOBJECT();
	}
}


class Op_Pobj: LdByte {
	string name;
	string[] attrs;
	LdByte[] contrib, code;

	this(string name, LdByte[] contrib, string[] attrs, LdByte[] code){
		this.name = name;
		this.code = code;
		this.attrs = attrs;
		this.contrib = contrib;
	}

	override LdOBJECT opCall(HEAP _heap){
		LdOBJECT[] h;

		foreach(LdByte i; contrib)
			h ~= i(_heap);

		new LdTyp(name, h, attrs, code, _heap);
		return new LdOBJECT();
	}
}


// GETTING ATTRIBUTE x.y x.y = 3

class Op_Pdot: LdByte {
	LdByte obj;
	string prop;

	this(LdByte obj, string prop){
		this.obj = obj;
		this.prop = prop;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return obj(_heap).__getProp__(prop);
	}
}


class Op_PdotAssign: LdByte {
	LdByte obj, value;
	string prop;

	this(LdByte obj, string prop, LdByte value){
		this.obj = obj;
		this.prop = prop;
		this.value = value;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return obj(_heap).__setProp__(prop, value(_heap));
	}
}




// BOOLEANS  true false and none

class Op_True: LdByte {
	override LdOBJECT opCall(HEAP _heap) {
		return new LdTrue();
	}
	override int type(){ return 1; }
}

class Op_False: LdByte {
	override LdOBJECT opCall(HEAP _heap) {
		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_None: LdByte {
	override LdOBJECT opCall(HEAP _heap) {
		return new LdNone();
	}
	override int type(){ return 1; }
}



// NOT OR and AND

class Op_Not: LdByte {
	LdByte value;

	this(LdByte value){
		this.value = value;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if(!value(_heap).__true__)
			return new LdTrue();

		return new LdFalse();
	}
	override int type(){ return 1; }
}

class Op_Or: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if(left(_heap).__true__ || right(_heap).__true__)
			return new LdTrue();

		return new LdFalse();
	}
}

class Op_And: LdByte {
	LdByte left, right;

	this(LdByte left, LdByte right){
		this.left = left;
		this.right = right;
	}

	override LdOBJECT opCall(HEAP _heap) {
		if(left(_heap).__true__ && right(_heap).__true__)
			return new LdTrue();

		return new LdFalse();
	}
}

