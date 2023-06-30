import Serialization: Serialization, serialize

function Serialization.serialize(filename::AbstractString, trace::Gen.Trace)
    genopen(filename, "w") do f
        header_length = write_file_header(f)
        serialize_trace(f.io, trace)
    end
end
function Serialization.serialize(::IO, ::Gen.Trace)
    file = GenFile(io, "", "w")
end

# function Serialization.serialize(filename::AbstractString, trace::Gen.DynamicDSLTrace)
#     genopen(filename, "w") do f
#         Serialization.serialize(f, trace)
#     end
# end



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