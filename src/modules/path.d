module lPath;

import std.format: format;
import std.algorithm.searching: find;
import std.algorithm.iteration: each, map;

import std.array: array;

import std.file;
import std.path;

import LdObject;

alias LdOBJECT[string] Heap;


class oPath: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"pwd": new _Pwd(),
            "exists": new _Exists(),

            "readdir": new _Readdir(),

			"isfile": new _IsFile(),
			"isdir": new _IsDir(),
			
			"tmp": new _Tmp(),
			"join": new _Join(),

			"copy": new _Copy(),
			"move": new _Move(),

            "chdir": new _Chdir(),
			"mkdir": new _MakeDir(),

			"rmdir": new _RmDir(),
			"remove": new _Remove(),

			"abspath": new _Abspath(),
			"relpath": new _Relpath(),

			"dirname": new _Dirname(),
			"basename": new _Basename(),
			
			"pathsep": new LdStr(pathSeparator),
			"sep": new LdStr(dirSeparator),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "path (native module)"; }
}


class _Readdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        string htap;

        if (args.length)
            htap = args[0].__str__;
        else
            htap = getcwd();

        LdOBJECT[] list = cast(LdOBJECT[])dirEntries(htap, SpanMode.shallow, false).map!(i => new LdStr(i)).array;

        return new LdArr(list);
    }

    override string __str__() { return "path.readdir (method)"; }
}

class _Chdir: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        chdir(args[0].__str__);
        return RETURN.A;
    }

    override string __str__() { return "path.chdir (method)"; }
}

class _Basename: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(baseName(args[0].__str__));
    }

    override string __str__() { return "path.basename (method)"; }
}

class _Dirname: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(dirName(args[0].__str__));
    }

    override string __str__() { return "path.dirname (method)"; }
}

class _Abspath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(absolutePath(args[0].__str__));
    }

    override string __str__() { return "path.abspath (method)"; }
}

class _Relpath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(relativePath(args[0].__str__));
    }

    override string __str__() { return "path.relpath (method)"; }
}

class _Remove: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	remove(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "path.remove (method)"; }
}

class _RmDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	rmdirRecurse(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "path.rmdir (method)"; }
}

class _MakeDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	mkdirRecurse(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "path.mkdir (method)"; }
}

class _Move: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	rename(args[0].__str__, args[1].__str__);
    	return new LdNone();
    }

    override string __str__() { return "path.move (method)"; }
}

class _Copy: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	copy(args[0].__str__, args[1].__str__);
    	return new LdNone();
    }

    override string __str__() { return "path.copy (method)"; }
}

class _Tmp: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	return new LdStr(tempDir());
    }

    override string __str__() { return "path.tmp (method)"; }
}

class _Pwd: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	return new LdStr(getcwd());
    }

    override string __str__() { return "path.pwd (method)"; }
}

class _IsFile: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (isFile(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.isfile (method)"; }
}

class _IsDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (isDir(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.isdir (method)"; }
}

class _Exists: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (exists(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "path.exists (method)"; }
}

class _Join: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	string x;
    	args.each!(i => x = buildPath(x, i.__str__));

    	return new LdStr(x);
    }

    override string __str__() { return "path.join (method)"; }
}
