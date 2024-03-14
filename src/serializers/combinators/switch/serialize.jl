# struct SwitchTrace{A <: Tuple, T, U <: Trace} <: Trace
#     gen_fn::GenerativeFunction{T, U}
#     branch::U
#     retval::T
#     args::A
#     score::Float64
#     noise::Float64
#     function SwitchTrace(gen_fn::GenerativeFunction{T, U}, 
#             branch::U,
#             retval::T, args::A, score::Float64,
#             noise::Float64) where {T, A, U}
#         new{A, T, U}(gen_fn, branch, retval, args, score, noise)
#     end
# end

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