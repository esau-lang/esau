module LdParser;

import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.file;

import std.path: buildPath;

import std.format: format;
import core.stdc.stdlib;

import LdLexer, LdNode;


class _Parse{
	int pos;
	bool end;
	TOKEN tok;

	NODE[] AST;
	Node[] ast;
	
	string file;
	TOKEN[] toks;
	NODE[] defaults;

	this(TOKEN[] toks, string file){
		this.end = true;
		this.toks = toks;
		this.file = file;

		this.ast = ast;
		this.AST = AST;

		this.pos = -1;
		this.defaults = defaults;
		this.tok = tok;
		this.next();
		this.parse();
	}

	void next(){
		this.pos += 1;

		if (this.pos < this.toks.length)
			this.tok = this.toks[this.pos];
		else
			this.end = false;
	}

	void prev(){
		this.pos -= 1;
		this.tok = this.toks[this.pos];
	}

	void SyntaxError(string err, string errtype="syntax", int lineno=0){
		writeln("SyntaxError: ", err);
		writeln("" ~ this.file ~"\n");

		if (lineno)
			write(" [", lineno, "] ");		
		else
			write(" [", this.tok.line, "] ");

		if (exists(this.file)){
			File file = File(this.file, "r");
			
			if (!lineno)
				for(int i = 0; i < this.tok.line-1; i++)
					file.readln();
			else
				for(int i = 0; i < lineno-1; i++)
					file.readln();

			writeln(strip(file.readln));
			
			for(int i = 0; i < this.tok.loc; i++)
				write(' ');

			writeln("    ^");
			file.close();
		}

		if (this.file == "__stdin__")
			throw new Exception("syntax error occured");

		exit(0);
	}

	NODE listdata(){
		next();
		NODE[] list;

		while (end && tok.type != "]") {
			if (find("NL,", tok.type).length)
				next();
			else
				list ~= eval("NL,]");
		}

		NODE n = { type:3, code:list };
		return n;
	}

	NODE tupledata(){
		next();
		NODE[] list;
		string last = "NL";

		while (end && tok.type != ")") {
			if (find("NL,", tok.type).length) {
				last = tok.type;
				next();
			} else
				list ~= eval("NL,)");
		}

		if (list.length == 1 && last != ",")
			return list[0];

		NODE n = { type:3, code:list };
		return n;
	}

	void skip_whitespace(){
		while(end && find("NL", tok.type).length)
			next();
	}

	NODE dictdata(){
		next();
		
		string[] keys;
		NODE[] values;

		while (end && tok.type != "}") {
			if (find("NL,", tok.type).length)
				next();

			else {
				if (!find("IDSTRNUM", tok.type).length)
					SyntaxError("Invalid key '"~tok.value~ "' for dict value");

				keys ~= tok.value;
				next();

				if (tok.type != ":")
					this.SyntaxError("Expected ':' not '"~tok.value~"' to assign dict value.");

				next();
				skip_whitespace();
				values ~= eval("NL,}");
			}
		}

		NODE n = { type:4, args:keys, code:values };
		return n;
	}

	NODE extractdata(NODE obj){
		next();
		string attr = tok.value;
		next();

		if (tok.type == "="){
			next();

			NODE n = { type:8, str:attr, exe:1, code:[obj, eval("NL;")] };
			return n;
		}

		NODE n = { type:8, str:attr, exe:0, code:[obj] };
		return n;
	}

	NODE Index(NODE ret){
		next();
		NODE value = eval("]");
		next();

		if (tok.type == "="){
			next();
		
			NODE n = { type:9, exe:1, code:[ret, value, eval("NL;")] };
			return n;
		}
		
		NODE n = { type:9, exe:0, code:[ret, value] };
		return n;
	}

