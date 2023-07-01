# HEADER
# [attributes] [# of leaf] [is_leaf, size, address, non-trace] [internal, size, address, non-trace] [# internal] [is_leaf, address, trace] [internal, addres, trace]


function serialize_address_map(io, trie::Trie{K,V}) where {K,V}
    map = Dict{Any, Int64}()

    # Leaf address map
    leaf_map_ptr = position(io)
    write(io, length(trie.leaf_nodes))
    for (addr, record) in trie.leaf_nodes
        is_trace = isa(record.subtrace_or_retval, Trace)
        Serialization.serialize(io, addr)
        map[addr] = position(io)
        write(io, 0) # Record ptr
        write(io, 0) # Size of record
        write(io, is_trace)
    end

    internal_map_ptr = position(io)
    write(io, length(trie.internal_nodes))
    for (addr, subtrie) in trie.internal_nodes
        Serialization.serialize(io, addr)

        # TODO: Add assertion here. If DynamicDSL invariant holds, then maybe not necessary?
        map[addr] = position(io)
        write(io, 0) # Trie ptr 
        write(io,0) # Size of trie
    end
    @debug "MAP" map leaf_map_ptr internal_map_ptr _module=""
    map, leaf_map_ptr, internal_map_ptr
end

function serialize_records(io, trie::Trie{K,V}, map::Dict{Any, Int64}) where {K,V}
    # Choices/Traces
    for (addr, record) in trie.leaf_nodes
        is_trace = isa(record.subtrace_or_retval, Trace)
        # ptr = io.ptr
        cuptr = position(io)
        hmac = rand(1:100000)
        @debug "LEAF" addr is_trace record_in_map=map[addr] record _module="" hmac

        if is_trace
            tr = record.subtrace_or_retval
            serialize_trace(io, tr)
        else
            # Deswizzle record
            write(io, record.score)
            write(io, record.noise)
            write(io, record.is_choice)
            Serialization.serialize(io, record.subtrace_or_retval)
        end

        # TODO: Check if nothing was serialized?
        seek(io, map[addr])
        len = write(io, cuptr)
        write(io, len)
        @debug "LEAF" addr record_ptr=cuptr length=(io.size-cuptr) hmac _module=""
        seekend(io)
    end

    for (addr, subtrie) in trie.internal_nodes
        hmac = rand(-10000:-1)
        cuptr = position(io)
        # ptr = io.ptr
        @debug "INTERNAL" addr hmac trie=cuptr
        serialize_dynamic_trie(io, subtrie)
        seek(io, map[addr])
        len = write(io, cuptr)
        write(io, len)
        seekend(io)
        @debug "INTERNAL" addr record_ptr=ptr length=(io.size-ptr) hmac=hmac _module=""
    end
end

function serialize_dynamic_trie(io, trie::Trie) 
    # HEADER - | leaf count | leaf map | leaves | internal count | addr map | tries | 
    # ptr = io.ptr
    cuptr = position(io)
    write(io, 0) # undefined ptr to leaf map
    write(io, 0) # undefined ptr to internal map
    @debug "TRIE" start=cuptr
    addr_map, leaf_map_ptr, internal_map_ptr = serialize_address_map(io, trie)
    @debug "MAP PTRS" leaf_map_ptr internal_map_ptr
    seek(io, cuptr)
    write(io, leaf_map_ptr)
    write(io, internal_map_ptr)
    seekend(io)
    serialize_records(io, trie, addr_map)
end

function serialize_trace(io::IO, tr::Gen.DynamicDSLTrace{T}) where {T} 
    # HEADER - type, isempty, score, noise, args, retval, [trie]
    Serialization.serialize(io, typeof(tr))
    write(io, tr.isempty)
    write(io, tr.score)
    write(io, tr.noise)
    Serialization.serialize(io, tr.args)
    Serialization.serialize(io, tr.retval)
    # @debug "HEADER" type=typeof(tr) tr.isempty tr.score tr.noise tr.args tr.retval _module=""

    if !tr.isempty
        serialize_dynamic_trie(io, tr.trie)
    end

    # @debug "END" _module=""
    return nothing
end