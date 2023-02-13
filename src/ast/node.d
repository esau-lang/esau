module LdNode;


struct TOKEN{
	string value, type;
	int tab, line, loc;
}


class Node{

	string str(){
		return "undef";
	}

	double f64(){
		return 0.1;
	}

	int exe(){
		return 0;
	}

	int line(){
		return 0;
	}

	int index(){
		return 0;
	}

	bool opt(){
		return false;
	}

	Node[] leftRight(){
		return [];
	}

	Node expr(){
		return new Node;
	}

	int type(){
		return 0;
	}

	Node expr2(){
		return new Node;
	}

	Node[] params(){
		return [new Node];
	}

	string[] args(){
		return [""];
	}

	string[][string] deepin(){
		return deepin;
	}

	string[string] strs(){
		return strs;
	}
}


class IdNode: Node{
	int pos, loc;
	string key;

	this(string key, int pos = 0, int loc = 0){
		this.key = key;
		this.pos = pos;
		this.loc = loc;
	}

	override string str(){
		return this.key;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 26;
	}
}


class NumberNode: Node{
	double value;

	this(double value){
		this.value = value;
	}

	override double f64(){
		return this.value;
	}

	override int type(){
		return 1;
	}
}


class StringNode: Node{
	string value;

	this(string value){
		this.value = value;
	}

	override string str(){
		return this.value;
	}

	override int type(){
		return 2;
	}
}


class FormatNode: Node{
	Node[] forms;

	this(Node[] forms){
		this.forms = forms;
	}

	override Node[] params(){
		return this.forms;
	}

	override int type(){
		return 27;
	}
}

class cAssignNode: Node{
	Node[] forms;

	this(Node[] forms){
		this.forms = forms;
	}

	override Node[] params(){
		return this.forms;
	}

	override int type(){
		return 28;
	}
}


class ListNode: Node{
	Node[] list;

	this(Node[] list){
		this.list = list;
	}

	override Node[] params(){
		return this.list;
	}

	override int type(){
		return 3;
	}
}

class ImportNode: Node{
	int loc, pos;
	string[][string] imps;
	string[] frms;

	this(string[][string] imps, string[] frms, int pos = 0, int loc = 0){
		this.imps = imps;
		this.frms = frms;
		this.pos = pos;
		this.loc = loc;
	}

	override string[][string] deepin(){
		return imps;
	}

	override string[] args(){
		return frms;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 29;
	}
}

class IncludeNode: Node{
	Node modules;
	int loc, pos;

	this(Node modules, int pos = 0, int loc = 0){
		this.modules = modules;
		this.pos = pos;
		this.loc = loc;
	}

	override Node expr(){
		return this.modules;
	}


	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 30;
	}
}


class DictNode: Node{
	string[] keys;
	Node[] values;

	this(string[] keys, Node[] values){
		this.keys = keys;
		this.values = values;
	}

	override string[] args(){
		return this.keys;
	}

	override Node[] params(){
		return this.values;
	}

	override int type(){
		return 4;
	}
}


class TrueNode: Node{
	override int type(){
		return 31;
	}
}

class FalseNode: Node{
	override int type(){
		return 32;
	}
}

class NullNode: Node{
	override int type(){
		return 33;
	}
}


class BinaryNode: Node{
	Node left;
	string op;
	Node right;
	int pos, loc;

	this(Node left, string op, Node right, int pos = 0, int loc = 0){
		this.left = left;
		this.op = op;
		this.right = right;
		this.pos = pos;
		this.loc = loc;
	}

	override Node[] leftRight(){
		return [this.left, this.right];
	}

	override string str(){
		return this.op;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 5;
	}
}


class VarNode: Node{
	string key;
	Node ast;

	this(string key, Node ast){
		this.key = key;
		this.ast = ast;
	}

	override string str(){
		return this.key;
	}

	override Node expr(){
		return this.ast;
	}

	override int type(){
		return 6;
	}
}


class CallNode: Node{
	int pos, loc;
	Node ast;
	Node[] args;

	this(Node ast, Node[] args, int pos = 0, int loc = 0){
		this.ast = ast;
		this.args = args;
		this.pos = pos;
		this.loc = loc;
	}

	override Node expr(){
		return this.ast;
	}

	override Node[] params(){
		return this.args;
	}

	override int type(){
		return 7;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}
}


class GetNode: Node{
	int assign, loc, pos;
	Node ast;
	string key;
	Node value;

	this(Node ast, string key, int assign, Node value, int pos = 0, int loc=0){
		this.ast = ast;
		this.key = key;
		this.assign = assign;
		this.value = value;
		this.pos = pos;
		this.loc = loc;
	}

	override int exe(){
		return this.assign;
	}

	override Node expr(){
		return this.ast;
	}

	override Node expr2(){
		return this.value;
	}

	override string str(){
		return this.key;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 8;
	}
}

class IndexNode: Node{
	int assign, pos;
	Node ast;
	Node index;
	Node value;

