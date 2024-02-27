# mutable struct SwitchDeserializeState{T}
#     score::Float64
#     noise::Float64
#     index::Int
#     subtrace::Trace
#     retval::T
#     SwitchDeserializeState{T}(score::Float64, noise::Float64) where T = new{T}(score, noise)
# end

# function deserialize_trace(io::IO, gen_fn::Switch{C, N, K, T}) where {C, N, K, T}
#     trace_type = Serialization.deserialize(io)
#     !(trace_type <: Gen.VectorTrace) && error("Expected VectorTrace, got $trace_type")
#     retval = Serialization.deserialize(io)
#     args = Serialization.deserialize(io)
#     len = read(io, Int)
#     num_nonempty = read(io, Int)
#     score = read(io, Float64)
#     noise = read(io, Float64)
# end