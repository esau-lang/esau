module lSocket;


import std.socket;
import std.conv: to;
import std.stdio: writeln;

import LdObject;

alias LdOBJECT[string] Heap;

class oSocket: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"Socket": new new_socket(),

			"addrFamily": address_family(),
			"sockType": socket_type(),
			"protoType": protocol_type(),
			"shutType": shutdown_type(),

			"getaddrinfo": new GetAdrrInfo(),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "socket (native module)"; }
}


class GetAdrrInfo: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
    	LdOBJECT[] info;

        foreach(i; getAddressInfo(args[0].__str__, args[1].__str__))
        	info ~= new LdArr([new LdNum(i.family), new LdNum(i.type), new LdNum(i.protocol), new LdStr(i.canonicalName), new LdArr([
        			new LdStr(i.address.toAddrString),
        			new LdNum(to!double(i.address.toPortString)),
        		])]);

        return new LdArr(info);
    }

    override string __str__() { return "socket.getaddrinfo (method)"; }
}


LdOBJECT address_family()
{
	return new LdDict("socket.addrFamily (object)", [
			"APPLETALK": new LdNum(AddressFamily.APPLETALK),
			"INET": new LdNum(AddressFamily.INET),
			"INET6": new LdNum(AddressFamily.INET6),
			"IPX": new LdNum(AddressFamily.IPX),
			"UNIX": new LdNum(AddressFamily.UNIX),
			"UNSPEC": new LdNum(AddressFamily.UNSPEC),
		]);
}

LdOBJECT socket_type()
{
	return new LdDict("socket.sockType (object)", [
			"STREAM": new LdNum(SocketType.STREAM),
			"DGRAM": new LdNum(SocketType.DGRAM),
			"RAW": new LdNum(SocketType.RAW),
			"RDM": new LdNum(SocketType.RDM),
			"SEQPACKET": new LdNum(SocketType.SEQPACKET),
		]);
}

LdOBJECT protocol_type()
{
	return new LdDict("socket.protoType (object)", [
			"IP": new LdNum(ProtocolType.IP),
			"ICMP": new LdNum(ProtocolType.ICMP),
			"IGMP": new LdNum(ProtocolType.IGMP),
			"GGP": new LdNum(ProtocolType.GGP),
			"TCP": new LdNum(ProtocolType.TCP),
			"PUP": new LdNum(ProtocolType.PUP),
			"UDP": new LdNum(ProtocolType.UDP),
			"IDP": new LdNum(ProtocolType.IDP),
			"RAW": new LdNum(ProtocolType.RAW),
			"IPV6": new LdNum(ProtocolType.IPV6),
		]);
}

LdOBJECT shutdown_type()
{
	return new LdDict("shut_type (Socket object)", [
			"BOTH": new LdNum(SocketShutdown.BOTH),
			"RECEIVE": new LdNum(SocketShutdown.RECEIVE),
			"SEND": new LdNum(SocketShutdown.SEND),
		]);
}

AddressFamily AF(ushort x)
{
	AddressFamily aF;

	switch (x){
	    case aF.INET6:
	        return aF.INET6;

	    case aF.UNIX:
	        return aF.UNIX;

	    case aF.IPX:
	        return aF.IPX;

	    case aF.APPLETALK:
	        return aF.APPLETALK;

	    case aF.UNSPEC:
	        return aF.UNSPEC;

	    default:
	    	return aF.INET;
	}

	return aF.INET;
}

SocketType ST(int x)
{
    SocketType sK;

    switch (x){
	    case sK.DGRAM:
	        return sK.DGRAM;

	    case sK.RDM:
	        return sK.RDM;

	    case sK.RAW:
	        return sK.RAW;

	    case sK.SEQPACKET:
	        return sK.SEQPACKET;

	    default:
	    	return sK.STREAM;
	}

	return sK.STREAM;
}

ProtocolType PT(int x)
{
    ProtocolType pT;

    switch (x){
	    case pT.IP:
	    	return pT.IP;

		case pT.ICMP:
			return pT.ICMP;

		case pT.IGMP:
			return pT.IGMP;

		case pT.GGP:
			return pT.GGP;

		case pT.TCP:
			return pT.TCP;

		case pT.PUP:
			return pT.PUP;

		case pT.UDP:
			return pT.UDP;

		case pT.RAW:
			return pT.RAW;

		case pT.IDP:
			return pT.IDP;

		case pT.IPV6:
			return pT.IPV6;

		default:
			return pT.IP;
	}

	return pT.IP;
}


import std.uni: toLower;


