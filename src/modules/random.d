module lRandom;


import std.random: randomShuffle, uniform, randomSample, choice;
import std.algorithm.iteration: each;

import LdObject;


alias LdOBJECT[string] Heap;


class oRandom: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"shuffle": new _Shuffle(),
			"sample": new _Sample(),

			"random": new _Random(),
			"uniform": new _Uniform(),

			"integer": new _RandInt(),
			"bool": new _Bool(),

			"pick": new _Pick(),

			"string": new _String(),
			"string_pool": new _Pool(),

            "__docs__": new LdStr("Provides an API to generates random\n * numbers\n * strings\n * and shuffling arrays\n\nThis unit is not that secure for things such as\ncryptographically, tokens and network sequence numbers."),
		];
	}

	override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "random (native module)"; }
}


class _Pool: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        string str;
    	string pool = args[0].__str__;

        for(ulong i = 0; i < args[1].__num__; i++)
            str ~= pool[uniform(0, pool.length)];

        return new LdStr(str);
    }

    override string __str__() { return "random.string (method)"; }
}

class _String: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	string str;
        string pick = "kyKSegYpwanMfLvmtNq82B6Z4AxblJDV17Woj0h3I9CQrcEPuzHGFdTOUiX5sR";

        if(args.length > 1)
            pick = args[1].__str__ ~ pick; 

        for(int i = 0; i < args[0].__num__; i++)
            str ~= pick[uniform(0, pick.length)];

        return new LdStr(str);
    }

    override string __str__() { return "random.string (method)"; }
}

class _Pick: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	return choice(args[0].__array__);
    }

    override string __str__() { return "random.pick (method)"; }
}

class _Bool: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if ([true, false][cast(int)(uniform(0, 2))])
            return new LdTrue();

        return new LdFalse();
    }

    override string __str__() { return "random.bool (method)"; }
}

class _RandInt: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if (args.length > 1)
            return new LdNum(cast(int)(uniform(args[0].__num__, args[1].__num__)));
        
        return new LdNum(cast(int)(uniform(0, args[0].__num__)));
    }

    override string __str__() { return "random.integer (method)"; }
}

class _Sample: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
    	LdOBJECT[] arr;

    	randomSample(randomShuffle(args[0].__array__.dup), cast(int)args[1].__num__).each!(i => arr ~= i);

        return new LdArr(arr);
    }

    override string __str__() { return "random.sample (method)"; }
}

class _Shuffle: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        randomShuffle(args[0].__array__);
        return new LdNone();
    }

    override string __str__() { return "random.shuffle (method)"; }
}

class _Random: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(uniform(0.0000000001, 1));
    }

    override string __str__() { return "random.random (method)"; }
}

class _Uniform: LdOBJECT 
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(uniform(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "random.uniform (method)"; }
}
