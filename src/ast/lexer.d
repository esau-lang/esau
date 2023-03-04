module LdLexer;

import std.uni;
import std.conv: to;
import std.range;
import std.stdio;
import std.array;
import std.digest;
import std.algorithm;
import std.typecons;

import LdNode: TOKEN;


string letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$";
string keys =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$?!1234567890";
string numbers = "1234567890";
string numbs = "1234567890e.x_";
string meters = "?;,({[]}):.";
string expr = "=!<>";
string aliases = "&|";
string operators = "+-*/%";

enum escaped_keys = ['r':'\r', 't':'\t', 'n':'\n', 'b':'\b', '\\':'\\', '0':'\0', 'a':'\a', 'f':'\f', 'v':'\v', '\'':'\'', '"': '\"', '`':'`', '?': '\?'];


class _Lex{
	int pos, line, tab, loc;
	TOKEN[] TOKENS;

	string code;
	char tok;
	bool end;

	this(string code){
		this.code = code;
		this.pos = -1;

		this.tok = tok;
		this.loc = -1;
		
		this.line = 1;
		this.end = true;

		this.next();
		this.parse();
	}

	void next(){
		this.pos += 1;
		this.loc += 1;

		if (this.pos < this.code.length)
			this.tok = this.code[this.pos];
		else
			this.end = false;
	}

	void back(){
		this.pos -= 1;
		this.loc -= 1;

		this.tok = this.code[this.pos];
	}

	void rString(){
		char quot = tok;
		string str;
		next();

		while (end && tok != quot){
			str ~= tok;
			next();
		}
		next();

		TOKEN N = {str, "STR", tab, line, loc};
		TOKENS ~= N;
	}

	void lex_keywords(){
		string key, _type;

		while (this.end && find(keys, this.tok).length){
			key ~= this.tok;
			this.next();
		}

		this.loc-=1;

		switch (key){
			case "if":
				_type = "IF"; break;
			case "else":
				_type = "ELSE"; break;
			case "elif":
				_type = "ELIF"; break;
			case "in":
				_type = "IN"; break;
			case "return":
				_type = "RET"; break;
			case "true":
				_type = "TRUE"; break;
			case "false":
				_type = "FALSE"; break;
			case "none":
				_type = "NONE"; break;
			case "while":
				_type = "WHILE"; break;
			case "for":
				_type = "FOR"; break;
			case "switch":
				_type = "SWITCH"; break;
			case "case":
				_type = "CASE"; break;
			case "break":
				_type = "BREAK"; break;
			case "default":
				_type = "DF"; break;
			case "pass":
				_type = "PS"; break;
			case "try":
				_type = "TRY"; break;
			case "except":
				_type = "CATCH"; break;
			case "function": case "fn":
				_type = "FN"; break;
			case "and":
				_type = "AND"; break;
			case "or":
				_type = "OR"; break;
			case "not":
				_type = "NOT"; break;
			case "import":
				_type = "IM"; break;
			case "include":
				_type = "INC"; break;
			case "continue":
				_type = "CONT"; break;
			case "from":
				_type = "FR"; break;
			case "as":
				_type = "AS"; break;
			case "class":
				_type = "CL"; break;
			case "let":
				return;
			default:
				if (key == "r" && find("'\"", this.tok).length) {
					this.rString();
					return;
				}

				if (key == "f" && find("'\"", this.tok).length){
					key = this.lex_string;
					_type = "FMT";
				
				} else
					_type = "ID";

				break;
		}
		
		TOKEN N = {key, _type, tab, line, loc};
		TOKENS ~= N;

		this.loc += 1;
	}

	void lex_operators(){
		string OP;
		OP ~= this.tok;
		
		this.next();

		if (this.tok == '='){
			TOKEN N = {OP, "AA", tab, line, loc};
			TOKENS ~= N;

			this.next();

		} else if (tok == '/') {
			while (end && tok != '\n')
				next;

			next();
			
		} else {
			TOKEN N = {OP, 	OP, tab, line, loc-1};
			TOKENS ~= N;
		}
	}

	void lex_meters(){
		string _dm;  _dm ~= tok;

		TOKEN N = {_dm, _dm, tab, line, loc};
		TOKENS ~= N;

		this.next();
	}

