module LdIntermediate;

import std.stdio;
import std.algorithm.iteration: each;

import LdParser, LdLexer, LdNode, LdObject;
import LdBytes, LdBytes2;


class _GenInter {
	int branch, seed;
	Node[] tree; Node leaf; LdByte[] bytez;

	this(Node[] tree){
		this.branch = -1;  this.seed = 1;
		this.leaf = leaf;  this.tree = tree;
		this.bytez = bytez;
		this.climb();   this.irrigate();
	}


	void climb(){
		branch += 1;

		if (branch < tree.length)
			leaf = tree[branch];
		else
			seed = 0;
	}

	LdByte IntOp(string op, LdByte left, LdByte right){
		if (op == "+")
			return new Op_Add(left, right);

		else if (op == "-")
			return new Op_Minus(left, right);

		else if (op == "*")
			return new Op_Times(left, right);

		else if (op == "/")
			return new Op_Divide(left, right);

		else if (op == "%")
			return new Op_Remainder(left, right);

		else if (op == "<")
			return new Op_Less(left, right);

		else if (op == ">")
			return new Op_Great(left, right);

		else if (op == "==")
			return new Op_Equals(left, right);

		else if (op == "!=")
			return new Op_NOTequals(left, right);

		else if (op == "<=")
			return new Op_Lequals(left, right);

		else if (op == ">=")
			return new Op_Gequals(left, right);

		return right;
	}


	LdByte BinaryOp(Node sap){
		int type = sap.leftRight[0].type;

		LdByte left = water(sap.leftRight[0]);
		LdByte right = water(sap.leftRight[1]);

		if (sap.str == "NOT")
			return new Op_Not(right);

		else if (sap.str == "OR")
			return new Op_Or(left, right);

		else if (sap.str == "AND")
			return new Op_And(left, right);

		return IntOp(sap.str, left, right);
	}

	LdByte FnCallOp(Node sap){
		LdByte[] args;
		LdByte def = this.water(sap.expr);

		foreach(Node i; sap.params)
			args ~= this.water(i);

		return new Op_FnCall(def, args);
	}

	LdByte FnDefOp(Node sap){
		LdByte[] defaults;
		
		foreach(Node i; sap.leftRight)
			defaults ~= this.water(i);

		//					fnName   params  def-params   fn-code-scope
		return new Op_FnDef(sap.str, sap.args, defaults, new _GenInter(sap.params).bytez);		
	}

	LdByte ArrOp(Node sap){
		LdByte[] arr;

		foreach(Node i; sap.params)
			arr ~= water(i);

		return new Op_Array(arr);
	}

	LdByte HashOp(Node sap){
		LdByte[] hs; 

		foreach(Node i; sap.params)
			hs ~= water(i);

		return new Op_Hash(sap.args, hs);
	}

	LdByte IndexOp(Node sap){
		LdByte key = water(sap.leftRight[0]);
		LdByte index = water(sap.leftRight[1]);

		if (sap.exe)
			return new Op_PiAssign(key, index, water(sap.leftRight[2]));
		
		return new Op_Pindex(key, index);
	}

	LdByte DotOp(Node sap){
		LdByte key = water(sap.expr);

		if (sap.exe)
			return new Op_PdotAssign(key, sap.str, water(sap.expr2));
		
		return new Op_Pdot(key, sap.str);
	}

	LdByte FormatOp(Node sap) {
		LdByte[] arr;
		sap.params.each!(i => arr ~= water(i));
		
		return new Op_Format(arr);
	}

	LdByte water(Node sap){
		if (sap.type == 26)
			return new Op_Id(sap.str);

		else if (sap.type == 1)
			return new Op_Num(sap.f64);
				
		else if (sap.type == 2)
			return new Op_Str(sap.str);

		else if (sap.type == 3)
			return this.ArrOp(sap);

		else if (sap.type == 5)
			return this.BinaryOp(sap);

		else if (sap.type == 7)
			return this.FnCallOp(sap);

		else if (sap.type == 8)
			return this.DotOp(sap);

		else if (sap.type == 4)
			return this.HashOp(sap);

		else if (sap.type == 9)
			return this.IndexOp(sap);

		else if (sap.type == 27)
			return this.FormatOp(sap);

		else if (sap.type == 10)
			return this.FnDefOp(sap);

		else if (sap.type == 31)
			return new Op_True();

		else if (sap.type == 32)
			return new Op_False();

		else if (sap.type == 33)
			return new Op_None();

		return new LdByte();
	}

	void gen_var(){
		bytez ~= new Op_Var(this.leaf.str, water(this.leaf.expr));
	}

	void gen_fndef(){
		bytez ~= water(this.leaf);
	}

	void gen_fncall(){
		bytez ~= water(this.leaf);
	}

	void gen_objdef() {
		LdByte[] herits;
		string[] attrs;

		foreach(Node i; leaf.leftRight)
			herits ~= water(i);

		foreach(Node x; leaf.params){
			if (x.type == 10 || x.type == 6)
				attrs ~= x.str;
		}
		bytez ~= new Op_Pobj(leaf.str, herits, attrs, new _GenInter(leaf.params).bytez);
	}

	void gen_if() {
		LdByte[] elifs;

		foreach(Node i; this.leaf.params)
			elifs ~= new Op_If(water(i.expr), new _GenInter(i.params).bytez);

		bytez ~= new Op_IfCase(elifs);
	}

	void gen_while() {
		LdByte base = water(leaf.expr);
		LdByte[] code = new _GenInter(leaf.params).bytez;

		bytez ~= new Op_While(base, code);
	}

	void gen_for() {
		bytez ~= new Op_For(leaf.str, water(leaf.expr), new _GenInter(leaf.params).bytez);
	}

	void gen_indexing() {
		bytez ~= water(this.leaf);
	}

	void gen_dotting() {
		bytez ~= water(this.leaf);
	}

	void gen_return() {
		bytez ~= new Op_Return(water(leaf.expr));
	}

	void gen_addFls() {
		bytez ~= new Op_Include(water(leaf.expr));
	}

	void gen_imp() {
		bytez ~= new Iimport(leaf.strs, leaf.args);
	}

	void gen_from() {
		bytez ~= new Ifrom(leaf.str, leaf.strs, leaf.args);
	}

	void irrigate(){
		while (this.seed){
			switch (this.leaf.type){
				case 6:
					gen_var();
					break;
				case 7:
					gen_fncall();
					break;
				case 8:
					gen_dotting();
					break;
				case 9:
					gen_indexing();
					break;
				case 14:
					gen_if();
					break;
				case 27:
					bytez ~= water(leaf);
					break;
				case 16:
					gen_while();
					break;
				case 18:
					gen_for();
					break;
				case 12:
					gen_return();
					break;
				case 10:
					gen_fndef();
					break;
				case 11:
					gen_objdef();
					break;
				case 21:
					bytez ~= new Op_Break();
					break;
				case 35:
					bytez ~= new Op_Continue();
					break;
				case 29:
					gen_imp();
					break;
				case 36:
					gen_from();
					break;
				case 30:
					gen_addFls();
					break;
				default:
					bytez ~= water(leaf);
					break;
					
			}
			this.climb();
		}
	}
}


