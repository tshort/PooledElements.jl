
##############################################################################
##
## Global string pool
##
##############################################################################

"""
```julia
const __GLOBAL_POOL__ = Pool()
```

The global string pool. Not exported.
"""
const __GLOBAL_POOL__ = Pool()


##############################################################################
##
## PooledString
##
##############################################################################

"""
```julia
PooledString{S <: AbstractString, T <: Unsigned, P <: AbstractPool} <: AbstractString
```

An immutable AbstractString that "pools" quantities to reduce storage and map to
integers. The Pool is a type parameter to facilitate use of different pools.
PooledStrings can also indicate missing values when the reference to the pool is
zero.

### Constructors / converters

```julia
PooledString{S <: AbstractString, T <: Unsigned, P <: AbstractPool}(
               i::Integer = 0, pool::AbstractPool{S,T} = __GLOBAL_POOL__)
```

See also `pstring`, the main way to create PooledStrings.

### Type parameters

* `S` : the elementary type of stored elements
* `T` : the integer type used for mapping elements to integers
* `P` : the type of the AbstractPool

### Arguments

* `i` : reference to the pool
* `pool` : the pool of values, defaulting to the global string pool

### Main methods

* `levels(x)` : the levels from the pool used by `x`
* `rename(x, args...)` : rename the strings in the pool used by `x`
* `isnull(x)` : is `x` null 
* `string(x)` : convert to a non-pooled version

### Examples

```julia
PooledString()  # a null string based on the global pool
p = Pool()
PooledString(0, p)  # a null string based on a custom pool
pstring("hello")
pstring("hello", "world")
pstring(p, "hello", "world")
levels(p)
```
"""
immutable PooledString{S <: AbstractString, T <: Unsigned, P <: AbstractPool} <: AbstractString
    level::T
    pool::P
end


##############################################################################
##
## PooledString constructors
##
##############################################################################

PooledString{S <: AbstractString, T <: Unsigned}(
               i::Integer = 0, pool::AbstractPool{S,T} = __GLOBAL_POOL__) = 
    PooledString{S,T,typeof(pool)}(convert(T, i), pool)


##############################################################################
##
## pstring constructor
##
##############################################################################

"""
```julia
pstring{S <: AbstractString, T <: Unsigned}(pool::AbstractPool{S,T}, s::S) 
pstring{S <: AbstractString}(s::S)
pstring{S <: AbstractString}(pool::AbstractPool{S}, s...)
pstring(s...)
```

Return a PooledString based on inputs.

### Arguments

* `pool` : the Pool, defaults to the global string pool
* `s` : a value to be converted to an AbstractString type

### Result

* `::PooledString`

### Examples

```julia
pstring("hello")      # uses the global string pool
pstring("hello", "world")
p = Pool()
pstring(p, "hello", "world")
```
"""
function pstring{S <: AbstractString, T <: Unsigned}(pool::AbstractPool{S,T}, s::S) 
    i = get!(pool, s)
    PooledString(i, pool)
end

pstring{S <: AbstractString}(s::S) = pstring(__GLOBAL_POOL__, utf8(s))

pstring{S <: AbstractString}(pool::AbstractPool{S}, s...) = 
    pstring(pool, utf8(string(s...)))
    
pstring(s...) = pstring(__GLOBAL_POOL__, utf8(string(s...)))


##############################################################################
##
## Utilities
##
##############################################################################

"""
```julia
levels(x::PooledString)
```

Return the levels from the AbstractPool used by `x`.
"""
levels(p::PooledString) = levels(p.pool)


"""
```julia
rename(x::PooledString, args...)
```

Rename the values in a pool used by a PooledString, returning the new 
PooledString with its new AbstractPool.
"""
rename(p::PooledString, args...) = PooledString(p.level. rename(p.pool, args...))


##############################################################################
##
## PooledString Base utilities
##
##############################################################################

"""
```julia
string(x::PooledString{S})
```

Return a string of type `S`. Note that if `x` is null, the string "__NULL__" 
is returned.
"""
Base.string{S <: AbstractString}(x::PooledString{S}) = 
    x.level != 0 ? x.pool[x.level] : convert(S, "__NULL__")

Base.next(s::PooledString, i::Int) = next(string(s), i)


"""
```julia
isnull(x::PooledString, args...)
```

Rename the values in a pool used by a PooledString, returning the new 
PooledString with its new AbstractPool.
"""
Base.isnull(x::PooledString) = x.level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

Base.endof(x::PooledString) = endof(string(x))

Base.show(io::IO, s::PooledString) = isnull(s) ? print(io, "#NULL") : print(io, string("\"", s ,"\""))