	this(Node ast, Node index, int assign, Node value, int pos = 0){
		this.ast = ast;
		this.index = index;
		this.assign = assign;
		this.value = value;
		this.pos = pos;
	}

	override int exe(){
		return this.assign;
	}

	override Node[] leftRight(){
		return [this.ast, this.index, this.value];
	}

	override int line(){
		return this.pos;
	}

	override int type(){
		return 9;
	}
}


class FunctionNode: Node{
	string name;
	Node[] code;
	string[] parameters;
	Node[] defaults;

	this(string name, string[] parameters, Node[] defaults, Node[] code){
		this.name = name;
		this.parameters = parameters;
		this.defaults = defaults;
		this.code = code;
	}

	override string str(){
		return this.name;
	}

	override Node[] params(){
		return this.code;
	}

	override Node[] leftRight(){
		return this.defaults;
	}

	override string[] args(){
		return this.parameters;
	}

	override int type(){
		return 10;
	}
}


class ClassNode: Node{
	string name;
	Node[] args;
	Node[] code;

	this(string name, Node[] args, Node[] code){
		this.name = name;
		this.args = args;
		this.code = code;
	}

	override string str(){
		return this.name;
	}

	override Node[] params(){
		return this.code;
	}

	override Node[] leftRight(){
		return this.args;
	}

	override int type(){
		return 11;
	}
}


class ReturnNode: Node{
	Node ast;

	this(Node ast){
		this.ast = ast;
	}

	override Node expr(){
		return this.ast;
	}

	override int type(){
		return 12;
	}
}


class notNode: Node{
	Node ast;

	this(Node ast){
		this.ast = ast;
	}

	override Node expr(){
		return this.ast;
	}

	override int type(){
		return 34;
	}
}


class IfNode: Node{
	Node ast;
	Node[] code;

	this(Node ast, Node[] code){
		this.ast = ast;
		this.code = code;
	}

	override Node expr(){
		return this.ast;
	}

	override Node[] params(){
		return this.code;
	}

	override int type(){
		return 13;
	}
}


class IfStatementNode: Node{
	Node[] code;

	this(Node[] code){
		this.code = code;
	}

	override Node[] params(){
		return this.code;
	}

	override int type(){
		return 14;
	}
}


class WhlNode: Node{
	Node ast;

	this(Node ast){
		this.ast = ast;
	}

	override Node expr(){
		return this.ast;
	}

	override int type(){
		return 15;
	}
}


class WhileNode: Node{
	Node ast;
	Node[] code;

	this(Node ast, Node[] code){
		this.ast = ast;
		this.code = code;
	}

	override Node expr(){
		return this.ast;
	}

	override Node[] params(){
		return this.code ~ new WhlNode(this.ast);
	}

	override int type(){
		return 16;
	}
}


class FrNode: Node{
	string keys;

	this(string keys){
		this.keys = keys;
	}

	override string str(){
		return this.keys;
	}

	override int type(){
		return 17;
	}
}


class ForNode: Node{
	Node run;
	string var;
	Node[] code;

	this(string var, Node run, Node[] code){
		this.var = var;
		this.run = run;
		this.code = code;
	}

	override string str(){
		return this.var;
	}
	
	override Node expr(){
		return this.run;
	}

	override Node[] params(){
		return this.code;
	}

	override int type(){
		return 18;
	}
}


class SwNode: Node{
	Node ast;
	Node[] code;

	this(Node ast, Node[] code){
		this.ast = ast;
		this.code = code;
	}

	override Node expr(){
		return this.ast;
	}

	override Node[] params(){
		return this.code;
	}

	override int type(){
		return 19;
	}
}


class CsNode: Node{
	bool bk;
	Node ast;
	Node[] code;

	this(Node ast, Node[] code, bool bk){
		this.bk = bk;
		this.ast = ast;
		this.code = code;
	}

	override Node expr(){
		return this.ast;
	}

	override Node[] params(){
		return this.code;
	}

	override bool opt(){
		return this.bk;
	}

	override int type(){
		return 20;
	}
}

class BreakNode: Node{
	override int type(){
		return 21;
	}
}


class ContinueNode: Node{
	override int type(){
		return 35;
	}
}


class ERROR{
	Node[] traceback;
	
	this(){
		this.traceback = traceback;
	}
}

class Locate: Node{
	int pos, loc;
	string file;

	this(int pos, string file, int loc = 0){
		this.file = file;
		this.pos = pos;
		this.loc = loc;
	}

	override string str(){
		return this.file;
	}

	override int line(){
		return this.pos;
	}

	override int index(){
		return this.loc;
	}

	override int type(){
		return 23;
	}
}


class CatchNode: Node{
	string id;
	Node[] code;

	this(string id, Node[] code){
		this.id = id;
		this.code = code;
	}

	override Node[] params(){
		return this.code;
	}

	override string str(){
		return this.id;
	}

	override int type(){
		return 24;
	}
}

class TryNode: Node{
	Node[] code;

	this(Node[] code){
		this.code = code;
	}

	override Node[] params(){
		return this.code;
	}

	override int type(){
		return 25;
	}
}
