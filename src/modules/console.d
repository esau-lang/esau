module lConsole;

import std.stdio;

import std.string: chomp;
import std.algorithm.iteration: each;
import core.stdc.stdio: printf;
import core.stdc.stdlib: exit;

import LdObject;


class oConsole: LdOBJECT
{
	LdOBJECT[string] props;

	this(LdOBJECT[string] props){
		this.props = props;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "console (native module)"; }
}


static LdOBJECT[string] __console_props__(){
	return [
			"print": new _Print(),
			"prompt": new _Prompt(),

			"super": new _Super(),

			"len": new _Len(),
			"attr": new _Attr(),

			"type": new _Type(),
			"exit": new _Exit(),

			"StopIterator": new _StopIterator(),
			"next": new _Next(),
			"iter": new _Iterator(),
		];
}


static void cprints(string i) {
	printf("%.*s ", cast(int)i.length, i.ptr);
}

class _Print: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args){
		args.each!(n => cprints(n.__str__));
		printf("\n");

		return RETURN.A;
	}

	override string __str__(){ return "console.print (method)"; }
}

class _Prompt: LdOBJECT
{
	override LdOBJECT opCall(LdOBJECT[] args){
		if (args.length)
			write(args[0].__str__);

		return new LdStr(chomp(readln()));
	}

	override string __str__(){ return "console.prompt (method)"; }
}


class _Super: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return args[0].__super__(args[1]);
	}

	override string __str__(){ return "console.super (method)"; }
}

class _Len: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return new LdNum(args[0].__length__);
	}

	override string __str__(){ return "console.len (method)"; } 
}

class _Type: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return new LdStr(args[0].__type__);
	}

	override string __str__(){ return "console.type (method)"; } 
}


class _Attr: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		LdOBJECT[] arr;
		args[0].__props__.keys().each!(i => arr ~= new LdStr(i));

		return new LdArr(arr);
	}

	override string __str__(){ return "console.attr (method)"; } 
}

class _Exit: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		exit(0);
		return RETURN.A;
	}

	override string __str__(){ return "console.exit (method)"; } 
}


LdOBJECT makeIterator(LdOBJECT i) {
	if ("__next__" in i.__props__)
		return i;

	if(!("__iter__" in i.__props__))
		throw new Exception("requires data that can be iterable.");

	return i.__props__["__iter__"]([]);
}


class _Iterator: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return makeIterator(args[0]);
	}

	override string __str__(){ return "console.iter (method)"; } 
}

class _Next: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return args[0].__props__["__next__"]([]);
	}

	override string __str__(){ return "console.next (method)"; } 
}

class _StopIterator: LdOBJECT 
{
	override LdOBJECT opCall(LdOBJECT[] args){
		return new LdStop_Iterator();
	}

	override string __str__(){ return "console.StopIterator (method)"; } 
}

