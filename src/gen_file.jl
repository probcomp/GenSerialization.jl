mutable struct GenFile{T<:IO}
    io::T
    path::String
    mode
    header_length::Int
end
function GenFile(io::T, path::String, mode::String) where {T<:IO}
    f = GenFile(io, path, mode, 0)
end

function io_size(io::IO)
    cuptr = position(io)
    seekend(io)
    size = position(io)
    seek(io, cuptr)
    return size
end

function openfile(T::Type, fname, mode)
    try
        openfile(T, fname, mode)
    catch
        @warn "Error saving Gen file. Using fallback..."
        @warn "No fallback!"
    end
end
function openfile(::Type{IOStream}, fname, mode)
    open(fname, mode)
end

FallbackType(::Type{IOStream}) = nothing

function genopen(fname::AbstractString, mode::String="r", iotype::T=IOStream) where T <: Union{Type{IOStream}}
    exists = ispath(fname)
    # TODO: Add safety locks with a 'finally' clause
    f = try
        io = openfile(iotype, fname, mode)
        rname = realpath(fname)
        f = GenFile(io, rname, mode)
        f
    catch e
        rethrow(e)
    end
    f
end

function close(f::GenFile)
    Base.close(f.io)
end

function genopen(f, fname::AbstractString, mode::String="r", iotype::T=IOStream) where T<: Union{Type{IOStream}}
    file = genopen(fname, mode, iotype)
    retval = f(file)
    close(file)
    retval
end