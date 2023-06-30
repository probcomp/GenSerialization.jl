using GenSerialization
using Test

@testset "GenSerialization.jl" begin
    Test.runtests("DynamicDSLTrace Serialization")
end
include("dsl/dsl.jl")