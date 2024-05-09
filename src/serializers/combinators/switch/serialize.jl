function serialize_trace(io::IO, tr::Gen.SwitchTrace) 
    cuptr = position(io)
    ws = WriteSession(cuptr)
    genwrite(io, typeof(tr), ws, Val{:serialized}())
    genwrite(io, tr.retval, ws, Val{:serialized}())
    genwrite(io, tr.args, ws, Val{:serialized}())
    genwrite(io, tr.score, ws)
    genwrite(io, tr.noise, ws)

    serialize_trace(io, tr.branch)
    return length(ws)
end