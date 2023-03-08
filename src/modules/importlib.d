module importlib;

import std.format: format;
import std.stdio: writeln;

import std.algorithm.searching: endsWith, startsWith, find;
import std.algorithm.iteration: map;
import std.algorithm.mutation: remove;

import std.array: array, split, replace;

import std.file: exists, isFile, isDir, readText, dirEntries, SpanMode;

import std.path: buildPath, absolutePath, stripExtension, baseName, dirSeparator;
import LdParser, LdLexer, LdNode, LdBytes, LdIntermediate, LdExec;

import LdObject;


import lSys: oSys;
import lTime: oTime;
import lBase64: oBase64;

import lMath: oMath;
import lSocket: oSocket;
import lFile: oFile;

import lJson: oJson;
import lFlare: oFlare;

import lPath: oPath;
import lConsole;

import lDtypes: oDtypes;
import lRandom: oRandom;

import lList: oList;
import lDict: oDict;

import LdString: oStr;
import LdChar: oByte;


alias LdOBJECT[string] HEAP;
HEAP imported_modules, _runtimeModules;

LdModule[][string] Circular;

LdOBJECT[string] _StartHeap;


const string[] _Core = ["base64", "byte", "console", "dict", "dtypes", "file", "flare", "json", "list", "math", "path", "random", "socket", "str", "sys", "time"];


LdOBJECT import_core_library(string X){
	switch (X) {
		case "base64":
			return new oBase64();
		case "dtypes":
			return new oDtypes();
		case "file":
			return new oFile();
		case "flare":
			return new oFlare();
		case "json":
			return new oJson();
		case "path":
			return new oPath();
		case "random":
			return new oRandom();
		case "socket":
			return new oSocket();
		case "str":
			return new oStr();
		case "list":
			return new oList();
		case "dict":
			return new oDict();
		case "byte":
			return new oByte();
		case "time":
			return new oTime();
		default:
			return new oMath();
	}
}


LdOBJECT[string] __setImp__(string[] args) {

	_StartHeap = [
		"#rtd": new LdTrue(),
		"#rt": new LdNone(),
		"#bk": new LdTrue(),
	];

	_runtimeModules = [ "": new LdStr("") ];

	// enter in runtimeModule to modules_path
	oSys sys = new oSys(args, new LdHsh(_runtimeModules));

	auto _console_functions = __console_props__;
	oConsole _Console = new oConsole(_console_functions);

	imported_modules = [ "sys": sys, "console": _Console ];

	// setting modules to imported_modules
	sys.__setProp__("modules", new LdHsh(imported_modules));

	return [
		"attr": _console_functions["attr"],
		"type": _console_functions["type"],
		
		"print": _console_functions["print"],
		"prompt": _console_functions["prompt"],
		
		"exit": _console_functions["exit"],
		"super": _console_functions["super"],

		"len": _console_functions["len"],
		"next": _console_functions["next"],

		"iter": _console_functions["iter"],				
		"StopIterator": _console_functions["StopIterator"],
	];
}


