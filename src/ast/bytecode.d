module LdBytes;

import std.stdio;
import std.algorithm.iteration: each;

import LdObject;

import LdFunction;
import LdExec;


alias LdOBJECT[string] HEAP;


class LdByte {
	LdByte[string] hash;

	LdOBJECT opCall(HEAP _heap){ return new LdOBJECT(); }

	LdByte[] opCode(){ return []; }

	int type(){ return 0; }
}


class Op_Var: LdByte {
	LdByte value;
	string key;

	this(string key, LdByte value){
		this.value = value;
		this.key = key;
	}

	override LdOBJECT opCall(HEAP _heap) {
		_heap[this.key] = this.value(_heap);
		return new LdOBJECT();
	}
}


class Op_Id: LdByte {
	string key;

	this(string key){
		this.key = key;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return _heap.get(key, new LdOBJECT());
	}
}

class Op_Format: LdByte {
	LdByte[] arr;

	this(LdByte[] arr){
		this.arr = arr;
	}

	override LdOBJECT opCall(HEAP _heap) {
		string st;
		arr.each!(i => st ~= i(_heap).__str__);

		return new LdStr(st);
	}
}


class Op_FnDef: LdByte {
	string name;
	LdByte[] code;
	string[] params;
	LdByte[] defaults;

	this(string name, string[] params, LdByte[] defaults, LdByte[] code){
		this.code = code;
		this.name = name;
		this.params = params;
		this.defaults = defaults;
	}

	override LdOBJECT opCall(HEAP _heap){
		LdOBJECT[] defs;

		foreach(LdByte i; defaults)
			defs ~= i(_heap);

		_heap[name] = new LdFn(name, params, defs, code, _heap);
		return new LdOBJECT();
	}
}


class Op_Return: LdByte {
	LdByte value;

	this(LdByte value){
		this.value = value;
	}

	override LdOBJECT opCall(HEAP _heap) {
		LdOBJECT feedback = value(_heap);
		_heap["#rt"] = feedback;
		_heap["#rtd"] = new LdFalse();
		_heap["#bk"] = new LdFalse();
		return feedback;
	}
}


class Op_FnCall: LdByte {
	LdByte def;
	LdByte[] args;

	this(LdByte def, LdByte[] args){
		this.def = def;
		this.args = args;
	}

	override LdOBJECT opCall(HEAP _heap){
		LdOBJECT[] params;

		foreach(LdByte i; this.args)
			params ~= i(_heap);

		return this.def(_heap)(params);
	}
}


class Op_If: LdByte {
	LdByte exe;
	LdByte[] code;

	this(LdByte exe, LdByte[] code){
		this.exe = exe;
		this.code = code;
	}

	override LdOBJECT opCall(HEAP _heap) {
		return exe(_heap);
	}

	override LdByte[] opCode(){
		return this.code;
	}
}


class Op_IfCase: LdByte {
	LdByte[] ifs;

	this(LdByte[] ifs){
		this.ifs = ifs;
	}

	override LdOBJECT opCall(HEAP _heap) {
		foreach(LdByte fi; ifs){
			if(fi(_heap).__true__){
				new _Interpreter(fi.opCode, _heap);
				break;
			}
		}
		return new LdOBJECT();
	}
}


class Op_While: LdByte {
	LdByte base;
	LdByte[] code;

	this(LdByte base, LdByte[] code){
		this.base = base;
		this.code = code;
	}

	override LdOBJECT opCall(HEAP _heap) {
		while(_heap["#bk"].__true__ && base(_heap).__true__)
			new _Interpreter(code, _heap);

		if(_heap["#rtd"].__true__)
			_heap["#bk"] = new LdTrue();

		return new LdNone();
	}
}

import lConsole: makeIterator;


class Op_For: LdByte {
	string var;
	LdByte value;
	LdByte[] code;

	this(string var, LdByte value, LdByte[] code){
		this.var = var;
		this.value = value;
		this.code = code;
	}

	override LdOBJECT opCall(HEAP _heap) {
		LdOBJECT iter = makeIterator(value(_heap));
		LdOBJECT i = iter.__props__["__next__"]([]);

		if(_heap["#bk"].__true__) {
			while(i.__stop_iteration__){
				_heap[var] = i;
				new _Interpreter(code, _heap);

				if(_heap["#bk"].__true__)		
					i = iter.__props__["__next__"]([]);
				else
					break;
			}
		}

		_heap["#bk"] = new LdTrue();
		return new LdOBJECT();
	}
}


class Op_Break: LdByte {
	override LdOBJECT opCall(HEAP _heap){
		_heap["#bk"] = new LdFalse();
		return new LdNone();
	}
}


class Op_Continue: LdByte {
	override LdOBJECT opCall(HEAP _heap){
		return new LdNone();
	}
}


import std.file: readText, exists, isFile;
import LdParser, LdLexer, LdIntermediate;

static void addFls(LdOBJECT[] fls, HEAP _heap) {
	LdByte[] bcode;
	
	foreach(i; fls) {
		if(exists(i.__str__) && isFile(i.__str__)) {
			bcode = new _GenInter(new _Parse(new _Lex(readText(i.__str__)).TOKENS, i.__str__).ast).bytez;
			new _Interpreter(bcode, _heap);
		}
	}
}

class Op_Include: LdByte {
	LdByte modules;

	this(LdByte modules){
		this.modules = modules;
	}

	override LdOBJECT opCall(HEAP _heap){
		addFls(modules(_heap).__array__, _heap);
		return new LdNone();
	}
}


import importlib: import_module;


class Op_Import: LdByte {
	string[][string] fm;
	string[] im;

	this(string[] im, string[][string] fm){
		this.im = im;
		this.fm = fm;
	}

	override LdOBJECT opCall(HEAP _heap){
		import_module(im, fm, _heap);
		return new LdNone();
	}
}