	void lex_expr(){
		string _op;  _op ~= tok;
		this.next();

		if (tok == '='){
			this.next();

			TOKEN N = {_op~'=', _op~'=', tab, line, loc};
			TOKENS ~= N;

		} else if (_op == "!") {
			TOKEN N = {_op, "NOT", tab, line, loc};
			TOKENS ~= N;

		} else {
			TOKEN N = {_op, _op, tab, line, loc};
			TOKENS ~= N;
		}
	}

	string get_hexidecimal(){
		this.next();
		string hex;

		while (this.end && find("0123456789abcdefABCDEF", this.tok).length){
			hex ~= this.tok;
			this.next();
		}

		this.back();
		return to!string(to!long(hex, 16));
	}

	string get_exp_num(){
		this.next();

		string Exp;
		string zeros;

		while (this.end && find("0123456789", this.tok).length){
			Exp ~= this.tok;
			this.next();
		}

		for(int i = 0; i < to!int(Exp); i++)
			zeros ~= "0";

		return zeros;
	}

	void pass(){}

	void lex_number() {
		string num;

		while (end && find(numbs, tok).length){
			if (this.tok == '_')
				pass;

			else if (this.tok == 'x')
				num = get_hexidecimal();

			else if (this.tok == 'e')
				num ~= get_exp_num();

			else
				num ~= tok;
			
			next();
		}

		TOKEN N = {num, "NUM", tab, line, loc};
		TOKENS ~= N;
	}

	void Aliases(){
		string op;  op ~= tok;
		this.next();

		if (find("&|", tok).length){
			op ~= tok;
			next();
		}

		string _type = "OR";

		if (op == "&&")
			_type = "AND";

		TOKEN N = {op, _type, tab, line, loc};
		TOKENS ~= N;
	}

	string get_hex_unicode(){
		string hex;

		while (hex.length < 2) {
			this.next();
			hex ~= this.tok;
		}

		return to!string(chunks(hex, 2).map!(i => cast(dchar)i.to!ubyte(16)).array);
	}

	string get_escaped(){
		next();
		string str;

		if (end) {
			if (find("rtnb0afv?\\'\"", tok).length)
				str ~= escaped_keys[tok];

			else if (tok == 'x')
				str = get_hex_unicode();
		}
		return str;
	}

	string lex_string(){
		char key;
		char quot = this.tok;
		string str, chars;
		this.next();

		while (end && tok != quot && tok){
			if (this.tok == '\\')
				str ~= get_escaped();
			else 
				str ~= this.tok;
			
			this.next();
		}

		this.next();
		return str;
	}

	void skip_char(){
		next();
		next();

		while(end && find(" \t", tok).length){
			if (tok == '\t')
				this.tab += 1;

			next();
		}

		if(tok == '\n')
			next();
	}

	void newline_char(){
		TOKEN N = {"", "NL", tab, line, loc};
		TOKENS ~= N;

		this.tab = 0;
		this.loc = -1;
		
		this.next();
		this.line += 1;
	}

	void hash_comment(){
		this.next();

		while (this.end && this.tok != '\n')
			this.next();
		
		this.next();
	}

	void spaces_indent(){
		string tabz;

		while (this.end && this.tok == ' '){
			tabz ~= this.tok;
			this.next();

			if (tabz.length == 4){
				tabz = "";
				this.tab += 1;
			}
		}
	}

	void parse(){
		while (this.end){
			if (find(letters, this.tok).length)
				this.lex_keywords();

			else if (find(meters, this.tok).length)
				this.lex_meters();

			else if (find(operators, this.tok).length)
				this.lex_operators();

			else if (find("\"'", this.tok).length){
				this.loc-=1;				
				
				TOKEN N = {lex_string, "STR", tab, line, loc};
				TOKENS ~= N;

				this.loc+=1;

			} else if (find(numbers, this.tok).length)
				this.lex_number();

			else if (this.tok == '\n')
				newline_char();

			else if (this.tok == '\t'){
				this.tab += 1;
				this.next();

			} else if (this.tok == '\\')
				skip_char();

			else if (find("&|", this.tok).length)
				this.Aliases();

			else if (find(expr, this.tok).length)
				this.lex_expr();

			else if (this.tok == '#')
				hash_comment();

			else if (this.tok == ' ')
				spaces_indent();

			else
				this.next();
		}

		if (TOKENS.length > 0){
			TOKEN N = {"", "NL", tab, line, loc};
			TOKENS ~= N;
		}		
	}
}


