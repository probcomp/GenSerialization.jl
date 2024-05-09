function serialize_vector(io::IO, vector, ws::WriteSession)
    # Pointers to subtraces
    base_ptr = position(io)
    for i=1:length(vector) 
        genwrite(io, 0, ws)
    end
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

function serialize_trace(io::IO, tr::Gen.VectorTrace{C, U, V}) where {C,U,V}
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

function deserialize_trace(io::IO, ::Type{Gen.VectorTrace{C, U, V}}) where {C,U,V}
    trace_type = Serialization.deserialize(io)
    retval = Serialization.deserialize(io)
    args = Serialization.deserialize(io)
    len = read(io, Int)
    num_nonempty = read(io, Int)
    score = read(io, Float64)
    noise = read(io, Float64)

    @debug "DESERIALIZE" type=trace_type isempty score noise args retval _module=""
    # ptr_trie = Gen.Trie{Any, RECORD_INFO}()
    ptr_vector = nothing
    # if !isempty
        # ptr_trie = read_address_maps(io, ptr_trie, ())
    # end

    LazyVectorTrace(io, ptr_vector, retval, args, score, noise, len, num_nonempty)
end
