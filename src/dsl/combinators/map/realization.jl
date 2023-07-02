mutable struct MapDeserializeState{T,U}
    score::Float64
    noise::Float64
    subtraces::Vector{U}
    retval::Vector{T}
    num_nonempty::Int
end

function realize_trace(io::IO, gen_fn::Map{T,U}) where {T,U}
    trace_type = Serialization.deserialize(io)
    !(trace_type <: Gen.VectorTrace) && error("Expected VectorTrace, got $trace_type")
    retval = Serialization.deserialize(io)
    args = Serialization.deserialize(io)
    len = read(io, Int)
    num_nonempty = read(io, Int)
    score = read(io, Float64)
    noise = read(io, Float64)
    len = length(args[1])
    base_ptr = position(io)
    state = MapDeserializeState{T,U}(0., 0., Vector{U}(undef,len), Vector{T}(undef,len), 0)
    for key=1:len
        seek(io, base_ptr + (key-1)*sizeof(Int))
        tr_ptr = read(io, Int)
        seek(io, tr_ptr)
        subtrace = realize_trace(io, gen_fn.kernel)
        state.subtraces[key] = subtrace
        retval = get_retval(subtrace)
        state.retval[key] = retval
    end
    state.noise = noise
    state.num_nonempty = num_nonempty
    state.score = score
    Gen.VectorTrace{Gen.MapType,T,U}(gen_fn,
        Gen.PersistentVector{U}(state.subtraces), Gen.PersistentVector{T}(state.retval),
        args, state.score, state.noise, len, state.num_nonempty)
end