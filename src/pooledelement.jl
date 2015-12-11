

##############################################################################
##
## PooledElement
##
##############################################################################

immutable PooledElement{S, T <: Unsigned, ID}
    level::T
    pool::Pool{S,T,ID}
end


##############################################################################
##
## PooledElement constructors
##
##############################################################################

PooledElement{S, T <: Unsigned, ID}(i::Integer, pool::Pool{S,T,ID}) = 
    PooledElement{S,T,ID}(convert(T, i), pool)


##############################################################################
##
## pelement constructor
##
##############################################################################

function pelement{S, T <: Unsigned, ID}(pool::Pool{S,T,ID}, s::S) 
    i = get!(pool, s)
    PooledElement(i, pool)
end


##############################################################################
##
## PooledElement Base utilities
##
##############################################################################

Base.isnull(x::PooledElement) = x.level == 0
Base.isnull{T <: PooledElement}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledElement}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

function NullableArrays.nullify!{S <: PooledElement}(X::AbstractArray{S}, I...)
    X[I...].refs = 0
end
