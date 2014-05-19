module JavaShowMethods
export getConstructors, getMethods

using JavaCall
import JavaCall

#jClass = 0
#jConstructor = 0
#jMethod = 0

#function myinit()
#    if jClass == 0
        jClass = @JavaCall.jimport "java.lang.Class"
        jConstructor = @JavaCall.jimport "java.lang.reflect.Constructor"
        jMethod = @JavaCall.jimport "java.lang.reflect.Method"
#    end
#end

replacements=[
 "boolean[][][]" "Array{Int8,3}";
 "boolean[][]" "Array{Int8,2}";
 "boolean[]" "Array{Int8,1}";
 "byte[][][]" "Array{Int8,3}";
 "byte[][]" "Array{Int8,2}";
 "byte[]" "Array{Int8,1}";
 "int[][][]" "Array{Int64,3}";
 "int[][]" "Array{Int64,2}";
 "int[]" "Array{Int64,1}";
 "short[][][]" "Array{Int32,3}";
 "short[][]" "Array{Int32,2}";
 "short[]" "Array{Int32,1}";
 "float[][][]" "Array{Float32,3}";
 "float[][]" "Array{Float32,2}";
 "float[]" "Array{Float32,1}";
 "double[][][]" "Array{Float64,3}";
 "double[][]" "Array{Float64,2}";
 "double[]" "Array{Float64,1}";
 "boolean" "jboolean";
 "int" "jint";
 "short" "jshort";
 "long" "jlong";
 "sizet" "jsize";
 "byte" "jchar";
 "double" "jdouble";
 "float" "jfloat"];

function convertJavaNamesToJulia(ss)
    if isempty(ss)
        return [];
    end
    for i=1:size(ss,1),j=1:size(replacements,1)
        ss[i]=replace(ss[i],replacements[j,1],replacements[j,2])
    end
    return ss
end

# Call static methods
#function mjcall{T}(typ::Type{JavaObject{T}}, method::String, rettype::Type, argtypes::Tuple, args... )
#	try
#		jcall(typ, method, rettype, argtypes, args );
#	catch e
#               getMethods(typ);
#		error(e);
#	end
#end


function getAllMethods(obj::JavaObject, findConstructors::Bool = false, conversion::Bool=true)
#        myinit()
        myClass   = jcall(obj, "getClass", (jClass), (),);
        if findConstructors
            myMethods = jcall(myClass, "getConstructors", (Array{jConstructor,1}), (),);
        else
            myMethods = jcall(myClass, "getMethods", (Array{jMethod,1}), (),);
        end
        s=Array(ASCIIString,size(myMethods,1));
        for i= 1:size(myMethods,1)
                s[i] = jcall(myMethods[i], "toString", (JString), (),);
        end
        return conversion ? convertJavaNamesToJulia(s) : s;
end

# function getAllMethods(obj::JavaObject)
function getAllMethods{T}(typ::Type{JavaObject{T}})
        obj = typ((),)
        return getAllMethods(obj)
end

# Call instance methods
#function mjcall(obj::JavaObject, method::String, rettype::Type, argtypes::Tuple, args... )
#	try
#		jcall(obj, method, rettype, argtypes, args );
#	catch e
#               getMethods(obj);
#		error(e);
#	end
#end


function getMethods(obj::JavaObject, name::ASCIIString = "", conversion::Bool = true, findConstructors::Bool = false)
        allm=getAllMethods(obj,findConstructors,conversion)
        mr=Regex(name)
        ss=allm[find(ms->ismatch(mr,ms),allm)]  # extracts all the methods with the regex in them
        return ss;
end

function getMethods{T}(typ::Type{JavaObject{T}},name::ASCIIString = "", conversion::Bool = true, findConstructors::Bool = false)
        obj = typ((),)
        return getMethods(obj,name,conversion,findConstructors)
end

function getConstructors{T}(typ::Type{JavaObject{T}}, name::ASCIIString = "", conversion::Bool = true)
        return getMethods(typ,name,conversion,true)
end

function getConstructors(obj::JavaObject, name::ASCIIString = "", conversion::Bool = true)
        return getMethods(obj,name,conversion,true)
end


end # module
