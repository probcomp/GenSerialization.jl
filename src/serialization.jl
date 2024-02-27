import Serialization: Serialization, serialize

"""
serialize(filename::AbstractString, trace::Gen.Trace)

Write a Gen trace to file `filename` in a opaque format intended for long term storage. Saved out trace data
is versioned and contains type information needed to reconstruct the trace. Therefore,
the trace definitions must exist in the runtime. 

Notes:
- Does NOT guarantee portability between different machines (e.g. different endianness).
- Uses Julia's `serialize` itself as a backend.
"""
function Serialization.serialize(filename::AbstractString, trace::Gen.Trace)
    genopen(filename, "w") do f
        header_length = write_file_header(f)
        serialize_trace(f.io, trace)
    end
end

export serialize