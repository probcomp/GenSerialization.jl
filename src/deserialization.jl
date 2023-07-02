function deserialize_trace(io::IO)
    cuptr = position(io)
    trace_type = Serialization.deserialize(io)
    seek(io, cuptr)
    deserialize_trace(io, trace_type)
end

function deserialize(fname::AbstractString)
    genopen(fname, "r") do f
        header_length = verify_file_header(f)
        f.header_length = header_length
        tr = deserialize_trace(f.io)
    end
end

function realize(fname::AbstractString, gen_fn::GenerativeFunction)
    genopen(fname, "r") do f
        header_length = verify_file_header(f)
        f.header_length = header_length
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