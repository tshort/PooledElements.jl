
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

Base.convert{S <: AbstractString, T <: Unsigned}(::Type{S}, x::PooledString{S,T}) = 
    convert(S, string(x))
Base.convert{U <: Unsigned, S <: AbstractString, T <: Unsigned}(::Type{U}, x::PooledString{S,T}) = 
    convert(U, x.level)

Base.string(x::PooledString) = x.level != 0 ? x.pool[x.level] : "__NA__"
Base.next(s::PooledString, i::Int) = next(string(s), i)

Base.isnull(x::PooledString) = x.level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, I::Integer...) = x[I...].level == 0
Base.isnull{T <: PooledString}(x::AbstractArray{T}, iv::AbstractVector) = [x[i].level == 0 for i in iv]

Base.endof(x::PooledString) = endof(string(x))

# asuint{S <: AbstractString, T <: Unsigned, ID}(x::Vector{PooledString{S,T,ID}}) = 
#     T[x[i].level for i in 1:length(x)]


##############################################################################
##
## PooledStringArray
##
##############################################################################

immutable PooledStringArray{S <: AbstractString, N, T <: Unsigned, ID} <: AbstractArray{PooledString{S,T,ID},N}
    refs::Array{T,N}
    pool::Pool{S,T,ID}
end


##############################################################################
##
## PooledStringArray constructors
##
##############################################################################

function PooledStringArray{S <: AbstractString, N, T <: Unsigned, ID}(refs::Array{T,N}, p::Pool{S,T,ID})
    PooledStringArray{S,N,T,ID}(refs, p)
end
function PooledStringArray{S <: AbstractString, T <: Unsigned}(p::Pool{S,T} = __GLOBAL_POOL__)
    PooledStringArray(T[], p)
end
function PooledStringArray{S <: AbstractString, T <: Unsigned}(p::Pool{S,T}, dims::Integer...)
    PooledStringArray(zeros(T, dims), p)
end
function PooledStringArray(dims::Integer...)
    PooledStringArray(zeros(UInt, dims), __GLOBAL_POOL__)
end
function PooledStringArray{S <: AbstractString, N, T <: Unsigned, ID}(x::AbstractArray{PooledString{S,T,ID},N})
    PooledStringArray(T[x[i].level for i in 1:length(x)], x[1].pool)
end
function PooledStringArray{S <: AbstractString}(x::AbstractArray{S})
    PooledStringArray(__GLOBAL_POOL__, x)
end
function PooledStringArray{S <: AbstractString}(pool::Pool, x::AbstractArray{S})
    psa = PooledStringArray(pool, size(x)...)
    for i in eachindex(x)
        psa[i] = x[i] 
    end
    psa
end


##############################################################################
##
## PooledStringArray Base methods
##
##############################################################################

Base.similar{S <: AbstractString}(A::PooledStringArray, ::Type{S}, dims::Dims) = PooledStringArray(A.pool, dims...)

Base.linearindexing{S <: AbstractString, N, T <: Unsigned, ID}(::Type{PooledStringArray{S,N,T,ID}}) = Base.LinearFast()

Base.size(A::PooledStringArray) = size(A.refs)
Base.size(A::PooledStringArray, d) = size(A.refs, d)

@inline function Base.getindex{S <: AbstractString, N, T <: Unsigned, ID}(A::PooledStringArray{S,N,T,ID}, i::Integer...)
    PooledString(A.refs[i...], A.pool) 
end

@inline function Base.setindex!{S <: AbstractString}(A::PooledStringArray{S}, s::AbstractString, i::Integer...)
    A.refs[i...] = get!(A.pool, s)
end

@inline function Base.setindex!{S <: AbstractString, N, T <: Unsigned, ID}(A::PooledStringArray{S,N,T,ID}, s::PooledString{S,T,ID}, i::Integer...)
    A.refs[i...] = s.level
end

Base.isnull(x::PooledStringArray, I::Integer...) = x[I...].level == 0
Base.isnull(x::PooledStringArray, iv::AbstractVector) = [x[i].level == 0 for i in iv]

# asuint(x::PooledStringArray) = x.refs
