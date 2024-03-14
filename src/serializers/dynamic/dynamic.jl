RECORD_INFO = NamedTuple{(:record_ptr, :record_size, :is_trace), Tuple{Int64, Int64, Bool}}

function read_address_maps(io::IO, ptr_trie::Trie{Any, RECORD_INFO}, prefix::Tuple)
    cuptr = position(io)
    leaf_map_ptr = read(io, Int)
    internal_map_ptr = read(io, Int)
    # @debug "[LEAF MAP] [INTERNAL MAP PTR]" current_trie leaf_map_ptr internal_map_ptr
    leaf_count = read(io, Int)
    # @debug "LEAF COUNT" leaf_count
    for _ in 1:leaf_count
        addr = foldr(=> , (prefix...,  Serialization.deserialize(io)))
        record_ptr = read(io, Int)
        record_size = read(io, Int)
        is_trace = read(io, Bool)

        ptr_trie[addr] = (record_ptr=record_ptr, record_size=record_size, is_trace=is_trace)
        @debug "LEAF" addr record_ptr size=record_size is_trace
    end

    internal_count = read(io, Int)
    @debug "INTERNAL COUNT" internal_count
    for i=1:internal_count
        flattened_addr = (prefix..., Serialization.deserialize(io))
        addr = foldr(=> , flattened_addr)
        trie_ptr = read(io, Int)
        trie_size = read(io,Int)
        @debug "INTERNAL" addr trie_ptr trie_size  

        internal_node = Gen.Trie{Any, RECORD_INFO}()
        Gen.set_internal_node!(ptr_trie, addr, internal_node)

        restore_ptr = position(io)
        seek(io, trie_ptr) # Next trie
        read_address_maps(io, ptr_trie, flattened_addr)
        seek(io, restore_ptr)
    end

    @debug "MAP" ptr_trie _module=""

    seek(io, cuptr)
    ptr_trie
end

include("serialize.jl")
include("deserialize.jl")