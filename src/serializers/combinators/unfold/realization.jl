mutable struct UnfoldDeserializeState{T,U}
    score::Float64
    noise::Float64
    subtraces::Vector{U}
    retval::Vector{T}
    num_nonempty::Int
    state::T
end

function deseiralize_trace(io::IO, gen_fn::Unfold{T,U}) where {T,U}
    trace_type = Serialization.deserialize(io)
    !(trace_type <: Gen.VectorTrace) && error("Expected VectorTrace, got $trace_type")
    retval = Serialization.deserialize(io)
    args = Serialization.deserialize(io)
    len = read(io, Int)
    num_nonempty = read(io, Int)
    score = read(io, Float64)
    noise = read(io, Float64)

    init_state = args[2]
    params = args[3:end]
    state = UnfoldDeserializeState{T,U}(0., 0.,
        Vector{U}(undef,len), Vector{T}(undef,len), 0, init_state)
    base_ptr = position(io)
    for key=1:len
        seek(io, base_ptr + (key-1)*sizeof(Int))
        tr_ptr = read(io, Int)
        seek(io, tr_ptr)
        subtrace = deserialize_trace(io, gen_fn.kernel)
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