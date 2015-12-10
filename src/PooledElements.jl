
# TO DO's
# - Add a slot for GC?
# - Add a global dict for pool lookup?
# - Add tests
# - Add docstrings


module PooledElements


##############################################################################
##
## Dependencies
##
##############################################################################

using Compat
using Docile

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

##############################################################################
##
## Load files
##
##############################################################################

include("pool.jl")
include("pooledelement.jl")
include("pooledstring.jl")


end # module
