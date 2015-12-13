
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

levels(p::PooledString) = levels(p.pool)
rename(p::PooledString, args...) = PooledString(p.level. rename(p.pool, args...))


##############################################################################
##
## PooledString Base utilities
##
##############################################################################

Base.string(x::PooledString) = x.level != 0 ? x.pool[x.level] : "__NULL__"
Base.next(s::PooledString, i::Int) = next(string(s), i)

Base.isnull(x::PooledString) = x.level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

Base.endof(x::PooledString) = endof(string(x))

Base.show(io::IO, s::PooledString) = isnull(s) ? print(io, "#NULL") : print(io, string("\"", s ,"\""))

# asuint{S <: AbstractString, T <: Unsigned, ID}(x::Vector{PooledString{S,T,ID}}) = 
#     T[x[i].level for i in 1:length(x)]
