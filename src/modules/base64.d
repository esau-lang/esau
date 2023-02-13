module lBase64;

import std.conv;
import std.format: format;
import std.algorithm.iteration: each;
import std.algorithm.searching: find;
import std.array: replicate;
import std.range: chunks;

import LdObject;



class oBase64: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "encode64": new Encode64(),
            "decode64": new Decode64(),
            "alphabet64": new LdStr("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"),
            
            "encode32": new Encode32(),
            "decode32": new Decode32(),
            "alphabet32": new LdStr("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"),
        ];
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__() {
        return "base64 (native module)";
    }
}


// =============================== ENCODING TO BASE64 ================================
char[string] _EncodeMap;
int[] _Map;

// maps 64bit binary to a Letter.
static char[string] _MapBase64(char y='+', char z='/')
{
    return [
        "000000":'A', "000001":'B', "000010":'C', "000011":'D', "000100":'E',

        "000101":'F', "000110":'G', "000111":'H', "001000":'I', "001001":'J',

        "001010":'K', "001011":'L', "001100":'M', "001101":'N', "001110":'O',

        "001111":'P', "010000":'Q', "010001":'R', "010010":'S', "010011":'T',

        "010100":'U', "010101":'V', "010110":'W', "010111":'X', "011000":'Y',

        "011001":'Z', "011010":'a', "011011":'b', "011100":'c', "011101":'d',

        "011110":'e', "011111":'f', "100000":'g', "100001":'h', "100010":'i',

        "100011":'j', "100100":'k', "100101":'l', "100110":'m', "100111":'n',

        "101000":'o', "101001":'p', "101010":'q', "101011":'r', "101100":'s',

        "101101":'t', "101110":'u', "101111":'v', "110000":'w', "110001":'x',

        "110010":'y', "110011":'z', "110100":'0', "110101":'1', "110110":'2',

        "110111":'3', "111000":'4', "111001":'5', "111010":'6', "111011":'7',

        "111100":'8', "111101":'9', "111110": y, "111111": z,
    ];
}

// grows string to 8bits if less
static string _to_8_(string x){
    return replicate("0", 8-x.length)~x;
}

// adds == if needed
static string Padding(int x){
    return [0:"", 2:"=", 4:"=="][x];
}

// replaces + and / in _EncodeMap
static void SetPlus(string x)
{
    switch (x.length){
        case 1:
            _EncodeMap = _MapBase64(x[0]);
            break;
        case 2:
            _EncodeMap = _MapBase64(x[0], x[1]);
            break;
        case 0:
            _EncodeMap = _MapBase64();
            break;
        default:
            _EncodeMap = _MapBase64(x[0], x[1]);
            break;
    }
    _Map.length = 1;
}

// encodig to base64
class Encode64: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 1)
            SetPlus(args[1].__str__);

        else if (!_Map.length) {
            _EncodeMap = _MapBase64();
            _Map.length = 1;
        }

        string X, Y, Z;
        int P;

        (cast(ubyte[])args[0].__chars__).each!(n => Z ~= _to_8_(format("%b", n)));

        foreach(i; chunks(Z, 6)){
            X = to!string(i);

            if (X.length < 6) {
                P = cast(int)(6-X.length);
                X ~= replicate("0", P);
            }

            Y~=_EncodeMap[X];
        }

        return new LdStr(Y~Padding(P));
    }

    override string __str__() { return "encode64 (base64 method)"; }
}


// ========================= DECODING BASE64 ================================================
string[char] _DecodeMap;
int[] _Dmap;


// deccding map
static string[char] _dBM(char x='+', char y='/')
{
    return [
        'A':"000000", 'B':"000001", 'C':"000010", 'D':"000011", 'E':"000100",

        'F':"000101", 'G':"000110", 'H':"000111", 'I':"001000", 'J':"001001",

        'K':"001010", 'L':"001011", 'M':"001100", 'N':"001101", 'O':"001110",

        'P':"001111", 'Q':"010000", 'R':"010001", 'S':"010010", 'T':"010011",

        'U':"010100", 'V':"010101", 'W':"010110", 'X':"010111", 'Y':"011000",

        'Z':"011001", 'a':"011010", 'b':"011011", 'c':"011100", 'd':"011101",

        'e':"011110", 'f':"011111", 'g':"100000", 'h':"100001", 'i':"100010",

        'j':"100011", 'k':"100100", 'l':"100101", 'm':"100110", 'n':"100111",

        'o':"101000", 'p':"101001", 'q':"101010", 'r':"101011", 's':"101100",

        't':"101101", 'u':"101110", 'v':"101111", 'w':"110000", 'x':"110001",

        'y':"110010", 'z':"110011", '0':"110100", '1':"110101", '2':"110110",

        '3':"110111", '4':"111000", '5':"111001", '6':"111010", '7':"111011",

        '8':"111100", '9':"111101", x:"111110", y: "111111",
    ];
}

