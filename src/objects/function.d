module LdFunction;

import std.stdio;
import std.format: format;
import std.array: join;

import LdObject, LdBytes2, LdBytes, LdExec;


alias LdOBJECT[string] store;



class LdFn: LdOBJECT {
	size_t def_length;
	store heap;                    string name;
	LdByte[] code;                 string[] params;
	LdOBJECT ret;                  LdOBJECT[] defaults;
	LdOBJECT[string] props,        point;
	
	this(string name, string[] params, LdOBJECT[] defaults, LdByte[] code, store heap){
		this.name = name;
		this.code = code;
		this.heap = heap;
		this.params = params;
		this.defaults = defaults;
		this.def_length = defaults.length;

		this.props = [
			"self": RETURN.A,
			"__object__": RETURN.A,
			"__repr__": new LdStr(format("%s (custom method)", name)),
			"__name__": new LdStr(name),
		];
	}

	override LdOBJECT opCall(LdOBJECT[] args){
		point = heap.dup;
		point["self"] = props["self"];

		if(args.length < params.length){
			size_t def = def_length - (params.length-args.length);

			if(!(def_length && def < def_length)) {
				throw new Exception(format("ERROR: MethodError: method '%s' needs more args.\nRequires %d yet given %d and %d default :: [%s].", (props["__object__"].__str__ ~ name), params.length, args.length, def_length, join(params, ", ")));
			}

			args = args ~ defaults[def .. def_length];
		}

		for(size_t i = 0; i < params.length; i++)
			point[params[i]] = args[i];

		return new _Interpreter(code, point).heap["#rt"];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return props["__repr__"].__str__; }
}