	Node formatdata(){
		string[] strs;
		Node[] forms;

		string st;
		string chars = this.tok.value;
		ulong len = this.tok.value.length;
		int i, count;

		while (i < len){
			if (chars[i] != '{'){
				st ~= chars[i];
				i += 1;
			} else {
				if (st.length){
					forms ~= new StringNode(st);
					st = "";
				}
				i += 1;
				count = 1;

				while (i < len){
					if (chars[i] == '{')
						count += 1;
					else if (chars[i] == '}'){
						count -= 1;
						if (!count)
							break;
					}
					st ~= chars[i];
					i += 1;
				}

				i += 1;
				if (st.length){
					forms ~= new _Parse(new _Lex("ODYESSY = " ~ st ~ ';').TOKENS, "format.io").ast[0].expr;
					st = "";
				}
			}
		}

		if (st.length)
			forms ~= new StringNode(st);

		return new FormatNode(forms);
	}

	NODE assignNode(string end){
		next();
		NODE[] expr;

		expr ~= eval(":");
		next();

		expr ~= eval("?");
		next();

		expr ~= eval(end);
		prev();
		
		NODE n = { type:28, code:expr };
		return n;
	}

	//Node unknownFnNode(){
	//	this.next();
	//	return new FunctionNode("lambda", this.getParams(), this.defaults, new _Parse(this.getCode(), this.file).ast);
	//}

	NODE factor(string end){
		NODE ret;
		if (tok.type == "ID"){
			NODE n = { type:26, str:tok.value };
			ret = n;
		} else if (tok.type == "STR"){
			NODE n = { type:2, str:tok.value };
			ret = n;
		} else if (tok.type == "NUM"){
			double number = to!double(tok.value);
			NODE n = { type:1, f64:number };
			ret = n;
	
		} else if (tok.type == "TRUE"){
			NODE n = { type:31 };
			ret = n;
				
		} else if (tok.type == "FALSE"){
			NODE n = { type:32 };
			ret = n;

		} else if (tok.type == "NONE") {
			NODE n = { type:33 };
			ret = n;

		} else if (tok.type == "[")
			ret = listdata();

		else if (tok.type == "{")
			ret = dictdata();

		else if (tok.type == "(")
			ret = tupledata();

		//else if (tok.type == "FMT")
		//	ret = formatdata();
		
		else if (tok.type == "IF"){
			ret = assignNode(end);
		
		}
		// else if (tok.type == "?") {
		//	ret = unknownFnNode();
		//	prev();

		//}
		else {
			prev();
			SyntaxError("invalid token '" ~ tok.value ~"' in expression");
		}

		next();

		while (find("(.[AA", tok.type).length){
			if (tok.type == "("){
				NODE n = { type:7, expr:&ret, code:getArgs() };
				ret = n;
			
			} else if (tok.type == ".")
				ret = extractdata(ret);

			else if (tok.type == "AA"){ 
				string op = tok.value;
				next();

				NODE right = eval("NL;");
				NODE n = { type:5, str:op, defaults:[ret, right] };
				ret = n;

			} else
				ret = Index(ret);
		}
		
		return ret;
	}
	
	NODE term(string end){
		NODE val = factor(end);

		while (end && find("*/%", tok.type).length){
			string op = tok.type;
			next();

			NODE n = { type:5, str:op, defaults:[val, factor(end)] };
			val = n;
		}

		return val;
	}

	NODE expr(string end){
		NODE val = term(end);

		while (end && find("+-", tok.type).length){
			string op = tok.type;
			next();

			NODE n = { type:5, str:op, defaults:[val, term(end)] };
			val = n;
		}

		return val;
	}

	NODE eqexpr(string end){
		NODE val = expr(end);

		while (end && find("==<=>=!=IN", tok.type).length){
			string op = tok.type;
			next();

			NODE n = { type:5, str:op, defaults:[val, expr(end)] };
			val = n;
		}
		return val;
	}

	NODE notexpr(string end){
		if (tok.type == "NOT"){
			string op = tok.type;
			next();

			NODE fill = { type:1 };

			NODE n = { type:5, str:op, defaults:[fill, eqexpr(end)] };
			return n;		
		}

		return eqexpr(end);
	}

