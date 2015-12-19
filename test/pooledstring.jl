module TPS

using PooledElements
using Base.Test


##############################################################################
##
## Constructors
##
##############################################################################

a = PooledString()
@test a == "__NULL__"

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

@test pstring("a") < pstring("b")
@test pstring("a") < "b"

a = convert(ASCIIString, pstring("hello"))
@test isa(a, ASCIIString)
@test a == "hello"

@test endof(pstring("hello")) == endof("hello")

@test string(pstring("hello", "world")) == "helloworld"

p = Pool(UInt8, ["x", "y", "z"])
a = pstring(p, "hello")
@test isa(a, PooledString{ASCIIString,UInt8})
@test levels(a) == ["x", "y", "z", "hello"]


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

@test PooledString() == PooledString()     
@test PooledString() == PooledString(0,Pool())   #  different pools
@test !(PooledString() < PooledString())
a = sort([PooledString(), pstring("z"), pstring("a")])
@test isnull(a, 3)
a = sort([PooledString(), "z", "a"])
@test a[3] == "__NULL__"

end # module
