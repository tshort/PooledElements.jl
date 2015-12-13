module TP

using PooledElements
using Base.Test

##############################################################################
##
## Constructors
##
##############################################################################

a = Pool(Float64[], Dict{Float64,UInt16}())
@test isa(a, Pool{Float64,UInt16})
a = Pool(UInt[], Dict{UInt,UInt16}())
@test isa(a, Pool{UInt,UInt16})
a = Pool(UInt[], Dict{UInt,UInt}())
@test isa(a, Pool{UInt,UInt})

a = Pool()
@test isa(a, Pool{UTF8String,UInt64})
a = Pool(UInt8)
@test isa(a, Pool{UTF8String,UInt8})
a = Pool(UInt8, Float64)
@test isa(a, Pool{Float64,UInt8})
a = Pool(UInt8, UInt8)
@test isa(a, Pool{UInt8,UInt8})

a = Pool()
b = Pool()
@test a != b
@test a == a

a = Pool(UInt8, ["x", "y", "z"])
@test isa(a, Pool{ASCIIString,UInt8})
@test levels(a) == ["x", "y", "z"]

a = Pool(UTF8String["x", "y", "z"])
@test isa(a, Pool{UTF8String,UInt64})
@test levels(a) == ["x", "y", "z"]


##############################################################################
##
## Basics
##
##############################################################################

a = Pool(UInt8, Float64)
push!(a, 2.0)
@test length(a) == 1

push!(a, 2.0, 3.0, 4.0)
@test length(a) == 3
@test a[2] == 3.0
@test a[1] == 2.0

i = get!(a, 2.0)
@test length(a) == 3
@test i == 1

i = get!(a, -2.0)
@test length(a) == 4
@test i == 4

b = Pool(UInt8, Float64)
push!(b, 2.0, 5.0, 6.0)
@test length(b) == 3

##############################################################################
##
## Merging 
##
##############################################################################

a = Pool(UInt8, Float64)
push!(a, 2.0, 3.0, 4.0)
b = Pool(UInt8, Float64)
push!(b, 2.0, 5.0, 6.0)

c = merge(a,b)
@test isa(c, Pool{Float64,UInt8})
@test length(c) == 5
@test get!(c, 5.0) == 4

a = Pool(UInt8, Float64)
push!(a, 2.0, 3.0, 4.0)
b = Pool(UInt16, Int)
push!(b, 2, 5, 6)

c = merge(a,b)
@test isa(c, Pool{Float64,UInt8})
@test length(c) == 5
@test get!(c, 5.0) == 4
@test c[2] == 3.0

end # module
