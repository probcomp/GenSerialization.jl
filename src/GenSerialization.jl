module GenSerialization
using Gen

"""
Serialization produces a .gen file that relies on Julia's native serialization.

Roughly, the serialized trace appears as a nested layout of traces where
parent traces contain serialized segments of a sub trace.

Each file contains a
1) Version number corresponding to the version of GenSerialization.jl used.
2) Type of (sub) trace
3) Contents of a trace as serialized segments.
"""

include("gen_file.jl")
include("write_session.jl")
include("serializers/serializers.jl")
include("lazy_structs/lazy_structs.jl")
include("file_header.jl")
include("serialization.jl")
include("deserialization.jl")

# Native caching
precompile(deserialize, (String,))
DEFAULT_TYPES = [
    (Gen.DynamicDSLTrace{DynamicDSLFunction{Any}}, DynamicDSLFunction{Any}),
    (Gen.VectorTrace{Gen.MapType, Any, Gen.DynamicDSLTrace}, Map{Any, Gen.DynamicDSLTrace})
]
for tr_type in DEFAULT_TYPES
    precompile(serialize, (String, tr_type[1]))
    precompile(realize, (String, tr_type[2]))
end

end
