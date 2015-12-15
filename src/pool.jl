
##############################################################################
##
## Pool -- a container for elements to be referenced
##
##############################################################################

@comment """
# Pool
"""

"""

```julia
AbstractPool{S, T <: Unsigned, ID}
```

An abstract type for types that "pool" quantities to reduce storage
and map values to integers.

### Type parameters

* `S` : the elementary type of stored elements
* `T` : the integer type used to map elements to integers
* `ID` : a unique ID (normally integer)
"""
abstract AbstractPool{S, T <: Unsigned, ID}



"""
```julia
Pool{S, T <: Unsigned, ID} <: AbstractPool{S, T, ID}
```

An immutable type that "pools" quantities to reduce storage and map to integers.

With the main API, you can add to a Pool, but you cannot change existing
elements. 

### Constructors

```julia
Pool{S, T <: Unsigned, ID}()
Pool{S, T <: Unsigned}(index::Vector{S}, invindex::Dict{S,T})
Pool{T <: Unsigned, S}(::Type{T}, ::Type{S})
Pool(t::Type = UInt, s::Type = UTF8String)
Pool(t::Type = UInt, X)
```

### Type parameters

* `S` : the elementary type of stored elements
* `T` : the integer type used for mapping elements to integers
* `ID` : a unique ID (integer)

### Arguments

* `index` : a Vector of values in the Pool
* `invindex` : a Dict mapping a value to an integer
* `ID` : a unique ID (integer)
* `t` : the integer type used to map elements to integers
* `s` : the elementary type of stored elements
* `X` : a Vector or other collection used to populate the Pool

### Main API

* `push!(p, x)` : add value `x` to pool `p`
* `get!(p, x)` : return the index of `x` in `p`, adding `x` if needed
* `haskey(p, x)` : true if `x` is in `p`
* `getindex(p, i)` : the contents of pool `p` at location `i`
* `levels(p)` : the unique values in `p`, a Vector

### Other supporting methods

* `copy(p)`
* `length(p)`
* `rename(p, args...)` : rename values in the pool 
* `merge(p, r)` : pools `p` and `r` merged
* `merge!(p, r)` : pool `r` merged into `p`

### Examples

```julia
p = Pool(UInt8, Float64)  # A Float64 pool with UInt8 references
p = Pool()  # The default pool, a UTF8String pool with UInt references
p = Pool(UInt8, ["x", "y", "z"])  # An ASCIIString pool with UInt8 references
get!(p, "a")  # 4
get!(p, "y")  # 2
length(p)  # 4
```
"""
immutable Pool{S, T <: Unsigned, ID} <: AbstractPool{S, T, ID}
    index::Vector{S}
    invindex::Dict{S,T}
end

 
##############################################################################
##
## Constructors
##
##############################################################################

function Pool{S, T <: Unsigned}(index::Vector{S}, invindex::Dict{S,T})
    Pool{S,T,object_id(invindex)}(index, invindex)
end
function Pool{T <: Unsigned, S}(::Type{T}, ::Type{S})
    d = Dict{S,T}()
    Pool{S,T,object_id(d)}(T[], d)
end

Pool(t::Type = UInt, s::Type = UTF8String) = Pool(t, s)

function Pool(t::Type, X)
    p = Pool(t, eltype(X))
    for x in X
        push!(p, x)
    end
    p
end
Pool(X) = Pool(UInt, X)
          

##############################################################################
##
## Base methods
##
##############################################################################

"""
```julia
length(p::Pool)
```

Returns the number of items in Pool `p`.
"""
Base.length(p::Pool) = length(p.index)

"""
```julia
copy(p::Pool)
```

Returns a copy of `p` with new internal values.
"""
function Base.copy{S, T <: Unsigned, ID}(p::Pool{S,T,ID})
    d = copy(p.invindex)
    Pool{S,T,object_id(d)}(copy(p.index), d)
end

"""
```julia
getindex(p::Pool, i::Integer)
```

Return the contents of pool `p` at location `i`.
"""
function Base.getindex(p::Pool, i::Integer)
    getindex(p.index, i)
end

"""
```julia
haskey(p::Pool, x)
```

Determine whether `p` contains value `x`.
"""
function Base.haskey(p::Pool, x)
    haskey(p.invindex, x)
end

"""
```julia
push!(p::Pool, x)
```

Add value `x` to `p`, returning the updated Pool.
"""
function Base.push!{S}(p::Pool{S}, x)
    y = convert(S, x) 
    if !haskey(p, y)
        push!(p.index, y) 
        p.invindex[y] = length(p)
    end
    p
end


"""
```julia
get!(p, x)
```

Return the index of `x` in `p`, adding `x` if needed.

### Arguments

* `p` : the Pool
* `x` : the element in `p`

### Result

* `::Unsigned` : the reference

### Examples

```julia
p = Pool(UInt32, ["a", "b"])
get!(p, "x")   # 3, add the new element
get!(p, "a")   # 1, an existing element
```

"""
function Base.get!{S}(p::Pool{S}, x)
    ## Returns the index of p, adding x if needed
    y = convert(S, x) 
    if !haskey(p, y)
        push!(p.index, y) 
        p.invindex[y] = length(p)
    end
    p.invindex[y]
end


##############################################################################
##
## Utilities
##
##############################################################################

"""
```julia
levels(p::Pool{S})
```

Return the entries in `p`

### Result

* `::Vector{S}` : the pool entries

### Examples

```julia
p = Pool(UInt32, ["a", "b"])
get!(p, "x")   # 3, add the new element
get!(p, "a")   # 1, an existing element
```

"""
levels(p::Pool) = p.index


"""
```julia
rename(p::Pool, args...)
```

Change the values in a pool, returning the new pool.

### Arguments

* `p::Pool{S}` : the Pool
* `args...` : key-value pairs both of type `S` giving the original value and the replacement value

### Result

* `::Pool{S}` : the pool entries

### Examples

```julia
p = Pool(UInt32, ["a", "b"])
p2 = rename(p, "a" => "apple", "b" => "banana")
levels(p2)  #  ["apple", "banana"]
```
"""
function rename(p::Pool, args...)
    newpool = copy(p)
    for (k,v) in args
        i = newpool.invindex[k]
        newpool.index[i] = v
        newpool.invindex[v] = i
        delete!(newpool.invindex, k)
    end
    newpool
end



##############################################################################
##
## Merging utilities
##
##############################################################################

"""
```julia
Base.merge!{S}(a::Pool{S}, b::Pool)
Base.merge{S}(a::Pool{S}, b::Pool)
```

Change the values in a pool, returning the new pool.

`merge(p, r)` merges pools `p` and `r`.
`merge!(p, r)` merges pool `r` into `p` and returns `p`.

### Arguments

* `a`, `b` : the Pools

### Result

* `::Pool{S}` : the merged pool

### Examples

```julia
p = Pool(UInt32, ["a", "b"])
p2 = Pool(["x", "y"])
p3 = merge(p, p2)
levels(p3)  #  ["a", "b", "x", "y"]
```
"""
function Base.merge!{S}(a::Pool{S}, b::Pool)
    for s in b.index
        push!(a, s) 
    end
    a
end
Base.merge{S}(a::Pool{S}, b::Pool) = merge!(copy(a), b)
        