class new_socket: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length == 2)
        	return new _socket(new Socket(AF(cast(ushort)args[0].__num__),
        								  ST(cast(int)args[1].__num__)));

        else if (args.length > 2)
        	return new _socket(new Socket(AF(cast(ushort)args[0].__num__),
        								  ST(cast(int)args[1].__num__),
        								  PT(cast(int)args[2].__num__)));
        else if (args.length == 1)
        	if (toLower(args[0].__str__) == "udp")
        		return new _socket(new UdpSocket());
        
        return new _socket(new TcpSocket());
    }

    override string __str__() { return "socket.Socket (object)";}
}


class _socket: LdOBJECT
{
    Heap props;
    Socket socket;

    this(Socket socket){
        this.socket = socket;
        this.socket.blocking = true;

        this.props = [
        	"isalive": new _IsAlive(socket),
        	"blocked": new _blocked(socket),

        	"bind": new _bind(socket),
        	"connect": new _connect(socket),

        	"listen": new _listen(socket),

        	"blocking": new _blocking(socket),
        	"non_blocking": new _nonblocking(socket),

        	"accept": new _accept(socket),
        	"send": new _send(socket),
        	"sendto": new _sendto(socket),
        	"recv": new _recv(socket),

        	"shutdown": new _shutdown(socket),
        	"close": new _close(socket),

        	"Ip": new LdStr(socket.hostName),
        	"addr_family": new LdNum(cast(double)socket.addressFamily)
        ];
    }
   	
   	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "Socket (socket connection object)"; }
}


class _bind: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            socket.bind(new InternetAddress(args[0].__str__, cast(ushort)args[1].__num__));
       	
       	else
        	throw new Exception("socket.bind requires a 'host-name' and a 'port-number'.");

        return new LdNone();
    }

    override string __str__() { return "bind (Socket.socket method)"; }
}


class _connect: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            this.socket.connect(new InternetAddress(args[0].__str__, cast(ushort)args[1].__num__));
       	else
        	throw new Exception("socket.connect requires a 'host-name' and a 'port-number'.");

        return new LdNone();
    }

    override string __str__() { return "connect (Socket.socket method)"; }
}


class _listen: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        socket.listen(cast(int)args[0].__num__);
        return new LdNone();
    }

    override string __str__() { return "listen (Socket.socket method)"; }
}


class _blocking: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] params){
        socket.blocking = false;
        return new LdNone();
    }

    override string __str__() { return "blocking (Socket.socket method)"; }
}


class _nonblocking: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] params){
        socket.blocking = true;
        return new LdNone();
    }

    override string __str__() { return "non_blocking (Socket.socket method)"; }
}


class _accept: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        return new _socket(socket.accept());
    }

    override string __str__() { return "accept (Socket.socket method)"; }
}


class _send: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        socket.send(args[0].__chars__);
        return new LdNone();
    }

    override string __str__() { return "send (Socket.socket method)"; }
}


class _sendto: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        socket.sendTo(args[0].__chars__);
        return new LdNone();
    }

    override string __str__() { return "sendto (Socket.socket method)"; }
}


class _recv: LdOBJECT
{
    Socket socket;
    char[64000] buffer;

    this(Socket socket){
    	this.buffer = buffer;
    	this.socket = socket;
    }

    override LdOBJECT opCall(LdOBJECT[] args){
        auto data = socket.receive(buffer);

        if (args.length)
            return new LdChr(buffer[0 .. cast(uint)args[0].__num__]);

        return new LdChr(buffer[0 .. data]);
    }

    override string __str__() { return "recv (Socket.socket method)"; }
}


SocketShutdown SD(int x)
{
    SocketShutdown t;

    switch (x){
    	case t.RECEIVE:
	    	return t.RECEIVE;

	    case t.SEND:
	    	return t.SEND;

	    default:
	    	return t.BOTH;
	}

	return t.BOTH;
}

class _shutdown: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length)
            socket.shutdown(SD(cast(int)args[0].__num__)); 
        else
        	socket.shutdown(SocketShutdown.BOTH);

        return new LdNone();
    }

    override string __str__() { return "shutdown (Socket.socket method)"; }
}


class _close: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        socket.close();
        return new LdNone();
    }

    override string __str__() { return "close (Socket.socket method)"; }
}


class _IsAlive: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        if (socket.isAlive())
            return new LdTrue();

        return new LdFalse();
    }

    override string __str__() { return "IsAlive (Socket.socket method)"; }
}


class _blocked: LdOBJECT
{
    Socket socket;
    this(Socket socket){ this.socket = socket; }

    override LdOBJECT opCall(LdOBJECT[] args){
        if (socket.blocking)
            return new LdTrue();

        return new LdFalse();
    }

    override string __str__() { return "blocked (Socket.socket method)"; }
}

