module lPath;

import std.format: format;
import std.algorithm.searching: find;
import std.algorithm.iteration: each;

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

	override string __str__(){ return "path (Paths handling unit)"; }
}


class _Readdir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        string htap = getcwd();

        if (args.length)
            htap = args[0].__str__;

        LdOBJECT[] list;
        dirEntries(htap, SpanMode.shallow, false).each!(i => list ~= new LdStr(i));

        return new LdArr(list);
    }

    override string __str__() { return "readdir (path method)"; }
}

class _Basename: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(baseName(args[0].__str__));
    }

    override string __str__() { return "basename (path method)"; }
}

class _Dirname: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(dirName(args[0].__str__));
    }

    override string __str__() { return "dirname (path method)"; }
}

class _Abspath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(absolutePath(args[0].__str__));
    }

    override string __str__() { return "abspath (path method)"; }
}

class _Relpath: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new LdStr(relativePath(args[0].__str__));
    }

    override string __str__() { return "relpath (path method)"; }
}

class _Remove: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	remove(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "remove (path method)"; }
}

class _RmDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	rmdirRecurse(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "rmdir (path method)"; }
}

class _MakeDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	mkdirRecurse(args[0].__str__);
    	return new LdNone();
    }

    override string __str__() { return "mkdir (path method)"; }
}

class _Move: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	rename(args[0].__str__, args[1].__str__);
    	return new LdNone();
    }

    override string __str__() { return "move (path method)"; }
}

class _Copy: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	copy(args[0].__str__, args[1].__str__);
    	return new LdNone();
    }

    override string __str__() { return "copy (path method)"; }
}

class _Tmp: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	return new LdStr(tempDir());
    }

    override string __str__() { return "tmp (path method)"; }
}

class _Pwd: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	return new LdStr(getcwd());
    }

    override string __str__() { return "pwd (path method)"; }
}

class _IsFile: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (isFile(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "isfile (path method)"; }
}

class _IsDir: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (isDir(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "isdir (path method)"; }
}

class _Exists: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	if (exists(args[0].__str__))
    		return new LdTrue();

    	return new LdFalse();
    }

    override string __str__() { return "exists (path method)"; }
}

class _Join: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	string x;
    	args.each!(i => x = buildPath(x, i.__str__));

    	return new LdStr(x);
    }

    override string __str__() { return "join (path method)"; }
}
