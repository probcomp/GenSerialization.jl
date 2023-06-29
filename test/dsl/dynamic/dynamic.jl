
function test_serialize_address_map()
    trie = Gen.Trie{Any, Gen.ChoiceOrCallRecord}()
    trie[:a] = Gen.ChoiceOrCallRecord(1.0, -1.0, NaN, true)
    io = IOBuffer()
    map, leaf_map_ptr, internal_map_ptr = GenSerialization.serialize_address_map(io, trie)
    println(map, " ", leaf_map_ptr, " ", internal_map_ptr)
    leaf_map_ptr == 0 || error("leaf_map_ptr modified")
end

function test_serialize_address_map_2()
    trie = Gen.Trie{Any, Gen.ChoiceOrCallRecord}()
    trie[:a] = Gen.ChoiceOrCallRecord(1.0, -1.0, NaN, true)
    set_leaf_node!(trie, :b=>:c, Gen.ChoiceOrCallRecord(1.0, -1.0, NaN, true))
    io = IOBuffer()
    map, leaf_map_ptr, internal_map_ptr = GenSerialization.serialize_address_map(io, trie)
    println(map, " ", leaf_map_ptr, " ", internal_map_ptr)
    error("What")
end

@testset "Serialization" begin
    @test test_serialize_address_map()
    @test test_serialize_address_map_2()
end