module lSys;

import std.file: getcwd, thisExePath;
import std.path: buildPath, dirName;
import std.stdio;

import LdObject;


alias LdOBJECT[string] LS;


class oSys: LdOBJECT
{
	LS props;

	this(string[] argv, LdOBJECT Modules){
		this.props = [
			"argv": set_argv(argv),
			"path": set_path(),

			//"object_instances": new GetInstances(),

			"modules_path": Modules,
			"executable": new LdStr(thisExePath),

			"__docs__": new LdStr("This modules has variables being used by the Esau runtime, so you can config them to new values.\n\nBut if set to unfamiliar values, this will result to errors.")
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "sys (native module)"; }
}


//class GetInstances: LdOBJECT
//{
//	override LdOBJECT opCall(LdOBJECT[] args) {
//		return new LdNum(LdOBJECT.objects);
//	}
//}


LdOBJECT set_argv(string[] arg)
{
	LdOBJECT[] arr;

	foreach(i; arg)
		arr ~= new LdStr(i);

	return new LdArr(arr);
}

LdOBJECT set_path()
{
	return new LdArr([new LdStr(""), new LdStr(getcwd()), new LdStr(buildPath(getcwd(), "esau_modules")), new LdStr(buildPath(dirName(thisExePath), "esau_modules"))]);
}

