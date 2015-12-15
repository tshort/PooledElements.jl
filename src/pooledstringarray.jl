
##############################################################################
##
## PooledStringArray
##
##############################################################################

"""
```julia
PooledStringArray{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool} <: 
        AbstractArray{PooledString{S,T,P},N}
```

An AbstractArray that "pools" quantities to reduce storage and map to integers.
The Pool is a type parameter to facilitate use of different pools.
PooledStringArrays can also indicate missing values when the reference to the
pool is zero.

### Constructors / converters

The core constructor is:

```julia
PooledStringArray{S <: AbstractString, N, T <: Unsigned}(refs::Array{T,N}, p::AbstractPool{S,T})
```

Several constructors are available that take AbstractPools and AbstractArrays:

```julia
PooledStringArray{S <: AbstractString, T <: Unsigned}(p::AbstractPool{S,T} = __GLOBAL_POOL__)
PooledStringArray{S <: AbstractString, T <: Unsigned}(p::AbstractPool{S,T}, dims::Integer...)
PooledStringArray(dims::Integer...)
PooledStringArray{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool}(x::AbstractArray{PooledString{S,T,P},N})
PooledStringArray{S <: AbstractString}(x::AbstractArray{S})
PooledStringArray{S <: AbstractString, T <: Unsigned}(t::Type{T}, x::AbstractArray{S})
PooledStringArray{S <: AbstractString}(pool::AbstractPool, x::AbstractArray{S})
```

### Type parameters

* `S` : the elementary type of stored elements
* `N` : the number of dimensions of the array
* `T` : the integer type used for mapping elements to integers
* `P` : the type of the AbstractPool

### Arguments

* `refs` : unsigned integer references to the pool
* `p` : the pool of values, defaulting to the global string pool
* `dims` : the number of dimensions for the result
* `x` : an AbstractArray to be converted
* `t` : unsigned integer type for the AbstractPool used

Constructors using `dims` return a PooledStringArray of nulls.

### Main methods

* `getindex(x, i...)` 
* `setindex!(x, s, i...)` 
* `size(x)` 
* `similar(x, dims...)` 
* `levels(x)` : the levels from the pool used by `x`
* `rename(x, args...)` : rename the strings in the pool used by `x`
* `isnull(x, i...)` : is `x` null at position `i...`
* `anynull(x)` : whether `x` is null at any position 
* `allnull(x)` : whether `x` is null at all positions
* `nullify!(x, i...)` : set location `i...` in `x` to null
* `repool(x, newpool)` : a new PooledStringArray based on `x` using `newpool`
* `repool!(x, newpool)` : a new PooledStringArray based on `x` using `newpool`,
  reusing the references in `x`

### PooledStringVector

Type aliases are included for `PooledStringVector` and `PooledStringMatrix`.

PooledStringVectors support many AbstractVector methods, including `push!`, 
`pop!`, `unshift!`, `shift!`, `splice!`, `deleteat!`, `resize!`, `append!`, 
`prepend!`, `sizehint!`, and `reverse!`. NullableVector methods supported 
include `dropnull`, `padnull!`, and `padnull`

### Examples

```julia
PooledStringArray(3, 2) 
p = Pool()
x = PooledStringArray(p, ["a", "b"])
levels(x)
```
"""
immutable PooledStringArray{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool} <: AbstractArray{PooledString{S,T,P},N}
    refs::Array{T,N}
    pool::P
end


##############################################################################
##
## PooledStringArray constructors
##
##############################################################################

function PooledStringArray{S <: AbstractString, N, T <: Unsigned}(refs::Array{T,N}, p::AbstractPool{S,T})
    PooledStringArray{S,N,T,typeof(p)}(refs, p)
end
function PooledStringArray{S <: AbstractString, T <: Unsigned}(p::AbstractPool{S,T} = __GLOBAL_POOL__)
    PooledStringArray(T[], p)
