module lMath;

import core.stdc.math;

import LdObject;



class oMath: LdOBJECT {
	LdOBJECT[string] props;

	this(){
		this.props = [
            "cos": new Cos(),
            "acos": new Acos(),
            "cosh": new CosH(),
			"acosh": new AcosH(),

            "sin": new Sin(),
            "asin": new Asin(),
            "sinh": new SinH(),
            "asinh": new AsinH(),

            "log": new Log(),
            "log2": new Log2(),
            "log1p": new Log1p(),
            "log10": new Log10(),

            "tan": new Tan(),
            "atan": new Atan(),
            "tanh": new TanH(),
            "atanh": new AtanH(),

            "erf": new Erf(),
            "erfc": new Erfc(),

            "exp": new Exp(),
            "expm1": new Expm1(),
            "fabs": new Fabs(),
            "fmod": new Fmod(),

            "modf": new Modf(),
            "hypot": new Hypot(),
            "ldexp": new Ldexp(),


            "pow": new Pow(),
            "sqrt": new Sqrt(),
            "ceil": new Ceil(),
            "floor": new Floor(),

            "trunc": new Trunc(),
            "lgamma": new Lgamma(),
            "remainder": new Remainder(),
            "copysign": new Copysign(),

		];
	}

    override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){
		return "math (native module)";
	}
}


class Ldexp: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(ldexp(args[0].__num__, cast(int)args[1].__num__));
    }

    override string __str__() { return "ldexp (math method)"; }
}

class Modf: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        double x = args[1].__num__;
        return new LdNum(modf(args[0].__num__, &x));
    }

    override string __str__() { return "modf (math method)"; }
}

class Hypot: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(hypot(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "hypot (math method)"; }
}

class Frexp: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        int x = cast(int)args[1].__num__;
        return new LdNum(frexp(args[0].__num__, &x));
    }

    override string __str__() { return "frexp (math method)"; }
}

class Fmod: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(fmod(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "fmod (math method)"; }
}

class Expm1: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(expm1(args[0].__num__));
    }

    override string __str__() { return "expm1 (math method)"; }
}

class Erf: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(erf(args[0].__num__));
    }

    override string __str__() { return "erf (math method)"; }
}

class Erfc: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(erfc(args[0].__num__));
    }

    override string __str__() { return "erfc (math method)"; }
}

class Copysign: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(copysign(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "copysign (math method)"; }
}

class Trunc: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(trunc(args[0].__num__));
    }

    override string __str__() { return "trunc (math method)"; }
}

class Lgamma: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(lgamma(args[0].__num__));
    }

    override string __str__() { return "lgamma (math method)"; }
}

class Exp: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(exp(args[0].__num__));
    }

    override string __str__() { return "exp (math method)"; }
}

class Remainder: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(remainder(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "remainder (math method)"; }
}

class Log1p: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log1p(args[0].__num__));
    }

    override string __str__() { return "log1p (math method)"; }
}

class Log2: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log2(args[0].__num__));
    }

    override string __str__() { return "log2 (math method)"; }
}

class Log10: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log10(args[0].__num__));
    }

    override string __str__() { return "log10 (math method)"; }
}

class Log: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log(args[0].__num__));
    }

    override string __str__() { return "log (math method)"; }
}

class Fabs: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(fabs(args[0].__num__));
    }

    override string __str__() { return "fabs (math method)"; }
}

class Pow: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(pow(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "pow (math method)"; }
}

class Floor: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(floor(args[0].__num__));
    }

    override string __str__() { return "floor (math method)"; }
}

class Ceil: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(ceil(args[0].__num__));
    }

    override string __str__() { return "ceil (math method)"; }
}

class Sqrt: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sqrt(args[0].__num__));
    }

    override string __str__() { return "sqrt (math method)"; }
}

class Cos: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(cos(args[0].__num__));
    }

    override string __str__() { return "cos (math method)"; }
}

class CosH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(cosh(args[0].__num__));
    }

    override string __str__() { return "cosh (math method)"; }
}

class Acos: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(acos(args[0].__num__));
    }

    override string __str__() { return "acos (math method)"; }
}

class AcosH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(acosh(args[0].__num__));
    }

    override string __str__() { return "acosh (math method)"; }
}

class Sin: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sin(args[0].__num__));
    }

    override string __str__() { return "sin (math method)"; }
}

class SinH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sinh(args[0].__num__));
    }

    override string __str__() { return "sinh (math method)"; }
}

class Asin: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(asin(args[0].__num__));
    }

    override string __str__() { return "asin (math method)"; }
}

class AsinH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(asinh(args[0].__num__));
    }

    override string __str__() { return "asinh (math method)"; }
}

class Tan: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(tan(args[0].__num__));
    }

    override string __str__() { return "tan (math method)"; }
}

class TanH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(tanh(args[0].__num__));
    }

    override string __str__() { return "tanh (math method)"; }
}

class Atan: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(atan(args[0].__num__));
    }

    override string __str__() { return "atan (math method)"; }
}

class AtanH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(atanh(args[0].__num__));
    }

    override string __str__() { return "atanh (math method)"; }
}