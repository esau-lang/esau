module lTime;

import core.thread.osthread: Thread;
import std.format: format;
import std.conv: to;
import std.string: chomp;

import core.time: dur;
import core.stdc.time;

import LdObject;


alias LdOBJECT[string] Heap;


class oTime: LdOBJECT
{
	Heap props;

	this(){
		this.props = [
			"sleep": new _sleep(),

            "time": new _time(),
            "ctime": new _ctime(),

            "mktime": new _mktime(),
            "asctime": new _asctime(),
            "difftime": new _difftime(),

            "gmtime": new _gmtime(),
            "localtime": new _localtime(),

            "clock": new _clock(),
            "CLOCKS_PER_SEC": new LdNum(CLOCKS_PER_SEC)
		];
	}

    override LdOBJECT[string] __props__(){ return props; }

	override string __str__(){ return "time (unit)"; }
}


class _localtime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        time_t localT;
        if (args.length)
            localT = cast(time_t)args[0].__num__;
        else
            localT = time(null);

        tm* info = localtime(&localT);

        return new LdDict(format("tm(tm_year=%d, tm_mon=%d, tm_mday=%d, tm_hour=%d, tm_min=%d, tm_sec=%d, tm_wday=%d, tm_yday=%d, tm_isdst=%d)", info.tm_year, info.tm_mon, info.tm_mday, info.tm_hour, info.tm_min, info.tm_sec, info.tm_wday, info.tm_yday, info.tm_isdst), [
                "tm_year": new LdNum(info.tm_year),
                "tm_mon": new LdNum(info.tm_mon),
                "tm_mday": new LdNum(info.tm_mday),
                "tm_yday": new LdNum(info.tm_yday),
                "tm_wday": new LdNum(info.tm_wday),
                "tm_hour": new LdNum(info.tm_hour),
                "tm_min": new LdNum(info.tm_min),
                "tm_sec": new LdNum(info.tm_sec),
                "tm_isdst": new LdNum(info.tm_isdst),
            ]);
    }

    override string __str__() { return "localtime (time method)"; }
}

class _gmtime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        time_t rw;
        if (args.length)
            rw = cast(time_t)args[0].__num__;
        else
            rw = time(null);

        tm* info;
        info = gmtime(&rw);

        return new LdDict(format("tm(tm_year=%d, tm_mon=%d, tm_mday=%d, tm_hour=%d, tm_min=%d, tm_sec=%d, tm_wday=%d, tm_yday=%d, tm_isdst=%d)", info.tm_year, info.tm_mon, info.tm_mday, info.tm_hour, info.tm_min, info.tm_sec, info.tm_wday, info.tm_yday, info.tm_isdst), [
                "tm_year": new LdNum(info.tm_year),
                "tm_mon": new LdNum(info.tm_mon),
                "tm_mday": new LdNum(info.tm_mday),
                "tm_yday": new LdNum(info.tm_yday),
                "tm_wday": new LdNum(info.tm_wday),
                "tm_hour": new LdNum(info.tm_hour),
                "tm_min": new LdNum(info.tm_min),
                "tm_sec": new LdNum(info.tm_sec),
                "tm_isdst": new LdNum(info.tm_isdst),
            ]);
    }

    override string __str__() { return "gmtime (time method)"; }
}

class _clock: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(clock());
    }

    override string __str__() { return "clock (time method)"; }
}

class _mktime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        if (!args.length)
            throw new Exception("time.mktime expects a type with time data.\nHaving attributes [tm_year, tm_mon, tm_mday, tm_wday, tm_yday, tm_hour, tm_min, tm_sec, tm_isdst]) with num->data.");

        tm st;  // tm* timeptr struct
        long stamp;

        foreach(k, v; args[0].__hash__) {
            switch (k) {
                case "tm_year":
                    st.tm_year = cast(int)v.__num__;
                    break;
                case "tm_mon":
                    st.tm_mon = cast(int)v.__num__;
                    break;
                case "tm_mday":
                    st.tm_mday = cast(int)v.__num__;
                    break;
                case "tm_hour":
                    st.tm_hour = cast(int)v.__num__;
                    break;
                case "tm_min":
                    st.tm_min = cast(int)v.__num__;
                    break;
                case "tm_sec":
                    st.tm_sec = cast(int)v.__num__;
                    break;
                case "tm_wday":
                    st.tm_wday = cast(int)v.__num__;
                    break;
                case "tm_yday":
                    st.tm_yday = cast(int)v.__num__;
                    break;
                case "tm_isdst":
                    st.tm_isdst = cast(int)v.__num__;
                    break;
                default:
                    break;
            }
        }

        stamp = mktime(&st);
       
        if (stamp == -1)
          throw new Exception("time.mktime is unable to make time.\nMethod expects a type with num values and\n  attributes->(tm_year, tm_mon, tm_mday, tm_wday, tm_yday, tm_hour, tm_min, tm_sec, tm_isdst).");

        return new LdNum(stamp);
    }

    override string __str__() { return "mktime (time method)"; }
}

class _asctime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        tm st;  // tm* timeptr struct

        if (args.length) {
            foreach(k, v; args[0].__hash__) {
                switch (k) {
                    case "tm_year":
                        st.tm_year = cast(int)v.__num__;
                        break;
                    case "tm_mon":
                        st.tm_mon = cast(int)v.__num__;
                        break;
                    case "tm_mday":
                        st.tm_mday = cast(int)v.__num__;
                        break;
                    case "tm_hour":
                        st.tm_hour = cast(int)v.__num__;
                        break;
                    case "tm_min":
                        st.tm_min = cast(int)v.__num__;
                        break;
                    case "tm_sec":
                        st.tm_sec = cast(int)v.__num__;
                        break;
                    case "tm_wday":
                        st.tm_wday = cast(int)v.__num__;
                        break;
                    case "tm_yday":
                        st.tm_yday = cast(int)v.__num__;
                        break;
                    case "tm_isdst":
                        st.tm_isdst = cast(int)v.__num__;
                        break;
                    default:
                        break;
                }
            }
        }

        return new LdStr(chomp(to!string(asctime(&st))));       
    }

    override string __str__() { return "asctime (time method)"; }
}


class _difftime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(difftime(cast(time_t)args[0].__num__, cast(time_t)args[1].__num__));
    }

    override string __str__() { return "difftime (time method)"; }
}


class _ctime: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        version(Windows) {
            int tm;

            if(args.length)
                tm = cast(int)args[0].__num__;
            else
                tm = time(null);

            return new LdStr(chomp(to!string(ctime(&tm))));
            
        } else {
            long tm;

            if(args.length)
                tm = cast(long)args[0].__num__;
            else
                tm = time(null);

            return new LdStr(chomp(to!string(ctime(&tm))));
        }
    }

    override string __str__() { return "ctime (time method)"; }
}

class _time: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
        return new LdNum(time(null));
    }

    override string __str__() { return "time (time method)"; }
}

class _sleep: LdOBJECT
{
    override LdOBJECT opCall(LdOBJECT[] args){
       	Thread.getThis().sleep(dur!"msecs"(cast(int)args[0].__num__));
        return new LdNone();
    }

    override string __str__() { return "sleep (time method)"; }
}
