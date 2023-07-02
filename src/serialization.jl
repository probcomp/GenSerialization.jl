import Serialization: Serialization, serialize

function Serialization.serialize(filename::AbstractString, trace::Gen.Trace)
    genopen(filename, "w") do f
        header_length = write_file_header(f)
        serialize_trace(f.io, trace)
    end
end
# function Serialization.serialize(::IO, ::Gen.Trace)
#     file = GenFile(io, "", "w")
# end

function coarse_serialize(filename::AbstractString, trace::Gen.Trace)
    genopen(filename, "w") do f
        header_length = write_file_header(f)
        coarse_serialize(f.io, trace)
    end
end

function coarse_serialize(io::IO, trace::Gen.Trace)
    lazy = LazyDynamicDSL.convert_to_lazy(trace)
    Serialization.serialize(io, lazy)
end

export serialize, coarse_serialize