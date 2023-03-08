module lFlare;

import std.stdio;
import std.socket;
import std.conv;
import std.digest.sha;
import std.base64;
import std.regex;
import std.bitmanip;
import std.random;
import std.array;
import std.format: format;

import std.path: buildPath;
import std.file: write, exists, isDir;

import core.thread.osthread: Thread;
import core.time: dur;
import core.stdc.time;

import LdObject;
import lJson: _Parse;

alias LdOBJECT[string] Heap;

class oFlare: LdOBJECT {
	Heap props;

	this(){
		this.props = [
			"App": new _App(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "flare (native module)"; }
}


class _App: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	return new _FlareApp(args[0].__str__);
    }

    override string __str__() { return "flare.App (type)";}
}

class _FlareApp: LdOBJECT {
	_Js js;
	Heap props;

	string app_path;

	WebSocket ws;
	LdOBJECT[string] functions;

	this(string app_path){
		this.app_path = app_path;

		this.ws = ws;
		this.js = new _Js(this);

		this.functions = [".": RETURN.A];

		this.props = [
			"js": new _Javascript(this),
			"start": new _Start(this),
			"export": new _Export(this),
			"exported_functions": new LdHsh(functions),
		];
	}

	override LdOBJECT[string] __props__(){
		return props;
	}

	override string __str__(){ return "flare.App (object)"; }
}


class _Export: LdOBJECT {
	_FlareApp app;

	this(_FlareApp app){
		this.app = app;
	}

    override LdOBJECT opCall(LdOBJECT[] args){
    	foreach(i; args)
    		app.functions[i.__getProp__("__name__").__str__] = i;

        return RETURN.A;
    }

    override string __str__() { return "App.export (method of flare)";}
}


class _Javascript: LdOBJECT {
	_FlareApp app;

	this(_FlareApp app) {
		this.app = app;
	}

    override LdOBJECT opCall(LdOBJECT[] args){
    	if((args[0].__str__).length)
    		app.ws.send(cast(char[])(args[0].__str__));

        return RETURN.A;
    }
    override string __str__() { return "App.js (method of flare)";}
}


class _Start: LdOBJECT {
	_FlareApp app;

	this(_FlareApp app){ this.app = app; }

    override LdOBJECT opCall(LdOBJECT[] args){
		WebSocket ws = new WebSocket(new Start_WebSocket(app.app_path));
		ws.Js = app.js;
		app.ws = ws;

		ws.EventListener();
        return RETURN.A;
    }
    override string __str__() { return "App.start (method of flare)";}
}


class _Js {
	_Parse json_parse;
	_FlareApp Js;

	this(_FlareApp Js){
		this.Js = Js;
		this.json_parse = new _Parse();
	}

    int opCall(string json) {
    	LdOBJECT[string] h = json_parse([new LdStr(json)]).__hash__;

    	if ("name" in h && "args" in h){
    		string fn = h["name"].__str__;
    		
    		if (fn in Js.functions)
    			Js.functions[fn](*(h["args"].__ptr__));

    		else
    			writeln("function ", fn, " is not defined.");
    	}

    	return 0;
    }
}


enum BUFF_SIZE = 64000;
enum MAX_MSGLEN = 65535;


class Start_WebSocket {
	Socket sock;
	ushort port;
	string hostname, flare_binder;

	this(string flare_binder){
		this.sock = new TcpSocket();

		this.hostname = "127.0.0.1";
		this.port = 7575;

		while (true) {
			try{
				this.sock.bind(new InternetAddress(this.hostname, this.port));
				break;
			} catch (Exception e) {}
			this.port++;
		}
		this.sock.blocking = true;

		writeln("... Esau Interpreter flare interface.");

		if(exists(flare_binder) && isDir(flare_binder)){
			flare_binder = buildPath(flare_binder, "flare_binder.js");

			write(flare_binder, format("\n//very important for the library to work\n\nconst ws = new WebSocket('ws://%s:%d');\n", this.hostname, this.port));

			writeln(format("... successfully touched socket file -> %s", flare_binder));
		} else {
			writeln(format("... ERROR js socket file %s touching failed.", flare_binder));
			writeln("... exiting since further execution is dangerous.");

			throw new Exception("flare error: '%s' app path does not exist.", flare_binder);
		}

		writeln(format("... flare websocket server started on address -> %s:%d.", this.hostname, this.port));
		writeln("... waiting of a client to connect, only one accepted.");
	}
}


