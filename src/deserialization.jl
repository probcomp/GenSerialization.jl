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

export deserialize 
export realize