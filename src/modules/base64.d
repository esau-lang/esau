module lBase64;

import std.conv;
import std.format: format;
import std.algorithm.iteration: each;
import std.algorithm.searching: find;
import std.array: replicate;
import std.range: chunks;

import std.base64: Base64;

import LdObject;



class oBase64: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "encode64": new Encode64(),
            "decode64": new Decode64(),
            
            "encode32": new Encode32(),
            "decode32": new Decode32(),
        ];
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__() {
        return "base64 (native module)";
    }
}


class Encode64: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdStr(Base64.encode(cast(ubyte[])(args[0].__chars__)));
    }

    override string __str__() { return "base64.encode64 (method)"; }
}


class Decode64: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdChr(cast(char[])(Base64.decode(args[0].__str__)));
    }

    override string __str__() { return "base64.decode64 (method)"; }
}



// %%%%%%%%%%%%%%%%%%%%%%%%%%%% BASE32 %%%%%%%%% BASE32 %%%%%%%%% BASE32 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// =============================== ENCODING TO BASE64 ================================
char[string] _EncodeMap32;
int[] _Map32;

// grows string to 8bits if less
static string _to_8_(string x){
    return replicate("0", 8-x.length)~x;
}

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
        if (!_Dmap32.length) {
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



