

##############################################################################
##
## PooledElement
##
##############################################################################

"""
```julia
PooledElement{S, T <: Unsigned, P <: AbstractPool}
```

An immutable that "pools" quantities to reduce storage and map to integers. The
Pool is a type parameter to facilitate use of different pools. PooledElements can
also indicate missing values when the reference to the pool is zero.

### Constructors / converters

```julia
PooledElement{S, T <: Unsigned, P <: AbstractPool}(i::Integer, pool::AbstractPool{S,T,P})
```

See also `pelement`, the main way to create PooledElements.

### Type parameters

* `S` : the elementary type of stored elements
* `T` : the integer type used for mapping elements to integers
* `P` : the type of the AbstractPool

### Arguments

* `i` : reference to the pool
* `pool` : the pool of values

### Main methods

* `pelement(x)` : create a PooledElement from `x`
* `isnull(x)` : is `x` null 

### Examples

```julia
PooledElement(0, Pool(UInt8, Float64))
levels(p)
```
"""
immutable PooledElement{S, T <: Unsigned, P <: AbstractPool}
    level::T
    pool::P
end


##############################################################################
##
## PooledElement constructors
##
##############################################################################

PooledElement{S, T <: Unsigned, ID}(i::Integer, pool::AbstractPool{S,T,ID}) = 
    PooledElement{S,T,typeof(pool)}(convert(T, i), pool)


##############################################################################
##
## pelement constructor
##
##############################################################################

function pelement{S, T <: Unsigned}(pool::AbstractPool{S,T}, s::S) 
    i = get!(pool, s)
    PooledElement(i, pool)
end


##############################################################################
##
## PooledElement Base utilities
##
##############################################################################

Base.show(io::IO, x::PooledElement) = isnull(x) ? print(io, "#NULL") : print(io, x.pool[x.level])

Base.isnull(x::PooledElement) = x.level == 0
Base.isnull{T <: PooledElement}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledElement}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

function NullableArrays.nullify!{S <: PooledElement}(X::AbstractArray{S}, I...)
    X[I...].refs = 0
end