	NODE eval(string end){
		NODE val = notexpr(end);

		while (end && !find(end, tok.type).length && find("ANDOR", tok.type).length){
			string op = tok.type;
			next();

			NODE n = { type:5, str:op, defaults:[val, notexpr(end)] };
			val = n;
		}
		if (!find(end, tok.type).length)
			SyntaxError("Unexpected syntax '" ~ tok.value ~ "' in expression.");

		return val;
	}

	NODE[] getArgs(){
		NODE[] args;
		next();

		while (end && tok.type != ")"){
			if (find("NL,;", tok.type).length)
				next();
			else
				args ~= eval("NL,)");
		}

		next();
		return args;
	}

	string[] getParams(){
		string[] params;
		bool assigned = false;
		this.defaults = [];

		if (this.tok.type == "("){
			this.next();

			while (this.end && this.tok.type != ")"){
				if (this.tok.type == "ID"){
					params ~= this.tok.value;
					this.next();

					if (this.tok.type == "=" || this.tok.type == ":"){
						assigned = true;
						this.next();
						this.defaults ~= eval("NL,)");

					} else if (assigned) {
						this.prev();
						this.SyntaxError("Non-default parameter can't come after a default parameter.");
					}

				} else if (!find("NL,", this.tok.type).length){
					this.SyntaxError("Unexpected syntax '" ~ this.tok.value ~ "' while parsing function params.");

				} else {
					this.next();
				}
			}
			this.next();
		}

		return params;
	}

	TOKEN[] getCode(){
		int indent;
		TOKEN[] code;
		bool singleLine = true;

		if (find("NL:", this.tok.type).length){
			if (this.tok.type == "NL"){
				this.prev();
				singleLine = false;

			} else {
				this.next();

				if (this.tok.type != "NL"){
					while (this.end && !find("NL;", this.tok.type).length){
						code ~= this.tok;
						this.next();
					}

					code ~= this.tok;
					return code;

				} else {
					this.prev();
				}
			}

			indent = this.tok.tab;
			this.next();

			skip_whitespace();
		}

		if (this.tok.type == "{"){
			int lineno = this.tok.line;
			int linenod = this.tok.line;
			int counter = 1;
			this.next();

			while (this.end && counter){
				if (this.tok.type == "{")
					counter += 1;
				else if (this.tok.type == "}"){
					counter -= 1;
					if (!counter)
						break;
				}

				code ~= this.tok;
				this.next();
			}

			if (!this.end)
				this.SyntaxError("missing '}' to close code statement.", "indent", lineno);
			
			this.next();

		} else {
			while (this.end) {
				if (this.tok.tab > indent || this.tok.type == "NL"){
					code ~= this.tok;
					this.next();
					
				} else
					break;
			}
		}

		return code;
	}

	void parse_identifier() {
		string id = tok.value;
		next();

		if (tok.type == "="){
			next();
			// Var
			NODE expr = eval("NL;");
			NODE n = { type:6, str:id, expr:&expr };
			AST~=n;

		} else if (find(".([", this.tok.type).length) {
			prev();
			AST ~= eval("NL;");
			
			next();

		} else if (find("NL;", this.tok.type).length){
			this.next();

		} else if (find("AA", this.tok.type).length){
			this.prev();
			// ID
			NODE Val = {type:26, str:tok.value};
			next();

			string op = tok.value;
			next();

			// Binary
			NODE bin = {type:5, str:op, defaults:[Val, eval("NL;")]};
			
			// Var
			NODE n = {type:6, str:id, expr:&bin };
			AST ~= n;

		} else {
			this.SyntaxError("Unexpected syntax '" ~ this.tok.value ~ "' after ID token.");
		}
	}

	void parse_function(){
		next();
		string name = tok.value;

		next();
		// Fn
		NODE n = {type:10, str:name, args:getParams(), defaults:defaults, code:new _Parse(getCode(), file).AST};
		AST ~= n;
	}

