
##############################################################################
##
## Global string pool
##
##############################################################################

const __GLOBAL_POOL__ = Pool()


##############################################################################
##
## PooledString
##
##############################################################################

immutable PooledString{S <: AbstractString, T <: Unsigned, ID} <: AbstractString
    level::T
    pool::Pool{S,T,ID}
end


##############################################################################
##
## PooledString constructors
##
##############################################################################

PooledString{S <: AbstractString, T <: Unsigned, ID}(i::Integer = 0, pool::Pool{S,T,ID} = __GLOBAL_POOL__) = 
    PooledString{S,T,ID}(convert(T, i), pool)


##############################################################################
##
## pstring constructor
##
##############################################################################

function pstring{S <: AbstractString, T <: Unsigned, ID}(pool::Pool{S,T,ID}, s::S) 
    i = get!(pool, s)
    PooledString(i, pool)
end

pstring{S <: AbstractString}(s::S) = pstring(__GLOBAL_POOL__, utf8(s))

pstring(pool::Pool, s...) = 
    pstring(pool, utf8(string(s...)))
    
pstring(s...) = pstring(__GLOBAL_POOL__, utf8(string(s...)))


##############################################################################
##
## PooledString Base utilities
##
##############################################################################

Base.string(x::PooledString) = x.level != 0 ? x.pool[x.level] : "__NA__"
Base.next(s::PooledString, i::Int) = next(string(s), i)

Base.isnull(x::PooledString) = x.level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

Base.endof(x::PooledString) = endof(string(x))

# asuint{S <: AbstractString, T <: Unsigned, ID}(x::Vector{PooledString{S,T,ID}}) = 
#     T[x[i].level for i in 1:length(x)]
