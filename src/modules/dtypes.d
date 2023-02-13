module lDtypes;


import std.conv: to;
import std.format: format;

import LdObject;


class oDtypes: LdOBJECT
{
	LdOBJECT[string] props;

	//this(){ this.props = [ "Load": new _Load()]; }

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "dtypes (native module)"; }
}


//class _Load: LdOBJECT {
//	override LdOBJECT opCall(LdOBJECT[] args){ return new oLoadLibrary(args[0].__str__); }
	
//	override string __str__(){ return "dtypes.Load (object)"; }
//}


//import core.sys.posix.dlfcn;
//import std.string: toStringz;
//import std.algorithm.iteration: each;

//class oLoadLibrary: LdOBJECT
//{
//	string libname;
//	LdOBJECT dynamic;
//	LdOBJECT[string] props;

//	this(string libname){
//		this.libname = libname;
//		void *l = dlopen(toStringz(libname), RTLD_LAZY);
		
//		dynamic = shared_lib_main(l, libname);

//		this.props = [
//			"__path__": new LdStr(libname),
//			"unload": new _unload(l),
//			"module": new LdDict(dynamic.__str__, dynamic.__props__),
//		];
//	}

//	override LdOBJECT[string] __props__(){ return props; }

//	override string __str__(){ return format("dtypes.Load (%s)", libname); }
//}


//LdOBJECT shared_lib_main(void* l, string name){
//	if (l == null)
//		throw new Exception(format("Loading shared library '%s' failed, maybe file doesn't exist.", name));

//	auto fn = dlsym(l, "port_to_esau".ptr);
	
//	if (fn == null)
//		throw new Exception(format("shared-object '%s' missing C function 'extern(C) LdOBJECT share_with_land() { }'.\nTo return the compatible Land-object.", name));

//	auto lib = cast(LdOBJECT function())fn;
//	return lib();
//}


//class _unload: LdOBJECT {
//	void* l;
//	this(void* l) { this.l = l; }

//	override LdOBJECT opCall(LdOBJECT[] args){
//		dlclose(l);
//		return new LdNone();
//	}

//	override string __str__(){ return "Load_library.unload (dtypes method)"; }
//}

