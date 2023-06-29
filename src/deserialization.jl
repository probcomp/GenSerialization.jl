"""
    deserialize(fname::AbstractString)

Returns a deserialized trace with no (sub) generative functions associated
to it. The returned trace is compatabile with the GFI interfaces, and is converted
to a normal trace during GFI execution.
"""
function deserialize(fname::AbstractString)
    genopen(fname, "r") do f
        header_length = verify_file_header(f)
        f.header_length = header_length
        tr = deserialize_trace(f.io)
    end
end

function deserialize_trace(io::IO)
    cuptr = position(io) # Start of trace segment
    trace_type = Serialization.deserialize(io)
    seek(io, cuptr)
    deserialize_trace(io, trace_type)
end

"""
    realize(fname::AbstractString, gen_fn::GenerativeFunction)

Reads and returns a Gen trace from `fname` given a corresponding generative function `gen_fn`. "Realization" is an alternative to deserialization. It is slower
than deserialization and runs roughly as long as the generative function
takes to execute.
"""
function realize(fname::AbstractString, gen_fn::GenerativeFunction)
    genopen(fname, "r") do f
        header_length = verify_file_header(f)
        f.header_length = header_length
        println("Yo")
        tr = realize_trace(f.io, gen_fn)
    end
end

function coarse_deserialize(fname::AbstractString)
    genopen(fname, "r") do f
        header_length = verify_file_header(f)
        f.header_length = header_length
        tr = Serialization.deserialize(f.io)
    end
end

export deserialize, realize, coarse_deserialize