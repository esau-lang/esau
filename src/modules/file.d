module lFile;

import std.file: readText, read, write, append, getSize;
import std.format: format;
import std.stdio: File;
import std.algorithm.searching: find;
import std.algorithm.iteration: each;

import LdObject;


alias LdOBJECT[string] Heap;


class oFile: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"read": new _Read(),
			"readbin": new _Readbin(),

			"write": new _Write(),
			"writebin": new _Writebin(),

			"append": new _Append(),
			"appendbin": new _Appendbin(),

			"size": new _Size(),
			"Open": new _Open(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "File (IO handling unit)"; }
}

class _Read: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	return new LdStr(readText(args[0].__str__));
    }

    override string __str__() { return "read (File method)"; }
}

class _Readbin: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {

		if (args.length > 1)
			return new LdChr(cast(char[])read(args[0].__str__, cast(size_t)args[1].__num__));

		return new LdChr(cast(char[])read(args[0].__str__));
    }

    override string __str__() { return "readbin (File method)"; }
}

class _Write: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(args.length > 1)
    		write(args[0].__str__, args[1].__str__);
       	
       	return new LdNone();
    }

    override string __str__() { return "write (File method)"; }
}

class _Writebin: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(args.length > 1)
       		write(args[0].__str__, args[1].__chars__);
		
		return new LdNone();
    }

    override string __str__() { return "writebin (File method)"; }
}

class _Append: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(args.length > 1)
    		append(args[0].__str__, args[1].__str__);
       	
       	return new LdNone();
    }

    override string __str__() { return "append (File method)"; }
}

class _Appendbin: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(args.length > 1)
       		append(args[0].__str__, args[1].__chars__);
		
		return new LdNone();
    }

    override string __str__() { return "appendbin (File method)"; }
}

class _Size: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
		return new LdNum(getSize(args[0].__str__));
    }

    override string __str__() { return "size (File method)"; }
}

class _Open: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args) {
		if (args.length > 1)
			return new _OpenFile(args[0].__str__, args[1].__str__);

		return new _OpenFile(args[0].__str__);
    }

    override string __str__() { return "open (File object)"; }
}


class _OpenFile: LdOBJECT
{
	File x;
	Heap props;
	string name, mode;

	this(string name, string mode="r"){
		this.name = name;
		this.mode = mode;

		this.x = File(name, mode);

		this.props = [
			"_CHUNK_SIZE": new LdNum(8192),

			"name": new LdStr(name),
			"mode": new LdStr(mode),

			"seek": new _seek(x),

			"tell": new _tell(x),
			"size": new _size(x),

			"flush": new _flush(x),
			"close": new _close(x),

			"chunks": new _chunks(this),

			"read": new _read(x, mode),
			"readline": new _readline(x, mode),

			"write": new _write(x, mode),
			"writeline": new _writeline(x, mode),

			"closed": new _Closed(x),
		];
	}

	override Heap __hash__(){ return props; }

    override LdOBJECT __getProp__(string prop){
        return props[prop];
    }

    override LdOBJECT __setProp__(string prop, LdOBJECT value){
        props[prop] = value;
        return new LdOBJECT();
    }

	override string __str__(){ return format("io-stream (name='%s' mode='%s'", name, mode); }
}

class _Closed: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
    	if (x.isOpen)
			return new LdFalse();
		
		return new LdTrue();
    }

    override string __str__() { return "closed (io-stream object method)"; }
}

class _flush: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
    	x.flush();
		return new LdNone();
    }

    override string __str__() { return "flush (io-stream object method)"; }
}

class _size: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
		return new LdNum(x.size);
    }

    override string __str__() { return "size (io-stream object method)"; }
}

class _tell: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
		return new LdNum(x.tell);
    }

    override string __str__() { return "tell (io-stream object method)"; }
}

class _close: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
    	x.close();
		return new LdNone();
    }

    override string __str__() { return "close (io-stream object method)"; }
}

class _read: LdOBJECT 
{
	File x;     char[8192] buf;    string md;

	this(File x, string md){
		this.x = x;
		this.md = md;
		this.buf=buf;
	}

    override LdOBJECT opCall(LdOBJECT[] args) {
    	char[] data = x.rawRead(buf);
    	int len = cast(int)data.length;

    	if(args.length) {
    		int inlen = cast(int)args[0].__num__;

    		if(inlen <= len)
    			len = inlen;
    	}

    	if(find(md, 'b').length)
    		return new LdChr(data[0..len]);

    	return new LdStr(cast(string)data[0..len]);
    }

    override string __str__() { return "read (io-stream object method)"; }
}

class _chunks: LdOBJECT 
{
	_OpenFile x;

	this(_OpenFile x){
		this.x = x;
	}

    override LdOBJECT opCall(LdOBJECT[] args) {
    	size_t chunk = cast(uint)x.props["_CHUNK_SIZE"].__num__;

    	if(args.length)
    		chunk = cast(uint)args[0].__num__;

    	auto buf = x.x.byChunk(chunk);
    	
    	if(find(x.mode, 'b').length){
    		char[] i;
    		buf.each!(n => i ~= cast(char[])n);
    		return new LdChr(i);
    	}

    	string i;
		buf.each!(n => i ~= cast(string)n);
		return new LdStr(i);
    }

    override string __str__() { return "chunks (io-stream object method)"; }
}


class _readline: LdOBJECT
{
	File x;  string md;
	char[] buf;

	this(File x, string md){
		this.x = x;
		this.md = md;
		this.buf = buf;
	}

    override LdOBJECT opCall(LdOBJECT[] args) {
    	if (args.length && args[0].__str__.length)
    		buf = x.readln!(char[])(args[0].__str__[0]);
		else
    		buf = x.readln!(char[])();

    	if(find(md, 'b').length)
    		return new LdChr(buf);

    	return new LdStr(cast(string)buf);
    }

    override string __str__() { return "readline (io-stream object method)"; }
}

class _write: LdOBJECT 
{
	File x; string md;

	this(File x, string md){
		this.x = x;
		this.md = md;
	}

    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(find(md, 'b').length)
    		x.rawWrite(args[0].__chars__);
    	else
    		x.write(args[0].__str__);

		return new LdNone();
    }

    override string __str__() { return "write (io-stream object method)"; }
}

class _writeline: LdOBJECT 
{
	File x; string md;

	this(File x, string md){
		this.x = x;
		this.md = md;
	}

    override LdOBJECT opCall(LdOBJECT[] args) {
    	if(find(md, 'b').length)
    		x.writeln(args[0].__chars__);
    	else
    		x.writeln(args[0].__str__);

		return new LdNone();
    }

    override string __str__() { return "writeline (io-stream object method)"; }
}

class _seek: LdOBJECT 
{
	File x;
	this(File x){ this.x = x; }

    override LdOBJECT opCall(LdOBJECT[] args) {
    	if (args.length)
			if (args.length == 1)
				x.seek(cast(uint)args[0].__num__, 2);
			else
				x.seek(cast(uint)args[0].__num__, cast(int)args[1].__num__);

		return new LdNone();
    }

    override string __str__() { return "seek (io-stream object method)"; }
}
