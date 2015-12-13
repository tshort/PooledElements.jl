

##############################################################################
##
## PooledElement
##
##############################################################################

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