class LdModule: LdOBJECT {
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


string inPath(string ph) {
	string md;

	foreach(i; imported_modules["sys"].__getProp__("path").__array__)
	{
		foreach(ext; ["", ".eu"]) {
			md = buildPath(i.__str__, format("%s%s", ph, ext));

			if(exists(md))
				return absolutePath(md);
		}
	}
	return "";
}

// JUST THE IMPORT STATEMENT
void import_module(string[string] m, string[] save, HEAP *brain) {
	string work;
	string[] done;

	LdOBJECT mod = null;

	foreach(i; save) {
		
		if(find(_Core, m[i]).length) {
			(*brain)[i] = get_core_library(m[i]);
			continue; 
		}

		work = inPath(m[i]);
		
		if(!work.length)
			throw new Exception(format("ImportError: module '%s' not found is sys.path.", m[i]));

		if(isFile(work))
			mod = read_file_module([i, work]);
		else if (isDir(work))
			mod = read_dir_module([i, work]);
		else
			throw new Exception(format("ImportError: module '%s' path '%s' should be a dir or a file."));
		
		done = i.split(dirSeparator);
		(*brain)[done[done.length - 1]] = mod;
	}
}


// GET CORE LIBRARY
LdOBJECT get_core_library(string htap) {
	if (htap in imported_modules)
		return imported_modules[htap];
	
	LdOBJECT mod = import_core_library(htap);
	// caching
	imported_modules[htap] = mod;
	
	return mod;
}


// FROM AND IMPORT STATEMENT
void core_library(string htap, string[string]*attrs, string[] *order, HEAP*brain){
	LdOBJECT mod = get_core_library(htap);
	auto fns = mod.__props__;

	foreach(i; *order) {
		if (i == "*") {
			foreach(k2, v2; fns) {
				if(!(endsWith(k2, "__") && startsWith(k2, "__")))
					(*brain)[k2] = v2;
			}
		
		} else if(i in fns)
			(*brain)[(*attrs)[i]] = fns[i];

		else
			throw new Exception(format("ImportError: attr '%s' is not found in builtin module '%s'.", i, mod.__str__));
	}		
}


void cache(string htap, LdOBJECT mod) {
	imported_modules[htap] = mod;

	if(htap in Circular) {
		foreach(ref i; Circular[htap])
			i.props = mod.__props__;

		Circular.remove(htap);
	}
}

bool circular(string f) {
	if(f in Circular)
		return false;

	Circular[f] = [];
	return true;
}

void load_all_module_dir(LdOBJECT mod, string[2] htap, HEAP*brain) {
	if (!("__export__" in mod.__props__))
		return;
	
	string p;

	foreach(i; (*(mod.__props__["__export__"].__ptr__)).map!(n => n.__str__)) {
		p = buildPath(htap[1], i);

		if(!exists(p)){
			p = format("%s.eu", p);
		
			if(!exists(p))
				throw new Exception(format("ImportError: Module not found\n path '%s' is not found in package %s.", i, htap[0]));
		}

		if(isFile(p))
			(*brain)[i] = read_file_module([i, p]);
		
		else if(isDir(p))
			(*brain)[i] = read_dir_module([i, p]);
	}
}

void directory_library(string[2] htap, string[string]*attrs, string[]*order, HEAP*brain){
	LdOBJECT mod = read_dir_module(htap);
	string f;

	foreach(i; *order) {
		if(i == "*") {
			load_all_module_dir(mod, htap, brain);
			continue;
		}

		f = buildPath(htap[1], i);

		if (!exists(f)) {
			f = format("%s.eu", f);

			if(!exists(f))
				throw new Exception(format("ImportError: file attr '%s' is not found in dir module '%s'", i, htap[0]));
		}

		if(isFile(f))
			(*brain)[(*attrs)[i]] = read_file_module([i, f]);
		
		else if(isDir(f))
			(*brain)[(*attrs)[i]] = read_dir_module([i, f]);
	}
}

void file_library(string[2] htap, string[string]*attrs, string[]*order, HEAP*brain){
	LdOBJECT mod = read_file_module(htap);
	auto fns = mod.__props__;

	foreach(i; *order) {
		if (i == "*") {
			foreach(k2, v2; fns) {
				if(!(endsWith(k2, "__") && startsWith(k2, "__")  || startsWith(k2, "#")))
					(*brain)[k2] = v2;
			}
		
		} else if(i in fns)
			(*brain)[(*attrs)[i]] = fns[i];
	
		else
			throw new Exception(format("ImportError: attr '%s' is not found in file module '%s'.", i, mod.__str__));
	}
}

LdOBJECT read_dir_module(string[] htap){
	LdModule mod;

	string[] list= dirEntries(htap[1], "*.eu", SpanMode.shallow, false).map!(i=>cast(string)i).array;
	string pack = buildPath(htap[1], "__pack__.eu");

	if (find(list, pack).length) {
		if (pack in imported_modules)
			return imported_modules[pack];

		if(circular(pack)) {
			mod = new LdModule(htap[0], pack, new _Interpreter(new _GenInter(new _Parse(new _Lex(readText(pack)).TOKENS, pack).ast).bytez, _StartHeap.dup).heap);

			cache(pack, mod);
			return mod;
		}

		mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__module__":RETURN.A]);
		Circular[pack] ~= mod;

		return mod;
	}

	if (htap[1] in imported_modules)
		return imported_modules[htap[1]];

	mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__name__": new LdStr(htap[0])]);
	cache(htap[1], mod);

	return mod;
}

LdOBJECT read_file_module(string[2] htap){
	LdModule mod;

	if(htap[1] in imported_modules)
		return imported_modules[htap[1]];
	
	if(circular(htap[1])) {
		mod = new LdModule(htap[0], htap[1], new _Interpreter(new _GenInter(new _Parse(new _Lex(readText(htap[1])).TOKENS, htap[1]).ast).bytez, _StartHeap.dup).heap);

		cache(htap[1], mod);
		return mod;
	}

	mod = new LdModule(htap[0], htap[1], ["__path__": new LdStr(htap[1]), "__module__":RETURN.A]);
	Circular[htap[1]] ~= mod;

	return mod;
}

void import_library(string fpath, string[string]*attrs, string[]*order, HEAP*heap) {
	
	if(find(_Core, fpath).length)
		return core_library(fpath, attrs, order, heap);

	string htap = inPath(fpath);

	if(!htap.length)
		throw new Exception(format("ImportError: path '%s' is not found in 'sys.path'.", fpath));

	if(isFile(htap))
		return file_library([fpath, htap], attrs, order, heap);

	if(isDir(htap))
		return directory_library([fpath, htap], attrs, order, heap);
}

