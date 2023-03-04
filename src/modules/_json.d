module lJson;

import std.stdio;
import std.json;

import LdObject;



class oJson: LdOBJECT
{
    LdOBJECT[string] props;

    this(){
        this.props = [
            "parse": new _Parse(),
            "stringify": new _Stringify(),
        ];
    }

    override LdOBJECT[string] __props__(){ return props; }

    override string __str__() { return "json (native module)"; }
}


LdOBJECT parse_array_json(JSONValue js){
    LdOBJECT[] list;

    foreach(i; js.array)
        list ~= parse_json(i);

    return new LdArr(list);
}

LdOBJECT parse_object_json(JSONValue js){
    LdOBJECT[string] hs;

    foreach(i, v; js.object)
        hs[i] = parse_json(v);

    return new LdHsh(hs);
}

LdOBJECT parse_json(JSONValue js){
    switch (js.type){
        case JSONType.string:
            return new LdStr(js.str);

        case JSONType.integer:
            return new LdNum(js.integer);

        case JSONType.uinteger:
            return new LdNum(js.uinteger);

        case JSONType.float_:
            return new LdNum(js.floating);

        case JSONType.true_:
            return RETURN.B;

        case JSONType.false_:
            return RETURN.C;

        case JSONType.null_:
            return RETURN.A;

        case JSONType.array:
            return parse_array_json(js);

        case JSONType.object:
            return parse_object_json(js);

        default:
            return RETURN.A;
    }
}


class _Parse: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args) {
        JSONValue js = parseJSON(args[0].__str__);
        return parse_json(js);
    }

    override string __str__() { return "json.parse (method)"; }
}


JSONValue get_list_json(LdOBJECT dt) {
    JSONValue[] h;

    foreach(i; *(dt.__ptr__))
        h ~= sort_cat(i);

    return JSONValue(h);
}

JSONValue get_dict_json(LdOBJECT dt) {
    JSONValue dict;

    foreach(k, v; dt.__hash__)
        dict[k] = sort_cat(v);

    return dict;
}

JSONValue sort_cat(LdOBJECT dt) {
    JSONValue js;
    
    switch (dt.__type__) {
        case "string":
            js = JSONValue(dt.__str__);
            break;
        case "number":
            js = JSONValue(dt.__num__);
            break;
        case "list":
            js = get_list_json(dt);
            break;
        case "dict":
            js = get_dict_json(dt);
            break;
        case "null":
            js = JSONValue(null);
            break;
        default:
            js = JSONValue(dt.__str__);
            break;
    }

    return js;
}


class _Stringify: LdOBJECT {
    override LdOBJECT opCall(LdOBJECT[] args) {
        const JSONValue js = sort_cat(args[0]);

        if (args.length > 1 && args[1].__true__)
            return new LdStr(toJSON(js, true));
        
        return new LdStr(toJSON(js));
    }

    override string __str__() { return "json.stringify (method)"; }
}
