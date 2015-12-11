
# TO DO's
# - Add a slot for GC?
# - Add docstrings


module PooledElements


##############################################################################
##
## Dependencies
##
##############################################################################

using Compat
using Docile
using NullableArrays

@document

##############################################################################
##
## Exported methods and types
##
##############################################################################

export Pool, 
       PooledElement, 
       PooledArray,
       PooledString, 
       PooledStringArray

export pstring, repool

# Re-exports from NullableArrays
export dropnull,
       anynull,
       allnull,
       nullify!,
       padnull!,
       padnull

##############################################################################
##
## Load files
##
##############################################################################

include("pool.jl")
include("pooledelement.jl")
include("pooledstring.jl")
include("pooledstringarray.jl")
include("pooledstringvector.jl")


end # module
