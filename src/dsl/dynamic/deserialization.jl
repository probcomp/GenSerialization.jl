function deserialize_record(io::IO, record_info::RECORD_INFO)
    cuptr = position(io)
    seek(io, record_info.record_ptr)
    score = read(io, Float64)
    noise = read(io, Float64)
    is_choice = read(io, Bool)
    subtrace_or_retval = Serialization.deserialize(io)
    record = Gen.ChoiceOrCallRecord(subtrace_or_retval, score, noise, is_choice)
    @debug "CHOICE" record_ptr=record_info.record_ptr is_choice record
    seek(io, cuptr)
    record
end

function deserialize_trie(io::IO, ptr_trie, tr, prefix::Tuple=())
    for (addr, record_info) in ptr_trie.leaf_nodes
        key = foldr(=> , (prefix..., addr,))
        if record_info.is_trace
            cuptr = position(io)
            seek(io, record_info.record_ptr)
            subtrace = deserialize_trace(io)
            # println("Subtrace ", subtrace)
            Gen.add_call!(tr, key, subtrace)
            seek(io, cuptr)
        else
            tr.trie[key] = deserialize_record(io, record_info)
        end
    end 
    for (addr, subtrie) in ptr_trie.internal_nodes
        flattened_key = (prefix..., addr,)
        deserialize_trie(io, subtrie, tr, flattened_key)
    end
end

function convert_to_lazy_trace(io::IO, ptr_trie, isempty, score, noise, args, retval)
    trie = Trie{Any, Gen.ChoiceOrCallRecord}()
    tr = LazyDynamicDSL.LazyDynamicTrace(trie, isempty, 0.0, noise, args, retval)
    deserialize_trie(io, ptr_trie, tr)
    tr.score = score
    # Traverse trie
    tr
end

function read_address_maps(io::IO, ptr_trie::Trie{Any, RECORD_INFO}, prefix::Tuple)

    cuptr = position(io)
    leaf_map_ptr = read(io, Int)
    internal_map_ptr = read(io, Int)
    # @debug "[LEAF MAP] [INTERNAL MAP PTR]" current_trie leaf_map_ptr internal_map_ptr
    leaf_count = read(io, Int)
    # @debug "LEAF COUNT" leaf_count
    for i=1:leaf_count
        addr = foldr(=> , (prefix..., Serialization.deserialize(io)))
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

function deserialize_trace(io::IO, ::Type{Gen.DynamicDSLTrace{T}}) where {T}
    trace_type = Serialization.deserialize(io)
    isempty = read(io, Bool)
    score = read(io, Float64)
    noise = read(io, Float64)
    args = Serialization.deserialize(io)
    retval = Serialization.deserialize(io)

    @debug "DESERIALIZE" type=trace_type isempty score noise args retval _module=""
    ptr_trie = Gen.Trie{Any, RECORD_INFO}()
    if !isempty
        ptr_trie = read_address_maps(io, ptr_trie, ())
    end

    trace = convert_to_lazy_trace(io, ptr_trie, isempty, score, noise, args, retval)
end