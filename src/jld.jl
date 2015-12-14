

##############################################################################
##
## JLD custom serialization - Pool
##
##############################################################################

immutable PoolSerializer{S, T <: Unsigned}
    index::Vector{S}
    invindex::Dict{S,T}
end

immutable GlobalPoolSerializer{S, T <: Unsigned}
    index::Vector{S}
    invindex::Dict{S,T}
end

function JLD.writeas(x::Pool)
    if x === __GLOBAL_POOL__
        GlobalPoolSerializer(x.index, x.invindex)
    else
        PoolSerializer(x.index, x.invindex)
    end
end

function JLD.readas(x::PoolSerializer)
    Pool(x.index, x.invindex)
end

function JLD.readas(x::GlobalPoolSerializer)
    merge!(__GLOBAL_POOL__, Pool(x.index, x.invindex))
end



##############################################################################
##
## JLD custom serialization - PooledString
##
##############################################################################

immutable PooledStringSerializer{S <: AbstractString, T <: Unsigned}
    level::T
    pool::Pool{S,T}
end

immutable GlobalPooledStringSerializer{S <: AbstractString}
    s::S
end

function JLD.writeas(x::PooledString)
    if x === __GLOBAL_POOL__
        GlobalPooledStringSerializer(string(x))
    else
        PooledStringSerializer(x.level, x.pool)
    end
end

function JLD.readas(x::PooledStringSerializer)
    PooledString(x.level, x.pool)
end

function JLD.readas(x::GlobalPooledStringSerializer)
    x.s == "__NULL__" ? PooledString() : pstring(x.s)
end


##############################################################################
##
## JLD custom serialization - PooledArray
##
##############################################################################

immutable PooledStringArraySerializer{S <: AbstractString, N, T <: Unsigned}
    refs::Array{T,N}
    pool::Pool{S,T}
end

immutable GlobalPooledStringArraySerializer{S <: AbstractString, N, T <: Unsigned}
    refs::Array{T,N}
    pool::Pool{S,T}
end

function JLD.writeas(x::PooledStringArray)
    if x === __GLOBAL_POOL__
        y = repool(x, Pool())
        GlobalPooledStringArraySerializer(y.refs, y.pool)
    else
        PooledStringArraySerializer(x.refs, x.pool)
    end
end

function JLD.readas(x::PooledStringArraySerializer)
    PooledStringArray(x.refs, x.pool)
end

function JLD.readas(x::GlobalPooledStringArraySerializer)
    repool(PooledStringArray(x.refs, x.pool))
end



##############################################################################
##
## JLD custom serialization - PooledElement
##
##############################################################################

immutable PooledElementSerializer{S, T <: Unsigned}
    level::T
    pool::Pool{S,T}
end

function JLD.writeas(x::PooledElement)
    PooledElementSerializer(x.level, x.pool)
end

function JLD.readas(x::PooledElementSerializer)
    PooledElement(x.level, x.pool)
end
