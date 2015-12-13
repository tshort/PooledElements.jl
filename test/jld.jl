
module TJLD

using PooledElements
using JLD
using Base.Test

p = Pool()
push!(p, "xyz")

a = PooledStringArray(["asdf", "hello", "x"])
b = PooledStringArray(["a", "b", "c"])
nullify!(b, 2)
c = PooledStringArray(p, ["x", "y", "z"])
A = [PooledString(), pstring("pstring 1")]
p2 = Pool()
push!(p2, "hello")

fname = joinpath(tempdir(), "mydata.jld")
@save fname a b c A p2

d = load(fname)
@test a == d["a"]
@test b == d["b"]
@test c == d["c"]
@test length(d["c"].pool) == 4
@test d["a"].pool === PooledElements.__GLOBAL_POOL__


end # module
