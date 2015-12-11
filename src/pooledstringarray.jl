
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


##############################################################################
##
## Nullable methods
##
##############################################################################

Base.isnull(X::PooledStringArray, I::Integer...) = X[I...].level == 0
Base.isnull(X::PooledStringArray, iv::AbstractVector) = [X[i].level == 0 for i in iv]

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
function repool{S <: AbstractString, T <: Unsigned}(
                     a::PooledStringArray, 
                     newpool::Pool{S,T}=__GLOBAL_POOL__)
    mapvec = Array(T, length(a.pool))
    uniquerefs = uniqueints(a.refs, UInt, (1,length(a.pool))) 
    for i in uniquerefs
        mapvec[i] = get!(newpool, a.pool.index[i])
    end
    newrefs = mapvec[a.refs]
    PooledStringArray(newrefs, newpool)
end
## If pools match, return the original:
repool{S <: AbstractString, N, T <: Unsigned, ID}(
            a::PooledStringArray{S,N,T,ID}, 
            newpool::Pool{S,T,ID}=__GLOBAL_POOL__) = a


# asuint(x::PooledStringArray) = x.refs
