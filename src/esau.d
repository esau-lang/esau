import std.stdio;

import std.file: readText, exists, isFile, thisExePath;

import std.algorithm.searching: canFind, endsWith;
import std.algorithm.mutation: remove;

import std.string: strip;
import std.array: replicate;

import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;
import LdObject, LdString;

import importlib: __setImp__, _StartHeap;


string _Console_Input(){
	string code, a;

	write(">> ");
	a = strip(readln());

	if(a.endsWith("{")) {
		short yet = 1;
		while (yet){
			code ~= a~'\n';

			write("...", replicate("    ", yet));
			a = strip(readln());

			if(a.endsWith("{"))
				yet++;

			else if (a.endsWith("}")) {
				yet--;

				if(!yet)
					code ~= a;
			}
		}
		return code;
	}
	return a;
}


int _console(){
	string code;
	auto _Heap = _StartHeap.dup;

	TOKEN[] tokens;
	LdByte[] bcode;

	writef(" Esau Interpreter 0.1 (official Mar 08 2023)\n check https://esau-lang.github.io\n\n");

	while (true)
	{
		try{
			code = _Console_Input();
			
			if(code.length) {
				tokens = new _Lex(code).TOKENS;
				bcode = new _GenInter(new _Parse(tokens, "__stdin__").ast).bytez;

				_Heap = new _Interpreter(bcode, _Heap).heap;
			}
		} 
		catch (Exception e)
			writeln("Error: ", e.msg);
	}

	return 0;
}

int _start(string[] args){
	if (exists(args[0]) && isFile(args[0]))
	{
		string code = readText(args[0]);
		TOKEN[] tokens = new _Lex(code).TOKENS; Node[] tree = new _Parse(tokens, args[0]).ast;

		LdByte[] bcode = new _GenInter(tree).bytez;

		new _Interpreter(bcode, _StartHeap.dup);
		
	} else if(canFind(args, "-v"))
		writeln("esau 0.0.1");

	else if(canFind(args, "-e"))
		writeln(thisExePath);

	else if(canFind(args, "-h"))
	{
		writeln("Genesis - The esau Interpreter [0.0.1]
...
-e     : shows the landof interpreter executable path
-h     : returns this help message
-v     : prints the esau version installed on your pc");
	}
	else
		writef("esau: Error '%s': [Errno 2] No such file\n", args[0]);

	return 0;
}


int main(string[] args)
{
	args = args.remove(0);
	
	LdBytes._AUTO_VARS = __setImp__(args);

	if(!args.length)
		return _console();

	_start(args);

	return 0;
}
