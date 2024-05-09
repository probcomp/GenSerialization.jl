import Serialization: Serialization, serialize, deserialize

"""
    serialize(filename::AbstractString, trace::Gen.Trace)

Write a Gen trace to file `filename` in a opaque format intended for long term storage. Saved out trace data
is versioned and contains type information needed to reconstruct the trace. Therefore,
the trace definitions must exist in the runtime. 

Notes:
- Does NOT guarantee portability between different machines (e.g. different endianness).
- Uses Julia's `serialize` itself as a backend.
"""
function Serialization.serialize(io::IO, trace::Gen.Trace)
    write_file_header(io)
    serialize_trace(io, trace)
end

function Serialization.serialize(filename::AbstractString, trace::Gen.Trace)
    genopen(filename, "w") do f
        Serialization.serialize(f.io, trace)
    end
end

"""
    deserialize(fname::AbstractString, gen_fn::GenerativeFunction)

Reads and returns a Gen trace from `fname` given a corresponding generative function `gen_fn`. "Realization" is an alternative to deserialization. It is slower
than deserialization and runs roughly as long as the generative function
takes to execute.
"""
function Serialization.deserialize(io::IO, gen_fn::GenerativeFunction) 
    verify_file_header(io)
    deserialize_trace(io, gen_fn)
end

function Serialization.deserialize(fname::AbstractString, gen_fn::GenerativeFunction)
    genopen(fname, "r") do f
        deserialize(f.io, gen_fn)
    end
end

include("dynamic/dynamic.jl")
include("combinators/combinators.jl")
export serialize, deserialize