end
function PooledStringArray{S <: AbstractString, T <: Unsigned}(p::AbstractPool{S,T}, dims::Integer...)
    PooledStringArray(zeros(T, dims), p)
end
function PooledStringArray(dims::Integer...)
    PooledStringArray(zeros(UInt, dims), __GLOBAL_POOL__)
end
function PooledStringArray{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool}(x::AbstractArray{PooledString{S,T,P},N})
    PooledStringArray(T[x[i].level for i in 1:length(x)], x[1].pool)
end
function PooledStringArray{S <: AbstractString}(x::AbstractArray{S})
    PooledStringArray(__GLOBAL_POOL__, x)
end
function PooledStringArray{S <: AbstractString, T <: Unsigned}(t::Type{T}, x::AbstractArray{S})
    PooledStringArray(Pool(T,S), x)
end
function PooledStringArray{S <: AbstractString}(pool::AbstractPool, x::AbstractArray{S})
    psa = PooledStringArray(pool, size(x)...)
    for i in eachindex(x)
        psa[i] = x[i] 
    end
    psa
end


##############################################################################
##
## Utilities
##
##############################################################################

"""
```julia
levels(x::PooledStringArray)
```

Return the levels from the AbstractPool used by `x`.
"""
levels(p::PooledStringArray) = levels(p.pool)

"""
```julia
rename(x::PooledString, args...)
```

Rename the values in a pool used by `x`, returning the new 
PooledStringArray with its new AbstractPool.

### Example

```julia
x = PooledStringArray(Pool(), ["b", "a"])
y = rename(x, "a" => "apple", "b" => "banana")
```
"""
rename(p::PooledStringArray, args...) = PooledStringArray(p.refs, rename(p.pool, args...))


##############################################################################
##
## PooledStringArray Base methods
##
##############################################################################

Base.similar{S <: AbstractString}(A::PooledStringArray, ::Type{S}, dims::Dims) = PooledStringArray(A.pool, dims...)

Base.linearindexing{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool}(::Type{PooledStringArray{S,N,T,P}}) = Base.LinearFast()

Base.size(A::PooledStringArray) = size(A.refs)
Base.size(A::PooledStringArray, d) = size(A.refs, d)

@inline function Base.getindex{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool}(A::PooledStringArray{S,N,T,P}, i::Integer...)
    PooledString(A.refs[i...], A.pool) 
end

@inline function Base.setindex!{S <: AbstractString}(A::PooledStringArray{S}, s::AbstractString, i::Integer...)
    A.refs[i...] = get!(A.pool, s)
end

@inline function Base.setindex!{S <: AbstractString, N, T <: Unsigned, P <: AbstractPool}(A::PooledStringArray{S,N,T,P}, s::PooledString{S,T,P}, i::Integer...)
    A.refs[i...] = s.level
end


##############################################################################
##
## Nullable methods
##
##############################################################################

"""
```julia
isnull(x::PooledStringArray, i...)
```

Whether `x` is null at positions `i...`.
"""
Base.isnull(X::PooledStringArray, I::Integer...) = X[I...].level == 0
Base.isnull(X::PooledStringArray, iv::AbstractVector) = [X[i].level == 0 for i in iv]

"""
```julia
nullify!(x::PooledStringArray, i...)
```

Set `x` to null at positions `i...`.
"""
NullableArrays.nullify!(X::PooledStringArray, I...) =
    setindex!(X.refs, 0, I...)


_isnull(x) = false
_isnull(x::Nullable) = isnull(x)
_isnull(x::PooledString) = isnull(x)
_isnull(x::PooledElement) = isnull(x)

function NullableArrays.anynull(A::AbstractArray) # -> Bool
    for a in A
        if _isnull(a)
            return true
        end
    end
    return false
end

function NullableArrays.allnull(A::AbstractArray) # -> Bool
    for a in A
        if !_isnull(a)
            return false
        end
    end
    return true
