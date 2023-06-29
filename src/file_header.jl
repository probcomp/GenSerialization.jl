"""
Header of Gen file. Contains version info.
"""
const FILE_HEADER_LENGTH=512
const HEADER_TITLE="Gen Trace Format verison "
const FORMAT_VERSION = v"0.0.0"
const HEADER = "$(HEADER_TITLE)$(FORMAT_VERSION)\x00(Julia $(VERSION) $(sizeof(Int)*8)-bit $(htol(1) == 1 ? "LE" : "BE"))\x00"

@assert length(HEADER) <= FILE_HEADER_LENGTH

function verify_file_header(f)
    io = f.io
    seekstart(io)
    title = String(read!(io, Vector{UInt8}(undef, length(HEADER_TITLE))))
    title == HEADER_TITLE || error("Invalid file header. Likely not a Gen trace file.")

    ver = VersionNumber(String(readuntil(io, 0x00)))
    julia_info = String(readuntil(io, 0x00))
    
    return position(io)
end

function write_file_header(f)
    io = f.io
    seekstart(io)
    write(io, HEADER)
    return length(HEADER)
end