module TPSA

using PooledElements
using Base.Test

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
@test isa(x, PooledStringArray{String,1,UInt8})

x = PooledStringArray(Pool(UInt8), 3)
@test size(x) == (3,)
@test isa(x, PooledStringArray{String,1,UInt8})

x = PooledStringArray(Pool(UInt8), 3, 2)
@test size(x) == (3,2)
@test isa(x, PooledStringArray{String,2,UInt8})

x = PooledStringArray(3, 2)
@test size(x) == (3,2)
@test isa(x, PooledStringArray{String,2,UInt})

x = PooledStringArray([pstring("a"), pstring("b")])
@test size(x) == (2,)
@test isa(x, PooledStringArray{String,1,UInt})

x = PooledStringArray(String["a", "b"])
@test size(x) == (2,)
@test isa(x, PooledStringArray{String,1,UInt})

x = PooledStringArray(["a", "b"])
@test size(x) == (2,)
@test isa(x, PooledStringArray{String,1,UInt})

x = PooledStringArray(["a", "b"], [false, true])
@test size(x) == (2,)
@test isa(x, PooledStringArray{String,1,UInt})
@test isnull(x, 2)

x = PooledStringArray(UInt8, ["a", "b"], [false, true])
@test size(x) == (2,)
@test isa(x, PooledStringArray{String,1,UInt8})
@test isnull(x, 2)

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

a = PooledStringArray(UInt8, ["x", "y", "z"])
@test isa(a, PooledStringArray{String,1,UInt8})
@test levels(a) == ["x", "y", "z"]

##############################################################################
##
## Re-pooling, condensing, and re-ordering methods
##
##############################################################################

x = PooledStringArray(Pool(UInt8), ["c", "a", "x"])
y = PooledStringArray(Pool(), ["x", "a", "y"])
z = repool(x, y.pool)
@test x == z
@test length(x.pool) == 3
@test length(y.pool) == 4
@test length(z.pool) == 4
@test levels(z) == String["x", "a", "y", "c"]

x = PooledStringArray(Pool(["x", "a"]), ["b", "c", "a"])
y = repool(x, Pool(UInt8))
@test x == y
@test length(y.pool) == 3
z = repool(y, Pool(sort(levels(y))))
@test levels(z) == String["a", "b", "c"]

zz = rename(z, "a" => "apple", "b" => "banana")
@test levels(z) == ["a", "b", "c"]
@test levels(zz) == ["apple", "banana", "c"]

x = PooledStringArray(["a", "b", "c"])
x = repool!(x, Pool())  # Note: don't just do `repool!(x, Pool())`
@test length(x.pool) == 3


##############################################################################
##
## PooledStringVector Base methods
##
##############################################################################

v = [pstring("a"), pstring("b"), pstring("c")]
psv = PooledStringArray(v)

v1 = push!(copy(v), pstring("x"))
psv1 = push!(copy(psv), "x")
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = copy(v)
psv1 = copy(psv)
x = pop!(v1)
y = pop!(psv1)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})
@test x == y
@test isa(x, PooledString{String,UInt})
@test isa(y, PooledString{String,UInt})

v1 = unshift!(copy(v), pstring("x"))
psv1 = unshift!(copy(psv), "x")
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = unshift!(copy(v), pstring("x"), pstring("y"))
psv1 = unshift!(copy(psv), "x", "y")
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = copy(v)
psv1 = copy(psv)
x = shift!(v1)
y = shift!(psv1)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})
@test x == y
@test isa(x, PooledString{String,UInt})
@test isa(y, PooledString{String,UInt})

# vc = copy(v)
# psvc = copy(psv)
# v1 = splice!(vc, 2, pstring("x"))
# psv1 = splice!(psvc, 2, "x")
# @test vc == psvc
# @test isa(psvc, PooledStringArray{String,1,UInt})

v1 = deleteat!(copy(v), 2)
psv1 = deleteat!(copy(psv), 2)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = deleteat!(copy(v), 2)
psv1 = deleteat!(copy(psv), 2)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = resize!(copy(v), 2)
psv1 = resize!(copy(psv), 2)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

# v1 = resize!(copy(v), 5)     ## fails because of #undefs
psv1 = resize!(copy(psv), 5)
@test length(psv1) == 5
@test isnull(psv1,5)
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = append!(copy(v), [pstring("a"), pstring("b")])
psv1 = append!(copy(psv), ["a", "b"])
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = prepend!(copy(v), [pstring("a"), pstring("b")])
psv1 = prepend!(copy(psv), ["a", "b"])
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = sizehint!(copy(v), 10)
psv1 = sizehint!(copy(psv), 10)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = reverse!(copy(v))
psv1 = reverse!(copy(psv))
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})

v1 = reverse!(copy(v), 2, 3)
psv1 = reverse!(copy(psv), 2, 3)
@test v1 == psv1
@test isa(psv1, PooledStringArray{String,1,UInt})


##############################################################################
##
## NullableArray methods
##
##############################################################################

v = fill(PooledString(), 3)
psv = PooledStringArray(v)
@test v == psv
@test anynull(v)
@test allnull(v)
@test anynull(psv)
@test allnull(psv)

v = fill(pstring("a"), 3)
psv = PooledStringArray(v)
nullify!(psv, 2)
@test anynull(psv)
@test !allnull(psv)


v = [pstring("a"), PooledString(), pstring("c")]
@test anynull(v)
@test !allnull(v)
psv = PooledStringArray(v)
@test anynull(psv)
@test !allnull(psv)

psv1 = dropnull(psv)
@test length(psv1) == 2
@test !anynull(psv1)
@test !allnull(psv1)
@test isa(psv1, PooledStringArray{String,1,UInt})

psv1 = padnull!(copy(psv), 1, 3)
@test length(psv1) == 7
@test anynull(psv1)
@test isnull(psv1, 1)
@test !isnull(psv1, 2)
@test !isnull(psv1, 4)
@test isnull(psv1, 5)
@test isa(psv1, PooledStringArray{String,1,UInt})


end # module