	void parse_class(){
		next();
		NODE[] poly;

		if (tok.type != "ID")
			this.SyntaxError("Expected an ID for ClassName not '" ~ tok.value ~ "'.");

		string name = tok.value;
		this.next();

		if (tok.type == "(")
			poly = getArgs();

		// class
		NODE n = { type:11, str:name, defaults:poly, code:new _Parse(getCode(), file).AST };
		AST~=n;
	}

	void parse_return(){
		next();

		if (end && !find("NL;", this.tok.type).length) {
			NODE expr = eval("NL;");
			NODE n = { type:12, expr:&expr };
			AST~=n;

		} else {
			NODE None = { type:33 };
			NODE n = { type:12, expr:&None };
			AST~=n;
		}

		next();
	}

	void parse_if(){
		bool repeat = false;
		NODE expr;
		NODE[] statements;

		while (end){

			if (find("ELIFELSE", tok.type).length){

				if (tok.type == "ELSE"){
					NODE n = { type:1, f64:1 };
					expr = n;
					next();

				} else {
					if (tok.type == "IF" && repeat)
						break;
					
					next();
					expr = eval("NL{:");
				}

				NODE n = { type:13, expr:&expr, code:new _Parse(getCode(), file).AST };
				statements ~= n;

				repeat = true;

			} else if (tok.type == "NL")
				next();
			else
				break;
		}

		NODE N = { type:14, code:statements };
		AST~=N;
	}

	void parse_while(){
		next();

		NODE expr = eval("NL{:");
		NODE n = { type:16, expr:&expr, code:new _Parse(getCode(), file).AST };
		AST~=n;
	}

	void parse_for(){
		next();

		if(tok.type != "ID")
			SyntaxError("Expected an ID after 'for' not '"~tok.value~"'.");

		string id = tok.value;
		next();

		if (tok.type != "IN")
			SyntaxError("'for' expected 'in' not '" ~ this.tok.value ~"' after ID.");

		next();

		NODE expr = eval("NL{:");
		NODE n = { type:18, str:id, expr:&expr, code:new _Parse(getCode(), file).AST };
		AST~=n;
	}

	//void parse_switch(){
	//	this.next();
	//	bool bk = false;
	//	bool brk = false;
	//	Node NODE = eval("NL:{ARR");
	//	Node[] cs;
	//	Node[] case_toks;
	//	Node value;
	//	TOKEN[] toks;

	//	if (this.tok.type == "ARR"){
	//		this.next();

	//		if (this.tok.type == "BREAK"){
	//			bk = true;
	//			this.next();

	//		} else
	//			this.SyntaxError("Expected only the 'break' token.");
	//	}

	//	if (find("NL:{", this.tok.type).length){
	//		this.next();
	//	}

	//	while (this.end){
	//		if (find("CASE DF", this.tok.type).length){
	//			if (this.tok.type == "CASE"){
	//				this.next();
	//				value = this.eval("NL:{");

	//			} else {
	//				this.next();
	//				value = key;
	//			}


	//			toks = this.getCode();
	//			case_toks = new _Parse(toks, this.file).ast;

	//			if (bk){
	//				cs ~= new CsNode(value, case_toks, true);
	//			} else {
	//				foreach(TOKEN i; toks.reverse){
	//					if (i.type != "NL"){
	//						if (i.type == "BREAK"){
	//							brk = true;
	//						}
	//						break;
	//					}
	//				}
	//				cs ~= new CsNode(value, case_toks, brk);
	//				brk = false;					
	//			}

	//		} else if(this.tok.type != "NL"){
	//			break;

	//		} else {
	//			this.next();
	//		}
	//	}

	//	this.ast ~= new SwNode(key, cs);
	//}

	void parse_include(){
		this.next();

		NODE expr = eval("NL;");
		NODE n = { type:30, expr:&expr };
		AST~=n;

		this.next();
	}

