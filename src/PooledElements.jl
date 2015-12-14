
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
using JLD

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

export pstring, repool, repool!, levels, rename

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
include("jld.jl")


end # module