class WebSocket {
	Socket app;
	_Js Js;
	Start_WebSocket soc;

	this(Start_WebSocket soc){
		this.Js = Js;

		this.soc = soc;
		this.soc.sock.listen(5);

		this.app = soc.sock.accept();
		writeln("... client made http handshake...");

		while (true) {
			char[] msg;
			char[BUFF_SIZE] buf;

			auto data = this.app.receive(buf);
			msg = buf[0..data];

			auto sec = match(cast(string)msg, "Sec-WebSocket-Key: (.*)");
		    string swka;
		    
		    bool wbSocket = false;

			foreach(i; sec){
		    	if(i.length > 1){
		    		wbSocket = true;
		    		swka = i[1];
		    	}
		    	break;
		    }

		    if (wbSocket){
			    swka ~= "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
			    
			    ubyte[20] swkaSha1 = sha1Of(swka);
			    string swkaSha1Base64 = Base64.encode(swkaSha1);

			    string res = (
			        "HTTP/1.1 101 Switching Protocols\r\n" ~
			        "Connection: Upgrade\r\n" ~
			        "Upgrade: websocket\r\n" ~
			        "Sec-WebSocket-Accept: " ~ swkaSha1Base64 ~ 
			        "\r\n\r\n"
			    );

				this.app.send(cast(char[])res);	
				writeln("... client handshake turned to websocket 200 OK");
				break;
			}
		}
	}

	void EventListener(){
		while (true) {
			char[BUFF_SIZE] buf;
			auto len = app.receive(buf);

			if (len > 0)
				on_message(buf[0..len]);
			else{
				writeln("... ERROR fronted disconnected or encounted an error.");
				writeln("... shutdown backend socket serve.r");
				break;
			}
		}

		app.shutdown(SocketShutdown.BOTH);
		app.close();

		soc.sock.shutdown(SocketShutdown.BOTH);
		soc.sock.close();
	}


	void send(char[] data){
        char[] op = [129];
	    auto len = appender!(const ubyte[])();

        if (data.length < 126)
        	op ~= cast(ubyte)data.length;

        else if (data.length < MAX_MSGLEN+1) {
			op ~= 126;
			len.append!ushort(cast(ushort)data.length);

        } else {
        	op ~= 127;
        	len.append!ulong(data.length);
        	
        }

        op ~= cast(char[])len.data ~ data;
        app.send(op);
	}


	void on_message(char[] data){
		ubyte[] bytes = cast(ubyte[])data;

		bool fin = (bytes[0] & 0b10000000) != 0;
		bool mask = (bytes[1] & 0b10000000) != 0;

	    int opcode = bytes[0] & 0b00001111;
	    int offset = 2;

	    size_t msglen = bytes[1] & 0b01111111;

	    if (msglen == 126) {
	    	msglen = bytes.peek!ushort(2);
	        offset = 4;
	    
	    } else if (msglen == 127) {
	        msglen = bytes.peek!size_t(2);
	        offset = 10;
	    }

	    // to text
	    ubyte[] decoded = new ubyte[msglen];
        ubyte[] masks = [bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3]];
        offset += 4;

        for (size_t i = 0; i < msglen; ++i)
            decoded[i] = cast(ubyte)(bytes[offset + i] ^ masks[i % 4]);

        string json_data = cast(string)decoded;
        Js(json_data);
	}
}

