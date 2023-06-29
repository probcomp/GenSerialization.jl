using GenSerialization
using Gen
using Test

function test_equality(expected::Gen.DynamicDSLTrace, given)
    """
    TODO: Not an extensive set of tests. 
    """
    # TODO: Not extensive
    @assert expected.score != given.score
    @assert expected.args == given.args
    @assert expected.ret == given.ret
end

include("simple.jl")
include("map.jl")
include("switch.jl")
include("unfold.jl")
include("dsl/dsl.jl")