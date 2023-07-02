module GenSerialization
using Gen

function io_size(io::IO)
    cuptr = position(io)
    seekend(io)
    size = position(io)
    seek(io, cuptr)
    return size
end

include("gen_file.jl")
include("write_session.jl")
include("dsl/dsl.jl")
include("lazy/lazy.jl")
include("file_header.jl")
include("serialization.jl")
include("deserialization.jl")

end
