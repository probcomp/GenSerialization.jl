# # HEADER
# # [attributes] [# of leaf] [is_leaf, size, address, non-trace] [internal, size, address, non-trace] [# internal] [is_leaf, address, trace] [internal, addres, trace]


# function serialize_address_map(io, trie::Trie{K,V}, ws::WriteSession) where {K,V}
#     map = Dict{Any, Int64}()

#     # Leaf address map
#     leaf_map_ptr = position(io)
#     genwrite(io, length(trie.leaf_nodes), ws)
#     for (addr, record) in trie.leaf_nodes
#         is_trace = isa(record.subtrace_or_retval, Trace)
#         genwrite(io, addr, ws, Val{:serialized}())
#         map[addr] = position(io)
#         genwrite(io, 0, ws) # Record ptr
#         genwrite(io, 0, ws) # Size of record
#         genwrite(io, is_trace, ws)
#     end

#     internal_map_ptr = position(io)
#     genwrite(io, length(trie.internal_nodes), ws)
#     for (addr, subtrie) in trie.internal_nodes
#         genwrite(io, addr, ws, Val{:serialized}())

#         # TODO: Add assertion here. If DynamicDSL invariant holds, then maybe not necessary?
#         map[addr] = position(io)
#         genwrite(io, 0, ws) # Trie ptr 
#         genwrite(io,0, ws) # Size of trie
#     end
#     @debug "MAP" map leaf_map_ptr internal_map_ptr _module=""
#     map, leaf_map_ptr, internal_map_ptr
# end

# function serialize_records(io, trie::Trie{K,V}, map::Dict{Any, Int64}, ws::WriteSession) where {K,V}
#     # Choices/Traces
#     for (addr, record) in trie.leaf_nodes
#         is_trace = isa(record.subtrace_or_retval, Trace)
#         # ptr = io.ptr
#         cuptr = position(io)
#         hmac = rand(1:100000)
#         @debug "LEAF" addr is_trace record_in_map=map[addr] record _module="" hmac

#         if is_trace
#             tr = record.subtrace_or_retval
#             p = position(io)
#             dump_len = serialize_trace(io, tr)
#             ws.max = max(ws.max, p+dump_len)
#         else
#             # Deswizzle record
#             genwrite(io, record.score, ws)
#             genwrite(io, record.noise, ws)
#             genwrite(io, record.is_choice, ws)
#             genwrite(io, record.subtrace_or_retval, ws, Val{:serialized}())
#         end

#         # TODO: Check if nothing was serialized?
#         seek(io, map[addr])
#         len = genwrite(io, cuptr, ws)
#         genwrite(io, len, ws)
#         @debug "LEAF" addr record_ptr=cuptr length=(io.size-cuptr) hmac _module=""
#         seekend(io) # TODO: Change this
#     end

#     for (addr, subtrie) in trie.internal_nodes
#         hmac = rand(-10000:-1)
#         cuptr = position(io)
#         # ptr = io.ptr
#         @debug "INTERNAL" addr hmac trie=cuptr
#         serialize_dynamic_trie(io, subtrie, ws)
#         seek(io, map[addr])
#         len = write(io, cuptr)
#         write(io, len)
#         seekend(io)
#         @debug "INTERNAL" addr record_ptr=ptr length=(io.size-ptr) hmac=hmac _module=""
#     end
# end

# function serialize_dynamic_trie(io, trie::Trie, ws::WriteSession) 
#     # HEADER - | leaf count | leaf map | leaves | internal count | addr map | tries | 
#     # ptr = io.ptr
#     cuptr = position(io)
#     genwrite(io, 0, ws) # undefined ptr to leaf map
#     genwrite(io, 0, ws) # undefined ptr to internal map
#     @debug "TRIE" start=cuptr
#     addr_map, leaf_map_ptr, internal_map_ptr = serialize_address_map(io, trie, ws)
#     @debug "MAP PTRS" leaf_map_ptr internal_map_ptr
#     seek(io, cuptr)
#     genwrite(io, leaf_map_ptr, ws)
#     genwrite(io, internal_map_ptr, ws)
#     seekend(io) # TODO: Serialization should be self-contained. Change this.
#     serialize_records(io, trie, addr_map, ws)
# end

# function serialize_trace(io::IO, tr::Gen.DynamicDSLTrace{T}) where {T} 
#     # HEADER - type, isempty, score, noise, args, retval, [trie]
#     ws = WriteSession(position(io))
#     genwrite(io, typeof(tr), ws, Val{:serialized}())
#     genwrite(io, tr.isempty, ws)
#     genwrite(io, tr.score, ws)
#     genwrite(io, tr.noise, ws)
#     genwrite(io, tr.args, ws, Val{:serialized}())
#     genwrite(io, tr.retval, ws, Val{:serialized}())
#     # @debug "HEADER" type=typeof(tr) tr.isempty tr.score tr.noise tr.args tr.retval _module=""

#     if !tr.isempty
#         serialize_dynamic_trie(io, tr.trie, ws)
#     end

#     # @debug "END" _module=""
#     return length(ws)
# end