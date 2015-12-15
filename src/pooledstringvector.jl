

##############################################################################
##
## PooledStringVector/Matrix
##
##############################################################################

"""
```julia
typealias PooledStringVector{S,T,P} PooledStringArray{S,1,T,P}
typealias PooledStringMatrix{S,T,P} PooledStringArray{S,2,T,P}
```

Type aliases for PooledStringVector and PooledStringMatrix.

PooledStringVectors support many AbstractVector methods, including `push!`, 
`pop!`, `unshift!`, `shift!`, `splice!`, `deleteat!`, `resize!`, `append!`, 
`prepend!`, `sizehint!`, and `reverse!`. NullableVector methods supported 
include `dropnull`, `padnull!`, and `padnull`
"""
typealias PooledStringVector{S,T,P} PooledStringArray{S,1,T,P}
typealias PooledStringMatrix{S,T,P} PooledStringArray{S,2,T,P}


##############################################################################
##
## Base methods 
##
##############################################################################

function Base.push!{S <: AbstractString}(X::PooledStringVector{S}, s::AbstractString)
    push!(X.refs, get!(X.pool, s))
    return X
end

function Base.pop!{S <: AbstractString}(X::PooledStringVector{S})
    v = X[end]
    pop!(X.refs)
    return v
end

function Base.unshift!{S <: AbstractString, T <: Unsigned}(X::PooledStringVector{S, T}, Y::AbstractString...)
    newrefs = T[]
    for s in Y
        push!(newrefs, get!(X.pool, s))
    end
    prepend!(X.refs, newrefs)
    return X
end

function Base.shift!{S <: AbstractString}(X::PooledStringVector{S})
    v = X[1]
    shift!(X.refs)
    return v
end

function Base.splice!{S <: AbstractString}(X::PooledStringVector{S}, i::Integer, ins=[])
    v = X[i]
    m = length(ins)
    if m == 0
        deleteat!(X.refs, i)
    elseif m == 1
        X[i] = ins
    else
        Base._growat!(X.refs, i, m-1)
        for k = 1:endof(ins)
            X[i + k - 1] = ins[k]
        end
    end
    return v
end
function Base.splice!{S <: AbstractString, T<:Integer}(X::PooledStringVector{S},
                                                       rng::UnitRange{T},
                                                       ins=_default_splice) # ->
    vs = X[rng]
    m = length(ins)
    if m == 0
        deleteat!(X.refs, rng)
        return vs
    end

    n = length(X)
    d = length(rng)
    f = first(rng)
    l = last(rng)

    if m < d # insert is shorter than range
        delta = d - m
        if f - 1 < n - l
            Base._deleteat_beg!(X.refs, f, delta)
        else
            Base._deleteat_end!(X.refs, l - delta + 1, delta)
        end
    elseif m > d # insert is longer than range
        delta = m - d
        if f -  1 < n - l
            Base._growat_beg!(X.refs, f, delta)
        else
            Base._growat_end!(X.refs, l + 1, delta)
        end
    end

    for k = 1:endof(ins)
        X[f + k - 1] = ins[k]
    end
    return vs
end

function Base.deleteat!{S <: AbstractString}(X::PooledStringVector{S}, inds)
    deleteat!(X.refs, inds)
    return X
end

function Base.resize!{S <: AbstractString}(X::PooledStringVector{S}, i)
    n = length(X)
    resize!(X.refs, i)
    for k in n+1:i
        X.refs[k] = 0
    end
    return X
end

function Base.append!{S <: AbstractString}(X::PooledStringVector{S}, items::AbstractVector)
    old_length = length(X)
    nitems = length(items)
    resize!(X, old_length + nitems)
    X[old_length + 1:end] = items[1:nitems]
    return X
end

function Base.prepend!{S <: AbstractString, T <: Unsigned}(X::PooledStringVector{S,T}, items::AbstractVector)
    nitems = length(items)
    prepend!(X.refs, Array(T, nitems))
    X[1:nitems] = items[1:nitems]
    return X
end

function Base.sizehint!{S <: AbstractString}(X::PooledStringVector{S}, newsz::Integer)
    sizehint!(X.refs, newsz)
    return X
end

function Base.reverse!{S <: AbstractString}(X::PooledStringVector{S}, s=1, n=length(X))
    reverse!(X.refs, s, n)
    return X
end

function Base.reverse{S <: AbstractString}(X::PooledStringVector{S}, s=1, n=length(X))
    reverse!(copy(X), s, n)
end

##############################################################################
##
## NullableArray methods
##
##############################################################################

function NullableArrays.dropnull{S <: AbstractString}(X::PooledStringVector{S})
    PooledStringArray(X.refs[X.refs .!= 0], X.pool)
end
    

function NullableArrays.padnull!{S <: AbstractString}(X::PooledStringVector{S}, front::Integer, back::Integer)
    prepend!(X.refs, fill(0, front))
    append!(X.refs, fill(0, back))
    return X
end

function NullableArrays.padnull{S <: AbstractString}(X::PooledStringVector{S}, front::Integer, back::Integer)
    return padnull!(copy(X), front, back)
end
