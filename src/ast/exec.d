module LdExec;


import std.stdio;
import std.algorithm.iteration: each;

import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate;
import LdObject, LdString;


alias LdOBJECT[string] Memory; 


class _Interpreter {
	LdByte[] code;
	Memory heap;

	this(LdByte[] code, Memory heap){
		this.code = code;
		this.heap = heap;

		this._initialize();
	}

	void _initialize(){
		int i = 0;
		size_t len = code.length;

		while(i < len && heap["#bk"].__true__){
			code[i](heap);
			i++;
		}
	}
}

