import Serialization: Serialization, serialize

function Serialization.serialize(::AbstractString, ::Gen.Trace) end
function Serialization.serialize(::IO, ::Gen.Trace) end

function Serialization.serialize(filename::AbstractString, trace::Gen.DynamicDSLTrace)
    genopen(filename, "w") do f
        Serialization.serialize(f, trace)
    end
end

function Serialization.serialize(f::GenFile, tr::Gen.DynamicDSLTrace{T}) where {T}
    # Write gen header
    write_file_header(f)
    # Write gen header
    # Write trace Type
    # Write address map
    # Write value map
end


# serialize_trace(tr::T) where T <: Gen.Trace

# function _deserialize_lazy(io::IO; gen_fn=nothing)
#     restore_ptr = io.ptr
#     trace_type = Serialization.deserialize(io)
#     io.ptr = restore_ptr
#     _deserialize_lazy(io, trace_type, gen_fn=gen_fn)
# end
# export _deserialize
# export serialize
# export _deserialize_lazy
export serialize