
##############################################################################
##
## PooledStringArray
##
##############################################################################

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

levels(p::PooledStringArray) = levels(p.pool)
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
function repool!{S <: AbstractString, T <: Unsigned}(
                      a::PooledStringArray, 
                      newpool::AbstractPool{S,T}=__GLOBAL_POOL__)
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
    repool!(copy(a), newpool)
end
## If pools match, return the original:
repool!{S <: AbstractString, N, T <: Unsigned, ID}(
            a::PooledStringArray{S,N,T,AbstractPool{S,T,ID}}, 
            newpool::AbstractPool{S,T,ID}=__GLOBAL_POOL__) = a


## More to think about:
##
## - repool!
## - rename(psa, "item 1" => "new name for item 1")
## - unique(psa) - return Array or PSA?



# asuint(x::PooledStringArray) = x.refs
