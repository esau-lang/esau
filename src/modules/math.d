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

    override string __str__() { return "math.ldexp (method)"; }
}

class Modf: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        double x = args[1].__num__;
        return new LdNum(modf(args[0].__num__, &x));
    }

    override string __str__() { return "math.modf (method)"; }
}

class Hypot: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(hypot(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "math.hypot (method)"; }
}

class Frexp: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        int x = cast(int)args[1].__num__;
        return new LdNum(frexp(args[0].__num__, &x));
    }

    override string __str__() { return "math.frexp (method)"; }
}

class Fmod: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(fmod(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "math.fmod (method)"; }
}

class Expm1: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(expm1(args[0].__num__));
    }

    override string __str__() { return "math.expm1 (method)"; }
}

class Erf: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(erf(args[0].__num__));
    }

    override string __str__() { return "math.erf (method)"; }
}

class Erfc: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(erfc(args[0].__num__));
    }

    override string __str__() { return "math.erfc (method)"; }
}

class Copysign: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(copysign(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "math.copysign (method)"; }
}

class Trunc: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(trunc(args[0].__num__));
    }

    override string __str__() { return "math.trunc (method)"; }
}

class Lgamma: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(lgamma(args[0].__num__));
    }

    override string __str__() { return "math.lgamma (method)"; }
}

class Exp: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(exp(args[0].__num__));
    }

    override string __str__() { return "math.exp (method)"; }
}

class Remainder: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(remainder(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "math.remainder (method)"; }
}

class Log1p: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log1p(args[0].__num__));
    }

    override string __str__() { return "math.log1p (method)"; }
}

class Log2: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log2(args[0].__num__));
    }

    override string __str__() { return "math.log2 (method)"; }
}

class Log10: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log10(args[0].__num__));
    }

    override string __str__() { return "math.log10 (method)"; }
}

class Log: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(log(args[0].__num__));
    }

    override string __str__() { return "math.log (method)"; }
}

class Fabs: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(fabs(args[0].__num__));
    }

    override string __str__() { return "math.fabs (method)"; }
}

class Pow: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(pow(args[0].__num__, args[1].__num__));
    }

    override string __str__() { return "math.pow (method)"; }
}

class Floor: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(floor(args[0].__num__));
    }

    override string __str__() { return "math.floor (method)"; }
}

class Ceil: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(ceil(args[0].__num__));
    }

    override string __str__() { return "math.ceil (method)"; }
}

class Sqrt: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sqrt(args[0].__num__));
    }

    override string __str__() { return "math.sqrt (method)"; }
}

class Cos: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(cos(args[0].__num__));
    }

    override string __str__() { return "math.cos (method)"; }
}

class CosH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(cosh(args[0].__num__));
    }

    override string __str__() { return "math.cosh (method)"; }
}

class Acos: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(acos(args[0].__num__));
    }

    override string __str__() { return "math.acos (method)"; }
}

class AcosH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(acosh(args[0].__num__));
    }

    override string __str__() { return "math.acosh (method)"; }
}

class Sin: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sin(args[0].__num__));
    }

    override string __str__() { return "math.sin (method)"; }
}

class SinH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(sinh(args[0].__num__));
    }

    override string __str__() { return "math.sinh (method)"; }
}

class Asin: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(asin(args[0].__num__));
    }

    override string __str__() { return "math.asin (method)"; }
}

class AsinH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(asinh(args[0].__num__));
    }

    override string __str__() { return "math.asinh (method)"; }
}

class Tan: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(tan(args[0].__num__));
    }

    override string __str__() { return "math.tan (method)"; }
}

class TanH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(tanh(args[0].__num__));
    }

    override string __str__() { return "math.tanh (method)"; }
}

class Atan: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(atan(args[0].__num__));
    }

    override string __str__() { return "math.atan (method)"; }
}

class AtanH: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(atanh(args[0].__num__));
    }

    override string __str__() { return "math.atanh (method)"; }
}