	void parse_import(){
		bool _set = true;

		string[] _path, _inn;
		string[][string] _attrs;

		if (tok.type == "FR") {
			this.next();

			while (!find("IM", tok.type).length && this.end){
				if (tok.type == "ID")
					_path ~= tok.value;

				else if (tok.type != ".")
					SyntaxError("Invalid syntax Import statement, expected an '.' token to separate paths.");

				next();
			}
		}
		next();

		while (!find("NL;", this.tok.type).length && this.end){
			if (this.tok.type == "ID") {
				_inn ~= tok.value;                _set = true;
				next();

				if (tok.type == "AS") {
					next();

					if (tok.type != "ID")
						SyntaxError("Invalid syntax in import statement, expected an identifier.");

					_attrs[tok.value] = _inn;     _set = false;
					next();                       _inn.length = 0;
				}

			} else if (tok.type == ","){
				if(_inn.length){
					_attrs[_inn[_inn.length - 1]] = _inn;
					_inn.length = 0;

					_set = false;
				}
				next();

			} else if (tok.type == "*"){
				_inn ~= tok.value;
				next();

			} else if (tok.type != ".") {
				this.SyntaxError("Invalid syntax in import statement, expected an '.' token.");

			} else {
				next();
			}
		}

		if (_set && _inn.length)
			_attrs[_inn[_inn.length - 1]] = _inn;

		next();
		this.ast ~= new ImportNode(_attrs, _path, tok.line, tok.loc);
	}

	void parse_try(){
		this.next();
		Node[] nodz;

		nodz ~= new ListNode(new _Parse(this.getCode(), this.file).ast);

		if (this.tok.type == "CATCH"){
			this.next();

			if (this.tok.type != "ID")
				this.SyntaxError("Expected an id token after 'except' not '"~this.tok.value~"'.");

			string id = this.tok.value;

			this.next();
			nodz ~= new CatchNode(id, new _Parse(this.getCode(), this.file).ast);
		}

		this.ast ~= new TryNode(nodz);
	}

	void parse_from(){
		this.next();

		string fpath;

		if(tok.type == ".") {
			fpath = ".";
			next();
		}

		while (end && tok.type != "IM")
		{
			if(tok.type == "ID")
				fpath = buildPath(fpath, tok.value);
			else if(tok.type != ".")
				SyntaxError("Unexpected syntax in import statement.");
			next();
		}
		if (tok.type != "IM")
			SyntaxError(format("Expected an 'import' token not '%s'.", tok.value));
		this.next();

		string[string] attrs;
		string at;

		while(end && !find("NL;", tok.type).length)
		{
			if (tok.type == "ID") {
				at = tok.value;
				next();

				if(tok.type != "AS") {
					attrs[at] = at;
					continue;
				}
				next();

				if(tok.type != "ID")
					SyntaxError(format("Expected token '%s' after 'as', it should be an ID.", tok.value));

				attrs[tok.value] = at;
			
			} else if (tok.type != ",")
				SyntaxError(format("Expected token '%s' after 'import', it should be an ID separated by ','.", tok.value));
			else
				next();
		}

		NODE n = { type:36, str:fpath, strs:attrs };
		AST~=n;
	}

	void parse(){
		while (end){
			if (tok.type == "ID")
				parse_identifier();

			else if (tok.type == "RET")
				parse_return();

			else if (tok.type == "IF")
				parse_if();

			//else if (tok.type == "SWITCH")
			//	parse_switch();

			else if (tok.type == "WHILE")
				parse_while();

			else if(tok.type == "FOR")
				parse_for();

			else if (tok.type == "BREAK") {
				NODE n = { type:21 };
				AST~=n;
				next();

			} else if (tok.type == "CONT") {
				NODE n = { type:35 };
				AST~=n;
				next();

			} else if (tok.type == "FN")
				parse_function();

			else if (tok.type == "CL")
				parse_class();

			else if (tok.type == "IM")
				parse_import();

			else if (tok.type == "FR")
				parse_from();

			else if (tok.type == "INC")
				parse_include();

			else if (tok.type == "TRY")
				parse_try();

			else
				this.next();
		}

		writeln(AST);
	}
}
