function serialize_vector(io::IO, vector, ws::WriteSession)
    # Pointers to subtraces
    base_ptr = position(io)
    println("Base ptr $base_ptr")
    for i=1:length(vector) 
        genwrite(io, 0, ws)
    end
    # println("ws before serializing $(length(ws))")
    for (i, tr) in enumerate(vector)
        cuptr = position(io)
        blob_len = serialize_trace(io, tr)

        # Manually update ws with blob_len
        ws.max = max(ws.max, cuptr+blob_len) 
        seek(io, base_ptr + (i-1)*sizeof(Int))
        genwrite(io, cuptr, ws)
        seek(io, cuptr+blob_len)
    end
end

function serialize_trace(io::IO, tr::Gen.VectorTrace{Gen.MapType, U, V}) where {U,V}
    cuptr = position(io)
    ws = WriteSession(cuptr)
    genwrite(io, typeof(tr), ws, Val{:serialized}())
    genwrite(io, tr.retval, ws, Val{:serialized}())
    genwrite(io, tr.args, ws, Val{:serialized}())
    genwrite(io, tr.len, ws)
    genwrite(io, tr.num_nonempty, ws)
    genwrite(io, tr.score, ws)
    genwrite(io, tr.noise, ws)
    serialize_vector(io, tr.subtraces, ws)
    seek(io, cuptr)

    return length(ws)
end

include("realization.jl")
include("deserialization.jl")