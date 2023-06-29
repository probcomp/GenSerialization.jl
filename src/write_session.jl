mutable struct WriteSession
    min::Int
    max::Int
end
WriteSession(i) = WriteSession(i,i)
Base.length(ws::WriteSession) = ws.max - ws.min + 1

@inline function genwrite(io, x, ws::WriteSession, ::Val{:raw})
    cuptr = position(io)
    ws.min = min(ws.min, cuptr)
    ws.max = max(ws.max, cuptr)
    len = write(io, x)
    cuptr = position(io)
    ws.min = min(ws.min, cuptr)
    ws.max = max(ws.max, cuptr)
    return len
end

@inline function genwrite(io, x, ws::WriteSession, ::Val{:serialized})
    cuptr = position(io)
    ws.min = min(ws.min, cuptr)
    ws.max = max(ws.max, cuptr)
    Serialization.serialize(io, x)
    final_ptr = position(io)
    len = final_ptr - cuptr
    ws.min = min(ws.min, final_ptr)
    ws.max = max(ws.max, final_ptr)
    return len
end

@inline genwrite(io, x, ws::WriteSession) = genwrite(io, x, ws, Val{:raw}())
