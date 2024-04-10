using GenSerialization
using Gen
using Test

function roundtrip_test(tr::Gen.Trace, model::Gen.GenerativeFunction)
    io = IOBuffer()
    serialize(io, tr)
    seekstart(io)
    recovered_tr = deserialize(io, model)

    test_equality(tr, recovered_tr)
    return true
end



include("equality.jl")
include("simple.jl")
include("combinators.jl")

return