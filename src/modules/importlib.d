module importlib;

import std.format: format;
import std.stdio: writeln;
import std.algorithm.searching: endsWith, startsWith, find;
import std.file: exists, isFile, isDir, readText, dirEntries, SpanMode;

import std.path: buildPath, absolutePath, stripExtension, baseName;

import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;

import LdObject;


import lSys: oSys;
import lTime: oTime;
import lBase64: oBase64;

import lMath: oMath;
import lSocket: oSocket;
import lFile: oFile;

import lPath: oPath;
import lConsole;

import lDtypes: oDtypes;
import lRandom: oRandom;

import LdString: oStr;


alias LdOBJECT[string] HEAP;
HEAP _nativeModules, _loadHeap, _runtimeModules;

const string[] _natModules = ["math", "base64", "console", "file", "dtypes", "path", "random", "socket", "str", "time"];


LdOBJECT _get_native_module(string X){
	switch (X) {
		case "base64":
			return new oBase64();
		case "dtypes":
			return new oDtypes();
		case "file":
			return new oFile();
		case "path":
			return new oPath();
		case "random":
			return new oRandom();
		case "socket":
			return new oSocket();
		case "str":
			return new oStr();
		case "time":
			return new oTime();
		default:
			return new oMath();
	}
}


void __setImp__(string[] args)
{

	_runtimeModules = [ "": new LdStr("") ];

	// enter in runtimeModule to modules_path
	oSys sys = new oSys(args, new LdHsh(_runtimeModules));

	auto _console_functions = __console_props__;
	oConsole _Console = new oConsole(_console_functions);

	_nativeModules = [ "sys": sys, "console": _Console ];

	// setting modules to _nativeModules
	sys.__setProp__("modules", new LdHsh(_nativeModules));

	_loadHeap = [
				
				"attr": _console_functions["attr"],
				
				"print": _console_functions["print"],
				"prompt": _console_functions["prompt"],
				
				"exit": _console_functions["exit"],
				"super": _console_functions["super"],

				"len": _console_functions["len"],
				"next": _console_functions["next"],

				"iter": _console_functions["iter"],				
				"StopIterator": _console_functions["StopIterator"],

				"#rtd": new LdTrue(),
				"#rt": new LdNone(),
				"#bk": new LdTrue(),
		];
}


class LdModule: LdOBJECT
{
	string name, _path;
	LdOBJECT[string] props;
	
	this(string name, string _path, LdOBJECT[string] props) {
		this.name = baseName(name);
		this.props = props;
		this._path = _path;
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return format("%s (module at '%s')", name, _path); }
}


string module_exists(string ph)
{
	string md;

	foreach(i; _nativeModules["sys"].__getProp__("path").__array__)
	{
		md = buildPath(i.__str__, ph);

		if(exists(md) && isFile(md))
			return absolutePath(md);
	}

	return "";
}


void fetch(string x, string y, string[] z, HEAP hash)
{
	LdOBJECT unit;

	if (x in _nativeModules)
		unit = _nativeModules[x];

	else if (_natModules.find(x).length){
		unit = _get_native_module(x);
		_nativeModules[x] = unit;
		_runtimeModules[x] = new LdStr(x);
	
	} else {

		unit = new LdModule(baseName(x, ".esau"), x, new _Interpreter(new _GenInter(new _Parse(new _Lex(readText(x)).TOKENS, x).ast).bytez, _loadHeap.dup).heap);

		// caching
		_nativeModules[x] = unit;
		_runtimeModules[stripExtension(baseName(x))] = new LdStr(x);
	}

	foreach(i; z)
	{
		if (i in unit.__hash__)
			unit = unit.__getProp__(i);
		else if (i == "*")
		{
			foreach(k, v; unit.__hash__)
			{
				if(endsWith(k, "__") && startsWith(k, "__")  || startsWith(k, "||")){ }
				else
					hash[k] = v;
			}
			return;

		} else
			throw new Exception(format("ImportError: attribute %s is not found in module %s.", i, unit.__str__));
	}

	hash[y] = unit;
}


string single_import(string[] im, string name, HEAP mem)
{
	string _ph, md;

	for(size_t i = 0; i < im.length; i++)
	{
		_ph = buildPath(_ph, im[i]);

		if(!(_ph in _nativeModules || _natModules.find(_ph).length))
			md = module_exists(format("%s.esau", _ph));
		else
			md = _ph;

		if(md.length)
		{
			fetch(md, name, im[i+1..im.length], mem);
			return "";
		}
	}

	throw new Exception(format("ImportError: Module %s is not found in sys.path.", _ph));
}


void import_module(string[] fm, string[][string] im, HEAP mem)
{
	foreach(k, v; im)
		single_import(fm~v, k, mem);
}

