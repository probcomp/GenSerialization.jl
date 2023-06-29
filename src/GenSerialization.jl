module GenSerialization
using Gen





# RECORD_INFO = NamedTuple{(:record_ptr, :record_size, :is_trace), Tuple{Int64, Int64, Bool}}

# function Gen.set_internal_node!(trie::Trie{K,V}, addr::Pair) where {K,V}
#     (first, rest) = addr
#     if haskey(trie.internal_nodes, first)
#         node = trie.internal_nodes[first]
#     else
#         node = Trie{K,V}()
#         trie.internal_nodes[first] = node
#     end
#     Gen.set_internal_node!(node, rest)
# end
# function Gen.set_internal_node!(trie::Trie{K,V}, addr) where {K,V}
#     trie.internal_nodes[addr] = Trie{K,V}()
# end

# include("lazy/lazy.jl")
# include("dynamic/serialization.jl")
include("gen_file.jl")
include("file_header.jl")
include("serialization.jl")
include("deserialization.jl")

end