// replaces + and / in _DecodeMap
static void decodeSetPlus(string x)
{
    switch (x.length){
        case 1:
            _DecodeMap = _dBM(x[0]);
            break;
        case 2:
            _DecodeMap = _dBM(x[0], x[1]);
            break;
        case 0:
            _DecodeMap = _dBM();
            break;
        default:
            _DecodeMap = _dBM(x[0], x[1]);
            break;
    }
    _Dmap.length = 1;
}


immutable string alp = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


// if a valid 64 char
string is64Char(char x, ref int eq)
{
    if(find(alp, x).length)
        return _dBM[x];
    else if (x == '=')
        eq++;
    else
        assert(false, format("'%c' is not a valid base64 character.", x));
    
    return "";
}


// converts binary to decimal
static ubyte binaryToDecimal(string b)
{
    int dec; 
    int base = 1;

    for (int i = cast(int)b.length-1;  i > -1; i--) {
        if (b[i] == '1')
            dec += base;
        base = base * 2;
    }
 
    return cast(ubyte)dec;
}


class Decode64: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if(args.length > 1)
            decodeSetPlus(args[1].__str__);

        else if (!_Dmap.length) {
            _DecodeMap = _dBM();
            _Dmap.length = 1;
        }

        string X;
        int pad;

        (args[0].__str__).each!(i => X ~= is64Char(i, pad));

        X = X[0..X.length-pad * 2];

        ubyte[] Y;
        chunks(X, 8).each!(i => Y ~= binaryToDecimal(to!string(i)));

        return new LdChr(cast(char[])Y);
    }

    override string __str__() { return "decode64 (base64 method)"; }
}



// %%%%%%%%%%%%%%%%%%%%%%%%%%%% BASE32 %%%%%%%%% BASE32 %%%%%%%%% BASE32 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// =============================== ENCODING TO BASE64 ================================
char[string] _EncodeMap32;
int[] _Map32;

// maps 64bit binary to a Letter.
static char[string] _MapBase32()
{
    return [
        "00000":'A', "00001":'B', "00010":'C', "00011":'D', "00100":'E',

        "00101":'F', "00110":'G', "00111":'H', "01000":'I', "01001":'J',

        "01010":'K', "01011":'L', "01100":'M', "01101":'N', "01110":'O',

        "01111":'P', "10000":'Q', "10001":'R', "10010":'S', "10011":'T',

        "10100":'U', "10101":'V', "10110":'W', "10111":'X', "11000":'Y',

        "11001":'Z', "11010":'2', "11011":'3', "11100":'4', "11101":'5',

        "11110":'6', "11111":'7'
    ];
}


// adds padding
static void Padding32(ref string d){
    switch (d.length % 8){
        case 2:
            d~="======";
            break;
        case 4:
            d~="====";
            break;
        case 5:
            d~="===";
            break;
        case 7:
            d~="=";
            break;
        default:
            break;
    }
}


import std.stdio;

// encodig to base64
class Encode32: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if (!_Map32.length) {
            _EncodeMap32 = _MapBase32();
            _Map32.length = 1;
        }

        string X, Y, Z;

        (cast(ubyte[])args[0].__chars__).each!(n => Z ~= _to_8_(format("%b", n)));

        foreach(i; chunks(Z, 5)){
            X = to!string(i);

            if (X.length < 5)
                X ~= replicate("0", 5-X.length);

            Y~=_EncodeMap32[X];
        }

        Padding32(Y);
        return new LdStr(Y);
    }

    override string __str__() { return "encode32 (base64 method)"; }
}



// ========================= DECODING BASE32 ================================================

string[char] _DecodeMap32;
int[] _Dmap32;


// deccding map
static string[char] _dBM32()
{
    return [
        'A':"00000", 'B':"00001", 'C':"00010", 'D':"00011", 'E':"00100",

        'F':"00101", 'G':"00110", 'H':"00111", 'I':"01000", 'J':"01001",

        'K':"01010", 'L':"01011", 'M':"01100", 'N':"01101", 'O':"01110",

        'P':"01111", 'Q':"10000", 'R':"10001", 'S':"10010", 'T':"10011",

        'U':"10100", 'V':"10101", 'W':"10110", 'X':"10111", 'Y':"11000",

        'Z':"11001", '2':"11010", '3':"11011", '4':"11100", '5':"11101",

        '6':"11110", '7':"11111"
    ];
}


immutable string alp32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";


// if a valid 32 char
string is32Char(char x, ref int eq)
{
    if(find(alp32, x).length)
        return _dBM32[x];
    else if (x == '=')
        eq++;
    else
        assert(false, format("'%c' is not a valid base32 character.", x));
    
    return "";
}


class Decode32: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if (!_Dmap.length) {
            _DecodeMap32 = _dBM32();
            _Dmap32.length = 1;
        }

        string X;
        int pad;

        (args[0].__str__).each!(i => X ~= is32Char(i, pad));

        ubyte[] Y;
        chunks(X, 8).each!(i => Y ~= binaryToDecimal(to!string(i)));

        return new LdChr(cast(char[])Y);
    }

    override string __str__() { return "decode32 (base64 method)"; }
}



