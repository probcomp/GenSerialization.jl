function deserialize_trace(io::IO, gen_fn::Switch{C, N, K, T}) where {C, N, K, T}
    trace_type = Serialization.deserialize(io)
    !(trace_type <: Gen.SwitchTrace) && error("Expected SwitchTrace, got $trace_type")
    retval = Serialization.deserialize(io)
    args = Serialization.deserialize(io)
    score = read(io, Float64)
    noise = read(io, Float64)
    branch = deserialize_trace(io, gen_fn.branches[args[1]])

    Gen.SwitchTrace(gen_fn, branch, retval, args, score, noise)
end