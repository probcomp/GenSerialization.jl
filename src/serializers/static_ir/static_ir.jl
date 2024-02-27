# RECORD_INFO = NamedTuple{(:record_ptr, :record_size, :is_trace), Tuple{Int64, Int64, Bool}}

include("serialization.jl")
include("deserialization.jl")
include("realization.jl")