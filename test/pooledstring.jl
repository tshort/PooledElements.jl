module TPS

using PooledElements
using Base.Test


##############################################################################
##
## Constructors
##
##############################################################################

a = PooledString()
@test a == "__NA__"

p = Pool()
push!(p, "hello")
a = PooledString(1, p)
@test a == "hello"


##############################################################################
##
## pstring
##
##############################################################################

a = pstring()
@test a == ""
@test isa(a, PooledString{UTF8String,UInt64})

a = pstring("test")
@test a == "test"
@test isa(a, PooledString{UTF8String,UInt64})

a = pstring(Pool(UInt8), 27, "X")
@test a == "27X"
@test isa(a, PooledString{UTF8String,UInt8})

a = pstring("test")
b = pstring(Pool(), "test")
@test a == b

a = pstring("a")
x = [a, pstring("b")]
@test isa(x, Array{typeof(a),1})

# with different pools, concatenation removes pools and just uses strings 
a = pstring("a")
x = [a; pstring(Pool(), "b")]
@test !isa(x, Array{typeof(a),1})
@test isa(x, Array{UTF8String,1})

a = pstring("x", "y", 2)
@test a == "xy2"


##############################################################################
##
## Utilities
##
##############################################################################

a = convert(ASCIIString, pstring("hello"))
@test isa(a, ASCIIString)
@test a == "hello"

@test endof(pstring("hello")) == endof("hello")

@test string(pstring("hello", "world")) == "helloworld"


##############################################################################
##
## NULL
##
##############################################################################

a = pstring("hi")
@test !isnull(a)

a = PooledString()
@test isnull(a)

x = [pstring(1), pstring("a"), PooledString()]
@test !isnull(x, 1)
@test isnull(x, [1,3]) == [false, true]




##############################################################################
##
## PooledStringArray constructors
##
##############################################################################

p = Pool(UInt8)
push!(p, "a", "b", "c")
x = PooledStringArray(UInt8[3,1,1,2], p)
@test length(x) == 4
@test size(x) == (4,)
@test x == ["c","a","a","b"]
@test x != ["c","a","a","a"]

x = PooledStringArray(Pool(UInt8))
@test length(x) == 0
@test isa(x, PooledStringArray{UTF8String,1,UInt8})

x = PooledStringArray(Pool(UInt8), 3)
@test size(x) == (3,)
@test isa(x, PooledStringArray{UTF8String,1,UInt8})

x = PooledStringArray(Pool(UInt8), 3, 2)
@test size(x) == (3,2)
@test isa(x, PooledStringArray{UTF8String,2,UInt8})

x = PooledStringArray(3, 2)
@test size(x) == (3,2)
@test isa(x, PooledStringArray{UTF8String,2,UInt})

x = PooledStringArray([pstring("a"), pstring("b")])
@test size(x) == (2,)
@test isa(x, PooledStringArray{UTF8String,1,UInt})

x = PooledStringArray(UTF8String["a", "b"])
@test size(x) == (2,)
@test isa(x, PooledStringArray{UTF8String,1,UInt})

x = PooledStringArray(["a", "b"])
@test size(x) == (2,)
@test isa(x, PooledStringArray{UTF8String,1,UInt})


##############################################################################
##
## PooledStringArray Base methods
##
##############################################################################

x = PooledStringArray(["a", "b", "c"])
@test x[1] == pstring("a")
@test x[1] == "a"
@test x[end] == "c"
@test size(x[1:2], 1) == 2

x[3] = "d"
@test x[end] == "d"

x[3] = pstring("e")
@test x[end] == "e"

x[3] = PooledString()
@test isnull(x[end])
@test isnull(x, 3)
@test !isnull(x, 1) 
@test isnull(x, [1,3]) == [false, true]

x = PooledStringArray(["a", "b", "c"])
y = PooledStringArray(["a", "d", "e"])
x[3] = PooledString()

x = PooledStringArray(["a"  "b"  "c"
                       "d"  "e"  "f"])
@test size(x) == (2, 3)
y = similar(x)
@test size(x) == size(y)
@test typeof(x) == typeof(y)

x = PooledStringArray(["a"  "b"  "c"
                       "d"  "e"  "f"])
y = similar(x, 2, 5)
@test size(y) == (2, 5)
@test typeof(x) == typeof(y)
z = [x y]
@test size(z) == (2, 8)
@test typeof(x) == typeof(z)

end # module
