module LdParser;

import std.stdio;
import std.conv;
import std.algorithm;
import std.string;
import std.file;
import core.stdc.stdlib;

import LdLexer, LdNode;


class _Parse{
	int pos;
	bool end;
	TOKEN tok;
	Node[] ast;
	string file;
	TOKEN[] toks;
	Node[] defaults;

	this(TOKEN[] toks, string file){
		this.end = true;
		this.toks = toks;
		this.file = file;
		this.ast = ast;
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

	Node listdata(){
		this.next();
		Node[] list;

		while (this.end && this.tok.type != "]") {
			if (find("NL,", this.tok.type).length) {
				this.next();
			} else {
				list ~= this.eval("NL,]");
			}
		}

		return new ListNode(list);
	}

	Node tupledata(){
		this.next();
		Node[] list;
		string last = "NL";

		while (this.end && this.tok.type != ")") {
			if (find("NL,", this.tok.type).length) {
				last = this.tok.type;
				this.next();
			} else {
				list ~= this.eval("NL,)");
			}
		}

		if (list.length == 1 && last != ","){
			return list[0];
		}

		return new ListNode(list);
	}

	void skip_whitespace(){
		while(this.end && find("NL", this.tok.type).length){
			this.next();
		}
	}

	Node objectdata(){
		this.next();
		string[] keys;
		Node[] values;

		while (this.end && this.tok.type != "}") {
			if (find("NL,", this.tok.type).length)
				this.next();

			else {
				if (!find("IDSTRNUM", this.tok.type).length){
					this.SyntaxError("Invalid key '"~this.tok.value~ "' for dict value");
				}

				keys ~= this.tok.value;
				this.next();

				if (this.tok.type != ":"){
					this.SyntaxError("Expected ':' not '"~this.tok.value~"' to assign dict value.");
				}

				this.next();
				this.skip_whitespace();
				values ~= this.eval("NL,}");
			}
		}

		return new DictNode(keys, values);
	}

	Node extractdata(Node ret){
		this.next();
		string value = this.tok.value;
		this.next();

		if (this.tok.type == "="){
			this.next();
			return new GetNode(ret, value, 1, this.eval("NL;"), this.tok.line, this.tok.loc);

		} else {
			return new GetNode(ret, value, 0, new Node(), this.tok.line, this.tok.loc);
		}
	}

	Node Index(Node ret){
		this.next();
		Node value = this.eval("]");
		this.next();

		if (this.tok.type == "="){
			this.next();
			return new IndexNode(ret, value, 1, this.eval("NL;"));

		} else {
			return new IndexNode(ret, value, 0, new Node());
		}
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

	Node assignNode(string end){
		this.next();
		Node[] expr;

		expr ~= this.eval(":");
		this.next();

		expr ~= this.eval("?");
		this.next();

		expr ~= this.eval(end);
		this.prev();
		return new cAssignNode(expr);
	}

	Node unknownFnNode(){
		this.next();
		return new FunctionNode("lambda", this.getParams(), this.defaults, new _Parse(this.getCode(), this.file).ast);
	}

	Node factor(string end){
		Node ret;
		if (this.tok.type == "ID")
			ret = new IdNode(this.tok.value, this.tok.line, this.tok.loc);

		else if (this.tok.type == "STR")
			ret = new StringNode(this.tok.value);
			
		else if (this.tok.type == "NUM"){
			double number = to!double(this.tok.value);
			ret = new NumberNode(number);

		} else if (this.tok.type == "TRUE")
			ret = new TrueNode();
			
		else if (this.tok.type == "FALSE")
			ret = new FalseNode();
			
		else if (this.tok.type == "NONE")
			ret = new NullNode();
			
		else if (this.tok.type == "[")
			ret = this.listdata();

		else if (this.tok.type == "{")
			ret = this.objectdata();

		else if (this.tok.type == "(")
			ret = this.tupledata();

		else if (this.tok.type == "FMT")
			ret = this.formatdata();
		
		else if (this.tok.type == "IF"){
			ret = this.assignNode(end);
		
		} else if (this.tok.type == "?") {
			ret = this.unknownFnNode();
			this.prev();

		} else {
			this.prev();
			this.SyntaxError("invalid token '" ~ this.tok.value ~"' in expression");
		}

		this.next();

		while (find("(.[AA", this.tok.type).length){
			if (this.tok.type == "(")
				ret = new CallNode(ret, this.getArgs(), this.tok.line, this.tok.loc);
			
			else if (this.tok.type == ".")
				ret = this.extractdata(ret);

			else if (this.tok.type == "AA"){ 
				string op = this.tok.value;
				this.next();

				Node expr = this.eval("NL;");
				ret = new BinaryNode(ret, op, expr);

			} else
				ret = this.Index(ret);
		}
		
		return ret;
	}
	
	Node term(string end){
		Node val = this.factor(end);

		while (this.end && find("*/%", this.tok.type).length){
			string op = this.tok.type;
			this.next();

			Node right = this.factor(end);
			val = new BinaryNode(val, op, right, this.tok.line); 
		}

		return val;
	}

	Node expr(string end){
		Node val = this.term(end);

		while (this.end && find("+-", this.tok.type).length){
			string op = this.tok.type;
			this.next();

			Node right = this.term(end);
			val = new BinaryNode(val, op, right); 
		}

		return val;
	}

	Node eqexpr(string end){
		Node val = this.expr(end);

		while (this.end && find("==<=>=!=IN", this.tok.type).length){
			string op = this.tok.type;
			this.next();

			Node right = this.expr(end);
			val = new BinaryNode(val, op, right); 
		}

		return val;
	}

	Node notexpr(string end){
		if (this.tok.type == "NOT"){
			string op = this.tok.type;
			this.next();
			return new BinaryNode(new StringNode(""), op, this.eqexpr(end)); 
		
		}

		return this.eqexpr(end);
	}

	Node eval(string end){
		Node val = this.notexpr(end);

		while (this.end && !find(end, this.tok.type).length && find("ANDOR", this.tok.type).length){
			string op = this.tok.type;
			this.next();

			Node right = this.notexpr(end);
			val = new BinaryNode(val, op, right); 
		}

		if (!find(end, this.tok.type).length){
			this.SyntaxError("Unexpected syntax '" ~ this.tok.value ~ "' in expression.");
		}

		return val;
	}

	Node[] getArgs(){
		Node[] args;
		this.next();

		while (this.end && this.tok.type != ")"){
			if (find("NL,;", this.tok.type).length){
				this.next();
			} else {
				args ~= eval("NL,)");
			}
		}

		this.next();
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
						this.defaults ~= this.eval("NL,)");

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
		string id = this.tok.value;
		this.next();

		if (this.tok.type == "="){
			this.next();

			Node expr = this.eval("NL;");
			this.ast ~= new VarNode(id, expr);

		} else if (find(".([", this.tok.type).length) {
			this.prev();
			this.ast ~= this.eval("NL;");
			this.next();

		} else if (find("NL;", this.tok.type).length){
			this.next();

		} else if (find("AA", this.tok.type).length){
			this.prev();
			Node Val = new IdNode(this.tok.value, this.tok.line, this.tok.loc);
			this.next();

			string op = this.tok.value;
			this.next();

			Node expr = this.eval("NL;");
			this.ast ~= new VarNode(id, new BinaryNode(Val, op, expr));

		} else {
			this.SyntaxError("Unexpected syntax '" ~ this.tok.value ~ "' after ID token.");
		}
	}

	void parse_function(){
		this.next();
		string name = this.tok.value;
		this.next();
		this.ast ~= new FunctionNode(name, this.getParams(), this.defaults, new _Parse(this.getCode(), this.file).ast);
	}

	void parse_class(){
		this.next();
		Node[] args;

		if (this.tok.type != "ID")
			this.SyntaxError("Expected an ID for ClassName not '" ~ this.tok.value ~ "'.");

		string name = this.tok.value;
		this.next();

		if (this.tok.type == "("){
			args = this.getArgs();
		}

		this.ast ~= new ClassNode(
				name, args, new _Parse(this.getCode(), this.file).ast);
	}

	void parse_return(){
		this.next();

		if (this.end && !find("NL;", this.tok.type).length)
			this.ast ~= new ReturnNode(this.eval("NL;"));
		else
			this.ast ~= new ReturnNode(new NullNode());

		this.next();
	}

	void parse_if(){
		bool repeat = false;
		Node expr;
		Node[] statements;

		while (this.end){
			if (find("ELIFELSE", this.tok.type).length){
				if (this.tok.type == "ELSE"){
					expr = new NumberNode(1);
					this.next();

				} else {
					if (this.tok.type == "IF" && repeat){
						break;
					}
					this.next();
					expr = this.eval("NL{:");
				}

				statements ~= new IfNode(expr,
					new _Parse(this.getCode(), this.file).ast);
				repeat = true;

			} else if (this.tok.type == "NL"){
				this.next();

			} else {
				break;
			}
		}

		this.ast ~= new IfStatementNode(statements);
	}

	void parse_while(){
		this.next();
		this.ast ~= new WhileNode(this.eval("NL{:"), new _Parse(this.getCode(), this.file).ast);
	}

	void parse_for(){
		this.next();

		if(this.tok.type != "ID")
			this.SyntaxError("Expected an ID after 'for' not '"~this.tok.value~"'.");

		string id = this.tok.value;
		this.next();

		if (this.tok.type != "IN")
			this.SyntaxError("'for' expected 'in' not '" ~ this.tok.value ~"' after ID.");

		this.next();
		this.ast ~= new ForNode(id, this.eval("NL{:"), new _Parse(this.getCode(), this.file).ast);
	}

	void parse_switch(){
		this.next();
		bool bk = false;
		bool brk = false;
		Node key = this.eval("NL:{ARR");
		Node[] cs;
		Node[] case_toks;
		Node value;
		TOKEN[] toks;

		if (this.tok.type == "ARR"){
			this.next();

			if (this.tok.type == "BREAK"){
				bk = true;
				this.next();

			} else
				this.SyntaxError("Expected only the 'break' token.");
		}

		if (find("NL:{", this.tok.type).length){
			this.next();
		}

		while (this.end){
			if (find("CASE DF", this.tok.type).length){
				if (this.tok.type == "CASE"){
					this.next();
					value = this.eval("NL:{");

				} else {
					this.next();
					value = key;
				}


				toks = this.getCode();
				case_toks = new _Parse(toks, this.file).ast;

				if (bk){
					cs ~= new CsNode(value, case_toks, true);
				} else {
					foreach(TOKEN i; toks.reverse){
						if (i.type != "NL"){
							if (i.type == "BREAK"){
								brk = true;
							}
							break;
						}
					}
					cs ~= new CsNode(value, case_toks, brk);
					brk = false;					
				}

			} else if(this.tok.type != "NL"){
				break;

			} else {
				this.next();
			}
		}

		this.ast ~= new SwNode(key, cs);
	}

	void parse_include(){
		this.next();
		this.ast ~= new IncludeNode(this.eval("NL;"), this.tok.line, this.tok.loc);
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

	void parse(){
		while (this.end){
			if (this.tok.type == "ID"){
				this.parse_identifier();

			} else if (this.tok.type == "RET") {
				this.parse_return();

			} else if (this.tok.type == "IF") {
				this.parse_if();

			} else if (this.tok.type == "SWITCH"){
				this.parse_switch();

			} else if (this.tok.type == "WHILE") {
				this.parse_while();

			} else if(this.tok.type == "FOR"){
				this.parse_for();

			} else if (this.tok.type == "BREAK") {
				this.ast ~= new BreakNode();
				this.next();

			} else if (this.tok.type == "CONT") {
				this.ast ~= new ContinueNode();
				this.next();

			} else if (this.tok.type == "FN") {
				this.parse_function();

			} else if (this.tok.type == "CL"){
				this.parse_class();

			} else if (this.tok.type == "IM") {
				this.parse_import();

			} else if (this.tok.type == "FR") {
				this.parse_import();

			} else if (this.tok.type == "INC") {
				this.parse_include();

			} else if (this.tok.type == "TRY") {
				this.parse_try();

			} else {
				this.next();
			}
		}
	}
}


