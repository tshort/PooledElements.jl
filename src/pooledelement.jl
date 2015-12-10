

##############################################################################
##
## PooledElement -- not much for now until we see how PooledStrings work
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

# PooledElement{S}(x::S, pool::Pool{S}) = 
#     PooledElement(get!(pool, x), pool)
    
## need a different name above to allow pooling of integers
