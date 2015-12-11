
##############################################################################
##
## Pool -- a container for elements to be referenced
##
##############################################################################

immutable Pool{S, T <: Unsigned, ID}
    index::Vector{S}
    invindex::Dict{S,T}
end

 
##############################################################################
##
## Constructors
##
##############################################################################

function Pool{S, T <: Unsigned}(index::Vector{S}, invindex::Dict{S,T})
    Pool{S,T,object_id(invindex)}(index, invindex)
end
function Pool{T <: Unsigned, S}(::Type{T}, ::Type{S})
    d = Dict{S,T}()
    Pool{S,T,object_id(d)}(T[], d)
end

Pool(t = UInt, s = UTF8String) = Pool(s, t)

##############################################################################
##
## Base methods
##
##############################################################################


Base.length(p::Pool) = length(p.index)

function Base.copy{S, T <: Unsigned, ID}(p::Pool{S,T,ID})
    d = copy(p.invindex)
    Pool{S,T,object_id(d)}(copy(p.index), d)
end

function Base.getindex(p::Pool, i::Integer)
    # Return the contents of the pool at location i
    getindex(p.index, i)
end

function Base.haskey(p::Pool, x)
    haskey(p.invindex, x)
end

function Base.push!{S}(p::Pool{S}, x)
    y = convert(S, x) 
    if !haskey(p, y)
        push!(p.index, y) 
        p.invindex[y] = length(p)
    end
    p
end

function Base.get!{S}(p::Pool{S}, x)
    ## Returns the index of p, adding x if needed
    y = convert(S, x) 
    if !haskey(p, y)
        push!(p.index, y) 
        p.invindex[y] = length(p)
    end
    p.invindex[y]
end

##############################################################################
##
## Merging utilities
##
##############################################################################

# function Base.merge!{S, T <: Unsigned}(a::Pool{S,T}, b::Pool{S,T})
function Base.merge!{S}(a::Pool{S}, b::Pool)
    for s in b.index
        push!(a, s) 
    end
    a
end
# Base.merge{S, T <: Unsigned}(a::Pool{S,T}, b::Pool{S,T}) = merge!(copy(a), b)
Base.merge{S}(a::Pool{S}, b::Pool) = merge!(copy(a), b)
        
