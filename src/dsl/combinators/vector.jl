function serialize_vector(io::IO, vector, ws::WriteSession)
    # Pointers to subtraces
    base_ptr = position(io)
    for i=1:length(vector) 
        genwrite(io, 0, ws)
    end
    for (i, tr) in enumerate(vector)
        blob_len = serialize_trace(io, tr)
        cuptr = position(io)
        seek(io, base_ptr + (i-1)*sizeof(Int))
        genwrite(io, blob_len, ws)
        seek(io, cuptr)
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