end


##############################################################################
##
## Re-pooling, condensing, and re-ordering methods
##
##############################################################################

"""
```julia
repool!(a::PooledStringArray, 
        newpool::AbstractPool=__GLOBAL_POOL__)
repool(a::PooledStringArray, 
       newpool::AbstractPool=__GLOBAL_POOL__)
```

Create a new PooledStringArray based on `a` and `newpool`. This is useful for 
reordering pooled values, condensing a pool, and for merging into the global 
pool.

`repool!` reuses the storage from `a`. NOTE that this corrupts `a`; be sure to 
use the return value, not `a`. To use `repool!`, the integer reference types of 
`newpool` and `a` must also match.

### Examples

```julia
pool = Pool(["x", "y", "z"])
x = PooledStringArray(pool, ["b", "a"])
levels(x)
# Condense a pool to only the unique values in `x`
y = repool(x, Pool())
levels(y)
# Convert `y` to using the global pool
z = repool(y, PooledElements.__GLOBAL_POOL__)
levels(z)
# Sort the levels of `y`
x = PooledStringArray(Pool(), ["b", "x", "a"])
levels(x)
z = repool!(x, Pool(sort(levels(x.pool))))
levels(z)
```
"""
function repool!{S <: AbstractString, N, T <: Unsigned}(
                      a::PooledStringArray{S,N,T}, 
                      newpool::AbstractPool{S,T}=__GLOBAL_POOL__)
    ## Because `a` and `newpool` are the same type,
    ## we can reuse `a.refs`.
    mapvec = Array(T, length(a.pool))
    uniquerefs = uniqueints(a.refs, UInt, (1,length(a.pool))) 
    for i in uniquerefs
        mapvec[i] = get!(newpool, a.pool.index[i])
    end
    for i in 1:length(a)
        j = a.refs[i]
        if j != 0 
            a.refs[i] = mapvec[j]
        end
    end
    PooledStringArray(a.refs, newpool)
end
function repool{S <: AbstractString, T <: Unsigned}(
                     a::PooledStringArray, 
                     newpool::AbstractPool{S,T}=__GLOBAL_POOL__)
    mapvec = Array(T, length(a.pool))
    uniquerefs = uniqueints(a.refs, UInt, (1,length(a.pool))) 
    for i in uniquerefs
        mapvec[i] = get!(newpool, a.pool.index[i])
    end
    newrefs = Array(T, length(a))
    for i in 1:length(a)
        j = a.refs[i]
        if j != 0 
            newrefs[i] = mapvec[j]
        else 
            newrefs[i] = 0
        end
    end
    PooledStringArray(newrefs, newpool)
end
## If pools match, return the original:
repool!{S <: AbstractString, N, T <: Unsigned, ID}(
            a::PooledStringArray{S,N,T,AbstractPool{S,T,ID}}, 
            newpool::AbstractPool{S,T,ID}=__GLOBAL_POOL__) = a
repool{S <: AbstractString, N, T <: Unsigned, ID}(
            a::PooledStringArray{S,N,T,AbstractPool{S,T,ID}}, 
            newpool::AbstractPool{S,T,ID}=__GLOBAL_POOL__) = a


function uniqueints{U <: Integer, T}(vs::AbstractVector{U}, ::Type{T}, ex=extrema(vs))
    ## uses a counting-type approach to find unique values
    mn, mx = ex
    bin = zeros(T, mx-mn+1)
    # Histogram for each element, radix
    @inbounds for i = 1:length(vs)
        bin[vs[i] - mn + 1] = 1
    end
    # println(bin)
    n = sum(bin)
    res = Array(T, n)
    j = 1
    @inbounds for i = eachindex(bin)
        if bin[i] != 0
            res[j] = i
            j += 1
        end
    end
    res
end




## More to think about:
##
## - unique(psa) - return Array or PSA?
